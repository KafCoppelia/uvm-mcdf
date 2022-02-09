class case1_sequence extends uvm_sequence #(transaction_dut);
    transaction_dut m_trans;

    function  new(string name= "case1_sequence");
        super.new(name);
    endfunction 
 
    virtual task body();
        if(starting_phase != null) 
            starting_phase.raise_objection(this);
        repeat (10) begin
            `uvm_do_with(m_trans, { m_trans.pload.size() == 10;})
        end
        #100;
        if(starting_phase != null) 
            starting_phase.drop_objection(this);
    endtask
 
   `uvm_object_utils(case1_sequence)
endclass

class case1 extends base_test;
   
    `uvm_component_utils(case1)
    function new(string name = "case1", uvm_component parent = null);
        super.new(name,parent);
    endfunction 
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);      
    endfunction

    virtual task main_phase(uvm_phase phase);
        /* 2. not use default_sequence */
        case1_sequence seq;
        seq = case1_sequence::type_id::create("seq");
        // set starting_phase for uvm_sequence.body() task
        seq.starting_phase = phase;
        seq.start(env.in_agt.sqr);
    endtask 


endclass


 