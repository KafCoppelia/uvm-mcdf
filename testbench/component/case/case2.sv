`ifndef _CASE2_SV
`define _CASE2_SV

// -- virtual sequence for data channel and formatter
// full rand test
class case2_vseq extends uvm_sequence;
    sequence_channel chnl_seq;
    sequence_formatter fmt_seq;

    `uvm_object_utils(case2_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

    function new(string name = "case2_vseq");
        super.new(name);
    endfunction
    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);
        #100;
        `uvm_info("case2_vseq", "sequence will create", UVM_HIGH);

        // set the sequence send to formatter, fmt_seq doesn't consume time
        `uvm_do_on_with(fmt_seq, p_sequencer.fmt_sqr, {fifo inside {SHORT_FIFO, ULTRA_FIFO}; bandwidth inside {LOW_WIDTH, ULTRA_WIDTH}; } );
        
        fork
            begin
                `uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[0], {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32}; });
                #500;
            end
            begin
                `uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[1], {ntrans inside {[400:600]}; ch_id==1; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32}; });
                #500;
            end
            begin
                `uvm_do_on_with(chnl_seq, p_sequencer.chnl_sqrs[2], {ntrans inside {[400:600]}; ch_id==2; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32}; });
                #500;
            end
        join
        
        #10us;   // wait untill all data have been transfered through MCDF        
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass 
 
// -- virtual sequence for register
  //Follow the instructions below
  //  -reset the register block
  //  -set all value of WR registers via uvm_reg::set()
  //  -update them via uvm_reg_block::update()
  //  -compare the register value via uvm_reg::mirror() with backdoor access
class case2_cfg_vseq extends uvm_sequence;
    sequence_bus reg_seq;

    `uvm_object_utils(case2_cfg_vseq)
    `uvm_declare_p_sequencer(virtual_sqr)

    function new(string name = "case2_cfg_vseq");
        super.new(name);
    endfunction
    virtual task body();
        uvm_status_e status;
        uvm_reg_data_t ch0_wr_val, ch1_wr_val, ch2_wr_val;
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        //reset the register block
        p_sequencer.p_rm.reset();

        //slv0 with len={4,8,16,32},  prio={[0:3]}, en={[0:1]}
        ch0_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
        ch1_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
        ch2_wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);

        //set all value of WR registers via uvm_reg::set() 
        p_sequencer.p_rm.chnl0_ctrl_reg.set(ch0_wr_val);
        //update them via uvm_reg_block::update()
        p_sequencer.p_rm.update(status, UVM_FRONTDOOR);
        p_sequencer.p_rm.chnl1_ctrl_reg.set(ch1_wr_val);
        p_sequencer.p_rm.update(status, UVM_FRONTDOOR);
        p_sequencer.p_rm.chnl2_ctrl_reg.set(ch2_wr_val);
        p_sequencer.p_rm.update(status, UVM_FRONTDOOR);

        //wait until the registers in DUT have been updated
        #100ns;

        //compare all of write value and read value
        p_sequencer.p_rm.chnl0_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
        p_sequencer.p_rm.chnl1_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
        p_sequencer.p_rm.chnl2_ctrl_reg.mirror(status, UVM_CHECK, UVM_BACKDOOR);
        
        // send IDLE command
        `uvm_do_on_with(reg_seq, p_sequencer.reg_sqr, {cmd==`IDLE; } )
        
        #500;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

endclass 


class case2 extends base_test;
    `uvm_component_utils(case2)
    
    function new(string name = "case2", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.configure_phase", "default_sequence", case2_cfg_vseq::type_id::get());
        uvm_config_db #(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence", case2_vseq::type_id::get());

    endfunction
    
endclass

    
`endif


