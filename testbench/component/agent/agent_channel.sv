`ifndef AGENT_CHANNEL_SV_
`define AGENT_CHANNEL_SV_

class agent_channel extends uvm_agent;
	driver_channel drv;
	monitor_channel mon;
	sequencer_channel sqr;

	uvm_analysis_port #(transaction_channel) ap;

	`uvm_component_utils(agent_channel);
	function new(string name = "agent_channel", uvm_component parent);
		super.new(name, parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass

function void agent_channel::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv = driver_channel::type_id::create("drv", this);
		sqr = sequencer_channel::type_id::create("sqr", this);
	end
	mon = monitor_channel::type_id::create("mon", this);
endfunction

function void agent_channel::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
	// ap = mon.ap;
endfunction

`endif

