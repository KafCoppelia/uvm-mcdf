`ifndef _SEQUENCER_PKG_SV
`define _SEQUENCER_PKG_SV

`include "reg_model.sv"

class sequencer_channel extends uvm_sequencer #(transaction_channel);
	
	`uvm_component_utils(sequencer_channel)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass

class sequencer_bus extends uvm_sequencer #(transaction_bus);
	
	`uvm_component_utils(sequencer_bus)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass

class sequencer_formatter extends uvm_sequencer #(transaction_formatter);
	
	`uvm_component_utils(sequencer_formatter)
	function new(string name = "sequencer_formatter", uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass

class virtual_sqr extends uvm_sequencer;
    sequencer_bus reg_sqr;
    sequencer_formatter fmt_sqr;
    sequencer_channel chnl_sqrs[3];
    reg_model_mcdf p_rm;

	`uvm_component_utils(virtual_sqr)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass

`endif

