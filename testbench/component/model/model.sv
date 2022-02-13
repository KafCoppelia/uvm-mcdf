`ifndef _MODEL_SV
`define _MODEL_SV

`include "param_def.v"

`uvm_blocking_put_imp_decl(_chnl0)
`uvm_blocking_put_imp_decl(_chnl1)
`uvm_blocking_put_imp_decl(_chnl2)

// reference model for MCDF
class model_mcdf extends uvm_component;
    local virtual interface_mcdf vif;
    reg_model_mcdf p_rm;

    uvm_blocking_put_imp_chnl0 #(mon_data_t, model_mcdf) chnl0_bp_imp;
    uvm_blocking_put_imp_chnl1 #(mon_data_t, model_mcdf) chnl1_bp_imp;
    uvm_blocking_put_imp_chnl2 #(mon_data_t, model_mcdf) chnl2_bp_imp;
	uvm_tlm_fifo #(transaction_formater) out_tlm_fifos[3];

    // storage the data form 3 channel monitor and reg monitor
    mailbox #(mon_data_t) chnl_mbs[3];

	`uvm_component_utils(model_mcdf);
	function new(string name = "model_mcdf", uvm_component parent);
	    super.new(name, parent);
    endfunction
	
    function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_mcdf)::get(this, "", "vif", vif))
            `uvm_fatal("model_mcdf", "virtual interface must be set for vif!!!");

        chnl0_bp_imp = new("chnl0_bp_imp", this);
        chnl1_bp_imp = new("chnl1_bp_imp", this);
        chnl2_bp_imp = new("chnl2_bp_imp", this);
        foreach(chnl_mbs[i]) chnl_mbs[i] = new();

        foreach(out_tlm_fifos[i])
            out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
    endfunction
	
    virtual task run_phase(uvm_phase phase);
        fork
            do_reset();
            do_packet(0);
            do_packet(1);
            do_packet(2);
        join
    endtask

    task put_chnl0(mon_data_t tr);
        chnl_mbs[0].put(tr);
    endtask
    task put_chnl1(mon_data_t tr);
        chnl_mbs[1].put(tr);
    endtask
    task put_chnl2(mon_data_t tr);
        chnl_mbs[2].put(tr);
    endtask

	extern task do_reset();
	extern task do_packet(int id);
	extern function int get_data_pload_length(int ch_id);

endclass

task model_mcdf::do_packet(int id);
    mon_data_t in_tr;
    transaction_formater out_tr;
    forever begin
        this.chnl_mbs[id].peek(in_tr);
        out_tr = new("fmt_tr");
        out_tr.length = get_data_pload_length(id);
        out_tr.data = new[out_tr.length];
        out_tr.ch_id = id;
        foreach(out_tr.data[m]) begin
            this.chnl_mbs[id].get(in_tr);
            out_tr.data[m] = in_tr.data;
        end
        this.out_tlm_fifos[id].put(out_tr);
    end
endtask

function int model_mcdf::get_data_pload_length(int ch_id);
    bit [31:0] reg_value;
    case(ch_id)
        0: begin
            reg_value = p_rm.chnl0_ctrl_reg.get();
            return (4 << (reg_value[5:3])) ;
        end
        1: begin
            reg_value = p_rm.chnl1_ctrl_reg.get();
            return (4 << (reg_value[5:3])) ;
        end
        2: begin
            reg_value = p_rm.chnl2_ctrl_reg.get();
            return (4 << (reg_value[5:3])) ;
        end
        default: return 0;
    endcase
endfunction

task model_mcdf::do_reset();
    forever begin
        @(negedge vif.rstn);
        p_rm.chnl0_ctrl_reg.predict(32'h07);
        p_rm.chnl1_ctrl_reg.predict(32'h07);
        p_rm.chnl2_ctrl_reg.predict(32'h07);
    end
endtask

`endif

