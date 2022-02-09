`ifndef MY_SEQUENCE_SV_
`define MY_SEQUENCE_SV_

class sequence_chnl extends uvm_sequence #(transaction_chnl);
	rand int pkt_id = 0;
	rand int ch_id = -1;
	rand int data_nidles = -1;
	rand int pkt_nidles = -1;
	rand int data_size = -1;
	rand int ntrans = 10;

    `uvm_object_utils_begin(sequence_chnl)
        `uvm_field_int( pkt_id ,       UVM_ALL_ON )
        `uvm_field_int( ch_id ,        UVM_ALL_ON )
        `uvm_field_int( data_nidles ,  UVM_ALL_ON )
        `uvm_field_int( pkt_nidles ,   UVM_ALL_ON )
        `uvm_field_int( data_size ,    UVM_ALL_ON )
        `uvm_field_int( ntrans ,       UVM_ALL_ON )
    `uvm_object_utils_end

	function new(string name = "sequence_chnl");
		super.new(name);
	endfunction

    `uvm_declare_p_sequencer(sequencer_chnl)

	constraint cstr{
		soft data_size inside {[4:32]};
        soft ch_id == 0;
        soft pkt_id == 0;
        soft data_nidles inside {[0:2]};
        soft pkt_nidles inside {[1:10]};
        soft ntrans inside {[5:10]};
	}

	virtual task body();
	    
        `uvm_info("sequence_chnl", $sformatf("sequence_chnl body will run %d transaction.", ntrans), UVM_LOW); 

        repeat(ntrans) begin
        // repeat(5) begin
            transaction_chnl m_trans, rsp;
			`uvm_do_with(m_trans, { ch_id == local::ch_id;
                                    pkt_id == local::pkt_id;
                                    data_nidles == local::data_nidles;
                                    pkt_nidles == local::pkt_nidles;
                                    data.size() == local::data_size;
                                    })
            this.pkt_id++;
            `uvm_info("sequence_chnl", {"m_trans: \n", m_trans.sprint()}, UVM_HIGH)
            get_response(rsp);
            `uvm_info("sequence_chnl", {"rsp: \n", rsp.sprint()}, UVM_HIGH)
            assert(rsp.rsp)
                else $error("[RSPERR] %0t error response received!", $time);
		end
	endtask

    function void post_randomize();
        string s;
        s = {s, "After randomization \n"};
        s = {s, "=========================================\n"};
        s = {s, "sequence_chnl object content is as below: \n"};
        s = {s, super.sprint()};
        s = {s, "=========================================\n"};
        `uvm_info("sequence_chnl", s, UVM_HIGH)
    endfunction
endclass

class sequence_reg extends uvm_sequence #(transaction_reg);
	rand bit[7:0] addr = 0;
	rand bit[1:0] cmd = 0;
	rand bit[31:0] data = 0;
    
    `uvm_object_utils_begin(sequence_reg)
        `uvm_field_int( addr ,  UVM_ALL_ON )
        `uvm_field_int( cmd ,   UVM_ALL_ON )
        `uvm_field_int( data ,  UVM_ALL_ON )
    `uvm_object_utils_end

	function new(string name = "sequence_reg");
		super.new(name);
	endfunction

    `uvm_declare_p_sequencer(sequencer_reg)

	virtual task body();
		transaction_reg m_trans, rsp;
		`uvm_do_with(m_trans, { addr == local::addr;
                                cmd == local::cmd;
                                data == local::data;
                                })
        `uvm_info("sequence_reg", m_trans.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info("sequence_reg", rsp.sprint(), UVM_HIGH)
        if(req.cmd == `READ)
            this.data = rsp.data;
        assert(rsp.rsp)
            else $error("[RSPERR] %0t error response received!", $time);
		
    endtask

    function void post_randomize();
        string s;
        s = {s, "After randomization \n"};
        s = {s, "=========================================\n"};
        s = {s, "sequence_reg object content is as below: \n"};
        s = {s, super.sprint()};
        s = {s, "=========================================\n"};
        `uvm_info("sequence_chnl", s, UVM_HIGH)
    endfunction
endclass

class sequence_fmt extends uvm_sequence #(transaction_fmt);
    rand fmt_fifo_t fifo = MED_FIFO;
    rand fmt_bandwidth_t bandwidth = MED_WIDTH;
    
    constraint cstr{
        soft fifo == MED_FIFO;
        soft bandwidth == MED_WIDTH;
    }
    
    `uvm_object_utils_begin(sequence_fmt)
        `uvm_field_enum( fmt_fifo_t, fifo, UVM_ALL_ON )
        `uvm_field_enum( fmt_bandwidth_t, bandwidth, UVM_ALL_ON )
    `uvm_object_utils_end

	function new(string name = "sequence_fmt");
		super.new(name);
	endfunction

    `uvm_declare_p_sequencer(sequencer_fmt)

	virtual task body();
        transaction_fmt m_trans, rsp;
		`uvm_do_with(m_trans, { fifo == local::fifo;
                                bandwidth == local::bandwidth;
                                })
        `uvm_info("sequence_fmt", m_trans.sprint(), UVM_HIGH)
        get_response(rsp);
        `uvm_info("sequence_fmt", rsp.sprint(), UVM_HIGH)
        assert(rsp.rsp)
            else $error("[RSPERR] %0t error response received!", $time);
	endtask

    function void post_randomize();
        string s;
        s = {s, "After randomization \n"};
        s = {s, "=========================================\n"};
        s = {s, "sequence_fmt object content is as below: \n"};
        s = {s, super.sprint()};
        s = {s, "=========================================\n"};
        `uvm_info("sequence_chnl", s, UVM_HIGH)
    endfunction
endclass

`endif


