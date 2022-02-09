class my_scoreboard extends uvm_scoreboard;
    transaction_dut  mdl_queue[$];
    local int compare_cnt = 0;
    local int success_cnt= 0;
    local int failure_cnt = 0;

    uvm_blocking_get_port #(transaction_dut)  pack_mdl_in;     // from reference model
    uvm_blocking_get_port #(transaction_dut)  pack_mon_in;     // from out_agt.monitor
    
    `uvm_component_utils(my_scoreboard)
    function new(string name="my_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        pack_mdl_in = new("pack_mdl_in", this);
        pack_mon_in = new("pack_mon_in", this);
    endfunction
    extern virtual task main_phase(uvm_phase phase);
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("\n************************************************************************");
        $display("Compare %0d time(s): %0d success(es), %0d failure(s).", compare_cnt, success_cnt, failure_cnt);
        $display("************************************************************************");
    endfunction
endclass 
 
task my_scoreboard::main_phase(uvm_phase phase);
    transaction_dut mdl_temp, mdl_cmp, mon_cmp; 
    bit result;
    super.main_phase(phase);

    fork 
        while (1) begin
            pack_mdl_in.get(mdl_temp);
            mdl_queue.push_back(mdl_temp);
        end
        while (1) begin
            pack_mon_in.get(mon_cmp);
            if(mdl_queue.size() > 0) begin
                mdl_cmp = mdl_queue.pop_front();
                result = mon_cmp.compare(mdl_cmp);
                compare_cnt = compare_cnt + 1;
                if(result) begin 
                    success_cnt = success_cnt + 1;
                    `uvm_info("my_scoreboard", "Compare SUCCESSFULLY", UVM_HIGH);
                end
                else begin
                    failure_cnt = failure_cnt + 1;
                    `uvm_error("my_scoreboard", "Compare FAILED");
                    $display("################################################### below is reference model out:");
                    mdl_cmp.print();
                    $display("################################################### below is out_agent.monitor out:");
                    mon_cmp.print();
                end
            end
            else begin
                `uvm_error("my_scoreboard", "While received from out_agent.monitor, model Queue is empty: ");
                $display("the unexpected pkt is");
                mon_cmp.print();
            end 
        end
    join

 endtask
`ifndef MCDF_SCOREBOARD_SV
`define MCDF_SCOREBOARD_SV

class scoreboard_mcdf extends uvm_scoreboard;
    local virtual interface_mcdf mcdf_vif;
    local virtual interface_arb arb_vif;
    local int err_count;
    local int total_count;
    local int chnl_count[3];
    
    uvm_blocking_get_port #(transaction_fmt) scb_bg_ports[3];
    uvm_blocking_put_imp #(transaction_fmt, scoreboard_mcdf) fmt_bp_imp;
    mailbox #(transaction_fmt)  fmt_mb;

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
        if(!uvm_config_db#(virtual interface_arb)::get(this, "", "arb_vif", arb_vif))
            `uvm_fatal("model_mcdf", "virtual interface must be set for vif!!!");
        foreach(scb_bg_ports[i]) 
            scb_bg_ports[i] = new($sformatf("scb_bg_ports[%0d]", i), this);
        fmt_bp_imp = new("fmt_bp_imp", this); 
    endfunction
	
    task put(transaction_fmt tr);
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
        this.do_channel_disable_check(0);
        this.do_channel_disable_check(1);
        this.do_channel_disable_check(2);
        this.do_arbiter_priority_check();
        this.do_data_compare();
    join
endtask

task scoreboard_mcdf::do_data_compare();
    transaction_fmt expt, mont;
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
        /* @(posedge this.mcdf_vif.clk iff (this.mcdf_vif.rstn && this.mcdf_vif.mon_ck.chnl_en[id]===0));
        if(this.chnl_vifs[id].mon_ck.ch_valid===1 && this.chnl_vifs[id].mon_ck.ch_ready===1)
           `uvm_error("[CHKERR]", "ERROR! when channel disabled, ready signal raised when valid high") 
    */
        #1000;
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
      s = "\n---------------------------------------------------------------\n";
      s = {s, "CHECKER SUMMARY \n"}; 
      s = {s, $sformatf("total comparison count: %0d \n", this.total_count)}; 
      foreach(this.chnl_count[i]) s = {s, $sformatf(" channel[%0d] comparison count: %0d \n", i, this.chnl_count[i])};
      s = {s, $sformatf("total error count: %0d \n", this.err_count)}; 
      /* foreach(this.chnl_mbs[i]) begin
        if(this.chnl_mbs[i].num() != 0)
          s = {s, $sformatf("WARNING:: chnl_mbs[%0d] is not empty! size = %0d \n", i, this.chnl_mbs[i].num())}; 
      end*/
      if(this.fmt_mb.num() != 0)
          s = {s, $sformatf("WARNING:: fmt_mb is not empty! size = %0d \n", this.fmt_mb.num())}; 
      s = {s, "---------------------------------------------------------------\n"};
      `uvm_info(get_type_name(), s, UVM_LOW)
endfunction
/*
    task put_chnl0(mon_data_t t);
      chnl_mbs[0].put(t);
    endtask
    task put_chnl1(mon_data_t t);
      chnl_mbs[1].put(t);
    endtask
    task put_chnl2(mon_data_t t);
      chnl_mbs[2].put(t);
    endtask
    task put_fmt(fmt_trans t);
      fmt_mb.put(t);
    endtask
    task put_reg(reg_trans t);
      reg_mb.put(t);
    endtask
    task peek_chnl0(output mon_data_t t);
      chnl_mbs[0].peek(t);
    endtask
    task peek_chnl1(output mon_data_t t);
      chnl_mbs[1].peek(t);
    endtask
    task peek_chnl2(output mon_data_t t);
      chnl_mbs[2].peek(t);
    endtask
    task get_chnl0(output mon_data_t t);
      chnl_mbs[0].get(t);
    endtask
    task get_chnl1(output mon_data_t t);
      chnl_mbs[1].get(t);
    endtask
    task get_chnl2(output mon_data_t t);
      chnl_mbs[2].get(t);
    endtask
    task get_reg(output reg_trans t);
      reg_mb.get(t);
    endtask
*/


`endif
 
