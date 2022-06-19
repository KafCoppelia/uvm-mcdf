`ifndef MCDF_SCOREBOARD_SV
`define MCDF_SCOREBOARD_SV

class scoreboard_mcdf extends uvm_scoreboard;
    local virtual interface_mcdf mcdf_vif;
    local virtual interface_arbiter arb_vif;
	local virtual interface_channel chnl_vifs[3];
    local int err_count;
    local int total_count;
    local int chnl_count[3];
    
    uvm_blocking_get_port #(transaction_formatter) scb_bg_ports[3];
    uvm_blocking_put_imp #(transaction_formatter, scoreboard_mcdf) fmt_bp_imp;
    mailbox #(transaction_formatter)  fmt_mb;

    `uvm_component_utils(scoreboard_mcdf)
    function new(string name = "scoreboard_mcdf", uvm_component parent = null);
        super.new(name, parent);
        this.err_count = 0;
        this.total_count = 0;
        foreach(this.chnl_count[i]) this.chnl_count[i] = 0;
        this.fmt_mb = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_mcdf)::get(this, "", "mcdf_vif", mcdf_vif))
            `uvm_fatal("model_mcdf", "virtual interface must be set for vif!!!");
        if(!uvm_config_db#(virtual interface_arbiter)::get(this, "", "arb_vif", arb_vif))
            `uvm_fatal("model_mcdf", "virtual interface must be set for vif!!!");
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch0_vif", chnl_vifs[0]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch1_vif", chnl_vifs[1]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch2_vif", chnl_vifs[2]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");

        foreach(scb_bg_ports[i]) 
            scb_bg_ports[i] = new($sformatf("scb_bg_ports[%0d]", i), this);
        fmt_bp_imp = new("fmt_bp_imp", this); 
    endfunction
    
    task put(transaction_formatter tr);
        fmt_mb.put(tr);
    endtask

    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern task do_channel_disable_check(int id);
    extern task do_arbiter_priority_check();
    extern task do_data_compare();
    extern function int get_slave_id_with_prio();
endclass


task scoreboard_mcdf::run_phase(uvm_phase phase);
    fork
        this.do_data_compare();
        this.do_channel_disable_check(0);
        this.do_channel_disable_check(1);
        this.do_channel_disable_check(2);
        this.do_arbiter_priority_check();
    join
endtask

task scoreboard_mcdf::do_data_compare();
    transaction_formatter expt, mont;
    bit cmp;
    forever begin
        this.fmt_mb.get(mont);
        this.scb_bg_ports[mont.ch_id].get(expt);
        cmp = mont.compare(expt);   
        this.total_count++;
        this.chnl_count[mont.ch_id]++;
        if(cmp == 0) begin
            this.err_count++;
            `uvm_error("[CMPERR]", $sformatf("%0dth times comparing but failed! MCDF monitored output packet is different with reference model output", this.total_count))
        end
        else begin
            `uvm_info("[CMPSUC]",$sformatf("%0dth times comparing and succeeded! MCDF monitored output packet is the same with reference model output", this.total_count), UVM_LOW)
        end
      end
endtask

task scoreboard_mcdf::do_channel_disable_check(int id);
    forever begin
        @(posedge this.mcdf_vif.clk iff (this.mcdf_vif.rstn && this.mcdf_vif.mon_ck.chnl_en[id]===0));
        if(this.chnl_vifs[id].mon_ck.ch_valid===1 && this.chnl_vifs[id].mon_ck.ch_ready===1)
        	`uvm_error("[CHKERR]", "ERROR! when channel disabled, ready signal raised when valid high") 
    end
endtask

task scoreboard_mcdf::do_arbiter_priority_check();
    int id;
    forever begin
        @(posedge this.arb_vif.clk iff (this.arb_vif.rstn && this.arb_vif.mon_ck.f2a_id_req===1));
        id = this.get_slave_id_with_prio();
        if(id >= 0) begin
          	@(posedge this.arb_vif.clk);
          	if(this.arb_vif.mon_ck.a2s_acks[id] !== 1)
            	`uvm_error("[CHKERR]", $sformatf("ERROR! arbiter received f2a_id_req===1 and channel[%0d] raising request with high priority, but is not granted by arbiter", id))
        end
      end
endtask

function int scoreboard_mcdf::get_slave_id_with_prio();
    int id=-1;
    int prio=999;
    foreach(this.arb_vif.mon_ck.slv_prios[i]) begin
        if(this.arb_vif.mon_ck.slv_prios[i] < prio && this.arb_vif.mon_ck.slv_reqs[i]===1) begin
          id = i;
          prio = this.arb_vif.mon_ck.slv_prios[i];
        end
    end
    return id;
endfunction

function void scoreboard_mcdf::report_phase(uvm_phase phase);
        string s;
        super.report_phase(phase);
        s = "\n************************************************************************\n";
        s = {s, "Compare Summary:\n"}; 
        s = {s, $sformatf("total comparison count: %0d \n", this.total_count)}; 
        foreach(this.chnl_count[i]) 
            s = {s, $sformatf("\tchannel[%0d] comparison count: %0d \n", i, this.chnl_count[i])};
        s = {s, $sformatf("total error count: %0d \n", this.err_count)}; 
        /* foreach(this.chnl_mbs[i]) begin
        if(this.chnl_mbs[i].num() != 0)
            s = {s, $sformatf("WARNING:: chnl_mbs[%0d] is not empty! size = %0d \n", i, this.chnl_mbs[i].num())}; 
        end*/
        if(this.fmt_mb.num() != 0)
            s = {s, $sformatf("WARNING:: fmt_mb is not empty! size = %0d \n", this.fmt_mb.num())}; 
        s = {s, "************************************************************************\n"};
        `uvm_info(get_type_name(), s, UVM_LOW)
endfunction

`endif
 
