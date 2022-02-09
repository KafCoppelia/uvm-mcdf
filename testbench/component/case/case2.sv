// `ifndef _CASE2_SV
// `define _CASE2_SV

// class case2_sequence extends uvm_sequence #(transaction_dut);
// 	transaction_dut m_trans;

// 	`uvm_object_utils(case2_sequence)
// 	function new(string name = "case2_sequence");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
//         repeat(5) begin
// 		    // `uvm_info("case2_sequence", "send one transaction to sequencer", UVM_MEDIUM)
// 			`uvm_do(m_trans)
// 		end
// 		#1000;
// 	endtask
// endclass

// // -- virtual sequence for case2
// class case2_vseq extends uvm_sequence;
// 	`uvm_object_utils(case2_vseq)
//     `uvm_declare_p_sequencer(virtual_sequencer)

// 	function new(string name = "case2_vseq");
// 		super.new(name);
// 	endfunction
// 	virtual task body();
//         case2_sequence dut_seq;
//         uvm_status_e status;
//         uvm_reg_data_t value;

// 		if(starting_phase != null)
// 			starting_phase.raise_objection(this);
        
//      //    #1000;
//         p_sequencer.p_rm.counter.mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR);
        
//         p_sequencer.p_rm.counter.peek(status, value);
//         `uvm_info("case2_vseq", $sformatf("counter's value is %0h", value), UVM_LOW);

// 		#100000;
// 		`uvm_do_on(dut_seq, p_sequencer.p_dut_sqr)
		
//         if(starting_phase != null)
// 			starting_phase.drop_objection(this);
// 	endtask
	
	
// endclass 
 
// class case2_bus_sequence extends uvm_sequence #(transaction_bus);
// 	transaction_bus m_trans;

// 	function new(string name = "case2_bus_sequence");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
// 		if(starting_phase != null)
// 			starting_phase.raise_objection(this);
        
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_RD;});
//         `uvm_info("case2_bus_sequencee", $sformatf("invert's initial value is %0h", m_trans.rd_data), UVM_MEDIUM)
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_WR;
//                                 m_trans.wr_data == 16'h1;});
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_RD;});
//         `uvm_info("case2_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_WR;
//                                 m_trans.wr_data == 16'h0;});
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_RD;});
//         `uvm_info("case2_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_WR;
//                                 m_trans.wr_data == 16'h1;});
// 		`uvm_do_with(m_trans, { m_trans.addr == 16'h9;
//                                 m_trans.bus_op == BUS_RD;});
//         `uvm_info("case2_bus_sequencee", $sformatf("after set, invert's value is %0h", m_trans.rd_data), UVM_MEDIUM)

// 		#1000;
// 		if(starting_phase != null)
// 			starting_phase.drop_objection(this);
// 	endtask
	
// 	`uvm_object_utils(case2_bus_sequence)
	
// endclass 

// // -- virtual sequence for case2 register model
// class case2_cfg_vseq extends uvm_sequence;
// 	`uvm_object_utils(case2_cfg_vseq)
//     `uvm_declare_p_sequencer(virtual_sequencer)

// 	function new(string name = "case2_cfg_vseq");
// 		super.new(name);
// 	endfunction
// 	virtual task body();
//         uvm_status_e status;
//         uvm_reg_data_t value;
//         uvm_reg_mem_hdl_paths_seq ckseq;
// //      bit[31:0] counter;

// 		if(starting_phase != null)
// 			starting_phase.raise_objection(this);
        
//         #1000;
//         ckseq = new("ckseq");
//         ckseq.model = p_sequencer.p_rm;
//         ckseq.start(null);

//         p_sequencer.p_rm.invert.set(16'h1);
//         value = p_sequencer.p_rm.invert.get();
//         `uvm_info("case2_cfg_vseq", $sformatf("invert's desired value is %0h", value), UVM_LOW)
        
//         value = p_sequencer.p_rm.invert.get_mirrored_value();
//         `uvm_info("case2_cfg_vseq", $sformatf("invert's mirrored value is %0h", value), UVM_LOW)
        
