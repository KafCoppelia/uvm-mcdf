`ifndef MY_ENV_SV
`define MY_ENV_SV

// top environment for MCDF
class env_mcdf extends uvm_env;
	agent_chnl chnl_agts[3];
	agent_reg reg_agt;
    agent_fmt fmt_agt;
	model_mcdf mdl;
	scoreboard_mcdf scb;
    reg_model rm;
    adapter adapter;
    uvm_reg_predictor #(transaction_reg) predictor;

    // coverage_mcdf cvrg;

	`uvm_component_utils(env_mcdf)
	function new(string name = "env_mcdf", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        foreach(chnl_agts[i]) begin
            chnl_agts[i] = agent_chnl::type_id::create($sformatf("chnl_agts[%0d]", i), this);
		    chnl_agts[i].is_active = UVM_ACTIVE;
        end
		reg_agt = agent_reg::type_id::create("reg_agt", this);
		reg_agt.is_active = UVM_ACTIVE;
        fmt_agt = agent_fmt::type_id::create("fmt_agt", this);
        fmt_agt.is_active = UVM_ACTIVE;
		mdl = model_mcdf::type_id::create("mdl", this);
		scb = scoreboard_mcdf::type_id::create("scb", this);
        
        // rm = reg_model::type_id::create("rm", this);
        // rm.build();
        // adapter = adapter::type_id::create("adapter", this);
        // predictor = uvm_reg_predictor#(transaction_reg)::type_id::create("predictor", this);
             
        // cvrg = coverage_mcdf::type_id::create("cvrg", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);	
        super.connect_phase(phase);
        chnl_agts[0].mon.mon_bp_port.connect(mdl.chnl0_bp_imp);
        chnl_agts[1].mon.mon_bp_port.connect(mdl.chnl1_bp_imp);
        chnl_agts[2].mon.mon_bp_port.connect(mdl.chnl2_bp_imp);
        reg_agt.mon.mon_bp_port.connect(mdl.reg_bp_imp);
        fmt_agt.mon.mon_bp_port.connect(scb.fmt_bp_imp);
        
        foreach(scb.scb_bg_ports[i])
            scb.scb_bg_ports[i].connect(mdl.out_tlm_fifos[i].blocking_get_export);
        // mdl.p_rm = this.p_rm;
        // mdl.p_sqr = bus_agt.sqr;

    endfunction

endclass

`endif

