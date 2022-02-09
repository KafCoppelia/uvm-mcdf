`ifndef BUS_MONITOR_SV
`define BUS_MONITOR_SV

class monitor_bus extends uvm_monitor;
	virtual interface_bus vif;
	
	uvm_analysis_port #(transaction_bus) ap;

	`uvm_component_utils(monitor_bus)
	function new(string name = "monitor_bus", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface_bus)::get(this, "", "vif", vif))
			`uvm_fatal("montior_bus", "virtual interface must be set for vif!!!");
		ap = new("ap", this);
	endfunction

	extern task main_phase(uvm_phase phase);
	extern task collect_one_pkt(transaction_bus tr);

endclass

task monitor_bus::main_phase(uvm_phase phase);
	transaction_bus tr;
	while(1) begin
		tr = new("tr");
		collect_one_pkt(tr);
		ap.write(tr);
	end
endtask

task monitor_bus::collect_one_pkt(transaction_bus tr);
	
	while(1) begin
		@(posedge vif.clk);
		if(vif.bus_cmd_valid) break;
	end

    tr.bus_op = ((vif.bus_op == 0) ? BUS_RD : BUS_WR);
    tr.addr = vif.bus_addr;
    tr.wr_data = vif.bus_wr_data;
	@(posedge vif.clk);
	tr.rd_data = vif.bus_rd_data;
	
	`uvm_info("monitor_bus", $sformatf("end collect one pkt, bus_op : %0d", tr.bus_op), UVM_HIGH);

endtask

`endif

