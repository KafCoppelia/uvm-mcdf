`ifndef _CASE0_SV
`define _CASE0_SV

/*class case0_sequence extends uvm_sequence #(my_transaction);
	my_transaction m_trans;

	`uvm_object_utils(case0_sequence)
	function new(string name = "case0_sequence");
		super.new(name);
	endfunction

	virtual task body();
        repeat(5) begin
		    // `uvm_info("case0_sequence", "send one transaction to sequencer", UVM_MEDIUM)
			`uvm_do(m_trans)
		end
		#1000;
	endtask
endclass */

// -- virtual sequence for case0
class case0_vseq extends uvm_sequence;
	`uvm_object_utils(case0_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case0_vseq");
		super.new(name);
	endfunction
	virtual task body();
        sequence_channel chnl_seq;
        sequence_formater fmt_seq;

		if(starting_phase != null)
			starting_phase.raise_objection(this);
        
        #100;
        `uvm_info("case0_vseq", "sequence will create", UVM_LOW);
        fork
		    `uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[0], {ntrans == 20;});
		    `uvm_do_on(fmt_seq, p_sequencer.fmt_sqr);
		join
        #500;
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask
	
	
endclass 
 
/*
class case0_bus_sequence extends uvm_sequence #(my_transaction);
	transaction_bus m_trans;

	function new(string name = "case0_bus_sequence");
		super.new(name);
	endfunction

	virtual task body();
		if(starting_phase != null)
			starting_phase.raise_objection(this);
        
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_RD;});
        `uvm_info("case0_bus_sequencee", $sformatf("invert's initial value is %0h", m_trans.rd_data), UVM_MEDIUM)
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_WR;
                                m_trans.wr_data == 16'h1;});
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_RD;});
        `uvm_info("case0_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_WR;
                                m_trans.wr_data == 16'h0;});
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_RD;});
        `uvm_info("case0_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_WR;
                                m_trans.wr_data == 16'h1;});
		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
                                m_trans.bus_op == BUS_RD;});
        `uvm_info("case0_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)

		#1000;
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask
	
	`uvm_object_utils(case0_bus_sequence)
	
endclass 

// -- virtual sequence for case0 register model
class case0_cfg_vseq extends uvm_sequence;
	`uvm_object_utils(case0_cfg_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

	function new(string name = "case0_cfg_vseq");
		super.new(name);
	endfunction
	virtual task body();
        case0_bus_sequence bus_seq;

		if(starting_phase != null)
			starting_phase.raise_objection(this);
        
        #1000;
        
		`uvm_do_on(bus_seq, p_sequencer.p_bus_sqr)
		
        #5000;
		if(starting_phase != null)
			starting_phase.drop_objection(this);
	endtask

endclass 

*/

class case0 extends base_test;
	`uvm_component_utils(case0)
	
	function new(string name = "case0", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
        /* 1. use default_sequence */
		// uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.configure_phase", "default_sequence", case0_cfg_vseq::type_id::get());
		uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence", case0_vseq::type_id::get());

	endfunction
	
endclass

	
`endif


