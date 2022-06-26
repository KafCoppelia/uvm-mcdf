`ifndef BUS_MONITOR_SV
`define BUS_MONITOR_SV

class monitor_bus extends uvm_monitor;
    virtual interface_bus vif;
    
    uvm_analysis_port #(transaction_bus) mon_ana_port;

    `uvm_component_utils(monitor_bus)
    function new(string name = "monitor_bus", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_bus)::get(this, "", "vif", vif))
            `uvm_fatal("montior_bus", "virtual interface must be set for vif!!!");
        mon_ana_port = new("mon_ana_port", this);
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task collect_one_pkt(transaction_bus tr);

endclass

task monitor_bus::run_phase(uvm_phase phase);
    transaction_bus tr;
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        mon_ana_port.write(tr);
    end
endtask

task monitor_bus::collect_one_pkt(transaction_bus tr);
    
    @(posedge vif.clk iff (vif.rstn && vif.mon_ck.psel == 1'b1 && vif.mon_ck.penable == 1'b0));
    tr.addr = vif.mon_ck.paddr;
    if(vif.mon_ck.pwrite == 1'b1) begin
        @(posedge vif.clk);
        tr.cmd = `WRITE;
        tr.data = vif.mon_ck.pwdata;
    end
    else if(vif.mon_ck.pwrite == 1'b0) begin
        @(posedge vif.clk);
        tr.cmd = `READ;
        tr.data = vif.mon_ck.prdata;
    end

    `uvm_info(get_type_name(), $sformatf("monitored addr %2x, cmd %s, data 0x%8x", tr.addr, tr.cmd == `WRITE ? "write" : "read", tr.data), UVM_LOW)

endtask

`endif

