`ifndef MONITOR_CHANNEL_SV
`define MONITOR_CHANNEL_SV

typedef struct packed{
    bit[31:0] data;
    bit[1:0] id;
}mon_data_t;

class monitor_channel extends uvm_monitor;
	local virtual interface_channel vif;
	
    uvm_blocking_put_port #(mon_data_t) mon_bp_port;

	`uvm_component_utils(monitor_channel)
	function new(string name = "monitor_channel", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface_channel)::get(this, "", "vif", vif))
			`uvm_fatal("montior_channel", "virtual interface must be set for vif!!!");
		mon_bp_port = new("mon_bp_port", this);
	endfunction

	extern task run_phase(uvm_phase phase);
	// extern task collect_one_pkt(my_transaction tr);

endclass

task monitor_channel::run_phase(uvm_phase phase);
	mon_data_t mtr;
	while(1) begin
        @(posedge vif.clk iff(vif.mon_ck.ch_valid==='b1 && vif.mon_ck.ch_ready==='b1));
        mtr.data = vif.mon_ck.ch_data;
        mon_bp_port.put(mtr);
        `uvm_info("monitor_channel", $sformatf("monitored channel data 'h%8x", mtr.data), UVM_HIGH)
	end
endtask

`endif

