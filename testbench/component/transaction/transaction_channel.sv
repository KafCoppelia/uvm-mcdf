`ifndef TRANSACTION_CHANNEL_SV
`define TRANSACTION_CHANNEL_SV

// transaction for one slave fifo channel
class transaction_channel extends uvm_sequence_item;
    rand bit[31:0] data[];
	rand int ch_id;
	rand int pkt_id;
	rand int data_nidles;
	rand int pkt_nidles;

    bit rsp = 0;

	constraint cstr{
		soft data.size inside {[4:32]};
        foreach(data[i]) data[i] == 'hc000_0000 + (this.ch_id<<24) + (this.pkt_id<<8) + i;
        soft ch_id == 0;
        soft pkt_id == 0;
        soft data_nidles inside {[0:2]};
        pkt_nidles inside {[1:100]};
	}

	`uvm_object_utils_begin(transaction_channel)
		`uvm_field_array_int(data, UVM_ALL_ON);
		`uvm_field_int(ch_id, UVM_ALL_ON);
		`uvm_field_int(pkt_id, UVM_ALL_ON);
		`uvm_field_int(data_nidles, UVM_ALL_ON);
		`uvm_field_int(pkt_nidles, UVM_ALL_ON);
		`uvm_field_int(rsp, UVM_ALL_ON);
	`uvm_object_utils_end

	function new(string name = "transaction_channel");
		super.new(name);
	endfunction

endclass

`endif

