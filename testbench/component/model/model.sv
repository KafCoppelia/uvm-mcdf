`ifndef _MODEL_SV
`define _MODEL_SV

`include "param_def.v"

typedef struct packed {
    bit[2:0] len;    
    bit[1:0] prio;    
    bit      en;    
    bit[7:0] avail;    
} mcdf_reg_t;

typedef enum {RW_LEN, RW_PRIO, RW_EN, RD_AVAIL} mcdf_field_t;

`uvm_blocking_put_imp_decl(_chnl0)
`uvm_blocking_put_imp_decl(_chnl1)
`uvm_blocking_put_imp_decl(_chnl2)

// reference model for MCDF
class model_mcdf extends uvm_component;
    local virtual interface_mcdf vif;
	mcdf_reg_t regs[3];

    uvm_blocking_put_imp_chnl0 #(mon_data_t, model_mcdf) chnl0_bp_imp;
    uvm_blocking_put_imp_chnl1 #(mon_data_t, model_mcdf) chnl1_bp_imp;
    uvm_blocking_put_imp_chnl2 #(mon_data_t, model_mcdf) chnl2_bp_imp;
	uvm_blocking_put_imp #(transaction_reg, model_mcdf) reg_bp_imp;

    // storage the data form 3 channel monitor and reg monitor
    mailbox #(mon_data_t) chnl_mbs[3];
    mailbox #(transaction_reg) reg_mb;

	uvm_tlm_fifo #(transaction_fmt) out_tlm_fifos[3];

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
	    reg_bp_imp = new("reg_bp_imp", this);

        foreach(chnl_mbs[i]) chnl_mbs[i] = new();
        reg_mb = new();

        foreach(out_tlm_fifos[i])
            out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
    endfunction
	
    virtual task run_phase(uvm_phase phase);
        fork
            do_reset();
            this.do_reg_update();
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
    task put(transaction_reg tr);
        reg_mb.put(tr);
    endtask

	extern task do_reset();
	extern task do_reg_update();
	extern task do_packet(int id);
	extern function int get_field_value(int id, mcdf_field_t f);

endclass

task model_mcdf::do_reg_update();
    transaction_reg tr;
    forever begin
        this.reg_mb.get(tr);
        if(tr.addr[7:4] == 0 && tr.cmd == `WRITE) begin
            this.regs[tr.addr[3:2]].en = tr.data[0];
            this.regs[tr.addr[3:2]].prio = tr.data[2:1];
            this.regs[tr.addr[3:2]].len = tr.data[5:3];
        end
        else if(tr.addr[7:4] == 1 && tr.cmd == `READ) begin
            this.regs[tr.addr[3:2]].avail = tr.data[7:0];
        end
    end
endtask

task model_mcdf::do_packet(int id);
    mon_data_t in_tr;
    transaction_fmt out_tr;
    forever begin
        this.chnl_mbs[id].peek(in_tr);
        out_tr = new("fmt_tr");
        out_tr.length = 4 << (this.get_field_value(id, RW_LEN) & 'b11);
        out_tr.data = new[out_tr.length];
        out_tr.ch_id = id;
        foreach(out_tr.data[m]) begin
            this.chnl_mbs[id].get(in_tr);
            out_tr.data[m] = in_tr.data;
        end
        this.out_tlm_fifos[id].put(out_tr);
    end
endtask

function int model_mcdf::get_field_value(int id, mcdf_field_t f);
    case(f)
        RW_LEN: return regs[id].len;
        RW_PRIO: return regs[id].prio;
        RW_EN: return regs[id].en;
        RD_AVAIL: return regs[id].avail;
    endcase
endfunction

task model_mcdf::do_reset();
    forever begin
        @(negedge vif.rstn);
        foreach(regs[i]) begin
            regs[i].len = 'h0;
            regs[i].prio = 'h3;
            regs[i].en = 'h1;
            regs[i].avail = 'h20;
        end
    end
endtask

`endif

