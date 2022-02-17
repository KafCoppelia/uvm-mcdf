`ifndef _CASE1_SV
`define _CASE1_SV

// -- virtual sequence for data channel and formatter
class case1_vseq extends uvm_sequence;
	sequence_channel chnl_seq;
	sequence_formatter fmt_seq;

	`uvm_object_utils(case1_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case1_vseq");
		super.new(name);
	endfunction
	virtual task body();
		if(starting_phase != null)
			starting_phase.raise_objection(this);
        #100;
        `uvm_info("case1_vseq", "sequence will create", UVM_HIGH);

		// set the sequence send to formatter, fmt_seq doesn't consume time
		`uvm_do_on_with(fmt_seq, p_sequencer.fmt_sqr, {fifo==LONG_FIFO; bandwidth == HIGH_WIDTH; } );
        
		fork
			begin
		    	`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[0], {ntrans == 100; ch_id==0; data_nidles==0; pkt_nidles==1; data_size==8; });
                #500;
            end
            begin
				`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[1], {ntrans == 100; ch_id==1; data_nidles==1; pkt_nidles==4; data_size==16; });
                #500;
            end
            begin
				`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[2], {ntrans == 100; ch_id==2; data_nidles==2; pkt_nidles==8; data_size==32; });
			    #500;
            end
		join
        
		#10us;   // wait untill all data have been transfered through MCDF        
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask

endclass 
 
// -- virtual sequence for register
class case1_cfg_vseq extends uvm_sequence;
	sequence_bus reg_seq;

	`uvm_object_utils(case1_cfg_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case1_cfg_vseq");
		super.new(name);
	endfunction
	virtual task body();
        uvm_status_e status;
        uvm_reg_data_t wr_val, rd_val;
		if(starting_phase != null)
			starting_phase.raise_objection(this);

        // set slv0 ctrl reg with len=8, prio=0, en=1, and then readout to compare
        wr_val = (1<<3) + (0<<1) + 1;
		p_sequencer.p_rm.chnl0_ctrl_reg.write(status, wr_val);
		p_sequencer.p_rm.chnl0_ctrl_reg.read(status, rd_val);
        if( wr_val != rd_val)
            `uvm_error("reg_compare", $sformatf("ERROR! %s write value 0x%8x != read value 0x%8x", "SLV0_CTRL_REG", wr_val, rd_val))

        // set slv1 ctrl reg with len=16, prio=1, en=1, and then readout to compare
        wr_val = (2<<3) + (1<<1) + 1;
		p_sequencer.p_rm.chnl1_ctrl_reg.write(status, wr_val);
		p_sequencer.p_rm.chnl1_ctrl_reg.read(status, rd_val);
        if( wr_val != rd_val)
            `uvm_error("reg_compare", $sformatf("ERROR! %s write value 0x%8x != read value 0x%8x", "SLV1_CTRL_REG", wr_val, rd_val))
        
        // set slv2 ctrl reg with len=32, prio=2, en=1, and then readout to compare
        wr_val = (3<<3) + (3<<1) + 1;
		p_sequencer.p_rm.chnl2_ctrl_reg.write(status, wr_val);
		p_sequencer.p_rm.chnl2_ctrl_reg.read(status, rd_val);
        if( wr_val != rd_val)
            `uvm_error("reg_compare", $sformatf("ERROR! %s write value 0x%8x != read value 0x%8x", "SLV2_CTRL_REG", wr_val, rd_val))

		// send IDLE command
		`uvm_do_on_with(reg_seq, p_sequencer.reg_sqr, {cmd==`IDLE; } )
		
        #500;
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask

endclass 


class case1 extends base_test;
	`uvm_component_utils(case1)
	
	function new(string name = "case1", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
        uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.configure_phase", "default_sequence", case1_cfg_vseq::type_id::get());
		uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence", case1_vseq::type_id::get());

	endfunction
	
endclass

	
`endif

 