//         p_sequencer.p_rm.invert.update(status, UVM_FRONTDOOR);
//         value = p_sequencer.p_rm.invert.get();
//         `uvm_info("case2_cfg_vseq", $sformatf("invert's desired value is %0h", value), UVM_LOW)
//         value = p_sequencer.p_rm.invert.get_mirrored_value();
//         `uvm_info("case2_cfg_vseq", $sformatf("invert's mirrored value is %0h", value), UVM_LOW)
//         p_sequencer.p_rm.invert.peek(status, value);
//         `uvm_info("case2_cfg_vseq", $sformatf("invert's actual value is %0h", value), UVM_LOW)

// /*        p_sequencer.p_rm.counter.read(status, value, UVM_FRONTDOOR);
//         `uvm_info("case2_cfg_vseq", $sformatf("counter's initial value(FRONTDOOR) is %0h", value), UVM_LOW)
        
//         p_sequencer.p_rm.counter.poke(status, 32'h1_fffd);
//         p_sequencer.p_rm.counter.read(status, value, UVM_FRONTDOOR);
//         `uvm_info("case2_cfg_vseq", $sformatf("after poke, counter's value(FRONTDOOR) is %0h", value), UVM_LOW)

//         p_sequencer.p_rm.counter.peek(status, value);
//         `uvm_info("case2_cfg_vseq", $sformatf("after poke, counter's value(BACKDOOR) is %0h", value), UVM_LOW)
// */
// /*        p_sequencer.p_rm.counter_low.poke(status, 16'hfffd);
//         p_sequencer.p_rm.counter_low.read(status, value, UVM_FRONTDOOR);
//         counter[15:0] = value[15:0];
//         p_sequencer.p_rm.counter_high.read(status, value, UVM_FRONTDOOR);
//         counter[31:16] = value[15:0];
//         `uvm_info("case2_cfg_vseq", $sformatf("after poke, counter's value(FRONTDOOR) is %0h", counter), UVM_LOW)

//         p_sequencer.p_rm.counter_low.peek(status, value);
//         counter[15:0] = value[15:0];
//         p_sequencer.p_rm.counter_high.peek(status, value);
//         counter[31:16] = value[15:0];
//         `uvm_info("case2_cfg_vseq", $sformatf("after poke, counter's value(BACKDOOR) is %0h", counter), UVM_LOW)
// */
// //		`uvm_do_on(bus_seq, p_sequencer.p_bus_sqr)
		
//         #5000;
// 		if(starting_phase != null)
// 			starting_phase.drop_objection(this);
// 	endtask

// endclass 


// class case2 extends base_test;
//     virtual interface_backdoor vif;

//     `uvm_component_utils(case2)
// 	function new(string name = "case2", uvm_component parent = null);
// 		super.new(name, parent);
// 	endfunction
	
// 	virtual function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
		
//         /* 1. use default_sequence */
// 		uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.configure_phase", "default_sequence", case2_cfg_vseq::type_id::get());
// 		uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence", case2_vseq::type_id::get());
// 	 	uvm_config_db #(virtual interface_backdoor)::get(this, "", "vif", vif);
	
//     endfunction
	
//     virtual task pre_main_phase(uvm_phase phase);
//         phase.raise_objection(this);
//         // @(vif.rst_n);
//         vif.poke_counter(32'hFFFD);
//         phase.drop_objection(this);
//     endtask
    
//     virtual task post_main_phase(uvm_phase phase);
//         uvm_status_e status;
//         bit[31:0] counter;
        
//         phase.raise_objection(this);
        
// /*        vif.poke_counter(32'hFD);
//         #200;
//         // rm.counter.write(status, 16'h55, UVM_FRONTDOOR);

//         counter = rm.counter.get_mirrored_value();
//         `uvm_info(get_type_name(), $sformatf("counter's mirrored value is %0h ", counter), UVM_LOW);
// */  
//         rm.counter.mirror(status, UVM_CHECK, UVM_FRONTDOOR);
// /*
//         counter = rm.counter.get_mirrored_value();
//         `uvm_info(get_type_name(), $sformatf("after mirror, counter's mirrored value is %0h ", counter), UVM_LOW);
//   */      
//         phase.drop_objection(this);
//     endtask
// endclass

// `endif

 
