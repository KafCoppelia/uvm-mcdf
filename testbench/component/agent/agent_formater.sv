`ifndef AGENT_FORMATER_SV
`define AGENT_FORMATER_SV

class agent_formatter extends uvm_agent;
	driver_formatter drv;
	monitor_formatter mon;
	sequencer_formatter sqr;

	// uvm_analysis_port #(my_transaction) ap;

	`uvm_component_utils(agent_formatter);
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass

function void agent_formatter::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv = driver_formatter::type_id::create("drv", this);
		sqr = sequencer_formatter::type_id::create("sqr", this);
	end
	mon = monitor_formatter::type_id::create("mon", this);
endfunction

function void agent_formatter::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
	// ap = mon.ap;
endfunction

`endif

