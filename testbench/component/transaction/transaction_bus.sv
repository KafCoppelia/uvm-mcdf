`ifndef TRANSACTION_BUS_SV
`define TRANSACTION_BUS_SV

// transaction for register
class transaction_bus extends uvm_sequence_item;
	rand bit[7:0] addr;
	rand bit[1:0] cmd;
	rand bit[31:0] data;
    bit rsp;
    
	`uvm_object_utils_begin(transaction_bus)
		`uvm_field_int(data, UVM_ALL_ON);
		`uvm_field_int(cmd, UVM_ALL_ON);
		`uvm_field_int(addr, UVM_ALL_ON);
		`uvm_field_int(rsp, UVM_ALL_ON);
	`uvm_object_utils_end

	function new(string name = "transaction_bus");
		super.new(name);
	endfunction

endclass

`endif

