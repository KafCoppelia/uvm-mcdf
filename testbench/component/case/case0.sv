`ifndef _CASE0_SV
`define _CASE0_SV

// -- virtual sequence for data channel and formatter
class case0_vseq extends uvm_sequence;
	sequence_channel chnl_seq;
	sequence_formatter fmt_seq;

	`uvm_object_utils(case0_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case0_vseq");
		super.new(name);
	endfunction
	virtual task body();
		if(starting_phase != null)
			starting_phase.raise_objection(this);
        #100;
        `uvm_info("case0_vseq", "sequence will create", UVM_HIGH);

		// set the sequence send to formatter, fmt_seq doesn't consume time
		`uvm_do_on_with(fmt_seq, p_sequencer.fmt_sqr, {fifo==ULTRA_FIFO; bandwidth == ULTRA_WIDTH; } );
        
		fork
			begin
		    	`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[0], {ntrans == 40; ch_id==0; data_nidles==0; pkt_nidles==1; data_size==8; });
                #500;
				`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[1], {ntrans == 20; ch_id==1; data_nidles==0; pkt_nidles==2; data_size==16; });
                #500;
				`uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[2], {ntrans == 10; ch_id==2; data_nidles==0; pkt_nidles==4; data_size==32; });
			end
		join
        
		#5us;   // wait untill all data have been transfered through MCDF        
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask

endclass 
 
// -- virtual sequence for register
class case0_cfg_vseq extends uvm_sequence;
	sequence_bus reg_seq;

	`uvm_object_utils(case0_cfg_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case0_cfg_vseq");
		super.new(name);
	endfunction
	virtual task body();
        uvm_status_e status;
        uvm_reg_data_t value;
		if(starting_phase != null)
			starting_phase.raise_objection(this);
        
        // set all value of control registers via uvm_reg::set()
		p_sequencer.p_rm.chnl0_ctrl_reg.write(status, {26'h00, 3'd0, 2'b00, 1'b1});		// 32'h01
		p_sequencer.p_rm.chnl1_ctrl_reg.write(status, {26'h00, 3'd1, 2'b00, 1'b1});		// 32'h09
		p_sequencer.p_rm.chnl2_ctrl_reg.write(status, {26'h00, 3'd2, 2'b00, 1'b1});		// 32'h11

		// read out the value form register
		p_sequencer.p_rm.chnl0_ctrl_reg.read(status, value);
		`uvm_info("case0_cfg_vseq", $sformatf("after set, chnl0_ctrl_reg's value is %0h", value), UVM_HIGH)
        p_sequencer.p_rm.chnl1_ctrl_reg.read(status, value);
		`uvm_info("case0_cfg_vseq", $sformatf("after set, chnl1_ctrl_reg's value is %0h", value), UVM_HIGH)
        p_sequencer.p_rm.chnl2_ctrl_reg.read(status, value);
		`uvm_info("case0_cfg_vseq", $sformatf("after set, chnl2_ctrl_reg's value is %0h", value), UVM_HIGH)
		
		// send IDLE command
		`uvm_do_on_with(reg_seq, p_sequencer.reg_sqr, {cmd==`IDLE; } )
		
        #500;
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask

endclass 


class case0 extends base_test;
	`uvm_component_utils(case0)
	
	function new(string name = "case0", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
        uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.configure_phase", "default_sequence", case0_cfg_vseq::type_id::get());
		uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence", case0_vseq::type_id::get());

	endfunction
	
endclass

	
`endif


