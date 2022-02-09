`ifndef AGENT_FORMATER_SV
`define AGENT_FORMATER_SV

class agent_formater extends uvm_agent;
	driver_formater drv;
	monitor_formater mon;
	sequencer_formater sqr;

	// uvm_analysis_port #(my_transaction) ap;

	`uvm_component_utils(agent_formater);
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass

function void agent_formater::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv = driver_formater::type_id::create("drv", this);
		sqr = sequencer_formater::type_id::create("sqr", this);
	end
	mon = monitor_formater::type_id::create("mon", this);
endfunction

function void agent_formater::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
	// ap = mon.ap;
endfunction

`endif

