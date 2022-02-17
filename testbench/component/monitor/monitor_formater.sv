`ifndef MONITOR_FORMATER_SV
`define MONITOR_FORMATER_SV

class monitor_formatter extends uvm_monitor;
	virtual interface_formatter vif;
	
	uvm_blocking_put_port #(transaction_formatter) mon_bp_port;

	`uvm_component_utils(monitor_formatter)
	function new(string name = "monitor_formatter", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface_formatter)::get(this, "", "vif", vif))
			`uvm_fatal("montior_formatter", "virtual interface must be set for vif!!!");
		mon_bp_port = new("mon_bp_port", this);
	endfunction

	extern task run_phase(uvm_phase phase);
	extern task collect_one_pkt(transaction_formatter tr);

endclass

task monitor_formatter::run_phase(uvm_phase phase);
	transaction_formatter tr;
	while(1) begin
		tr = new("tr");
		collect_one_pkt(tr);
		mon_bp_port.put(tr);
	end
endtask

task monitor_formatter::collect_one_pkt(transaction_formatter tr);
    string s;
	@(posedge vif.mon_ck.fmt_start);
    tr.length = vif.mon_ck.fmt_length;
    tr.ch_id = vif.mon_ck.fmt_chid;
    tr.data = new[tr.length];
    foreach(tr.data[i]) begin
		@(posedge vif.clk);
        tr.data[i] = vif.mon_ck.fmt_data;
	end
	
    s = $sformatf("\n==================================================\n");
    s = {s, $sformatf("%0t %s moniotred a packet: \n", $time, this.m_name)};
    s = {s, $sformatf("length = %d: \n", tr.length)};
    s = {s, $sformatf("chid = %d: \n", tr.ch_id)};
    foreach(tr.data[i])
        s = {s, $sformatf("data[%0d] = %8x \n", i, tr.data[i])};
    s = {s, $sformatf("==================================================\n")};	
	`uvm_info("monitor_formatter", s, UVM_HIGH);

endtask

`endif

