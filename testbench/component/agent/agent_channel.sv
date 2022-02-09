`ifndef AGENT_CHANNEL_SV_
`define AGENT_CHANNEL_SV_

class agent_channel extends uvm_agent;
	driver_chnl drv;
	monitor_chnl mon;
	sequencer_chnl sqr;

	uvm_analysis_port #(transaction_chnl) ap;

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
		drv = driver_chnl::type_id::create("drv", this);
		sqr = sequencer_chnl::type_id::create("sqr", this);
	end
	mon = monitor_chnl::type_id::create("mon", this);
endfunction

function void agent_channel::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
	// ap = mon.ap;
endfunction

`endif

