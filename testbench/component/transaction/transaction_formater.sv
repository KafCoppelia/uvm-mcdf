`ifndef TRANSACTION_FORMATER_SV
`define TRANSACTION_FORMATER_SV

typedef enum {SHORT_FIFO, MED_FIFO, LONG_FIFO, ULTRA_FIFO} fmt_fifo_t;
typedef enum {LOW_WIDTH, MED_WIDTH, HIGH_WIDTH, ULTRA_WIDTH} fmt_bandwidth_t;

class transaction_formater extends uvm_sequence_item;
	rand fmt_fifo_t fifo;
    rand fmt_bandwidth_t bandwidth;
	bit[9:0] length;
	bit[31:0] data[];
	bit[1:0] ch_id;
	bit rsp;

	constraint cstr{
		soft fifo == MED_FIFO;
		soft bandwidth == MED_WIDTH;
	}

	`uvm_object_utils_begin(transaction_formater)
		`uvm_field_enum(fmt_fifo_t, fifo, UVM_ALL_ON);
		`uvm_field_enum(fmt_bandwidth_t, bandwidth, UVM_ALL_ON);
		`uvm_field_int(length, UVM_ALL_ON);
		`uvm_field_array_int(data, UVM_ALL_ON);
		`uvm_field_int(ch_id, UVM_ALL_ON);
		`uvm_field_int(rsp, UVM_ALL_ON);
	`uvm_object_utils_end

	function new(string name = "transaction_formater");
		super.new(name);
	endfunction

endclass

`endif

