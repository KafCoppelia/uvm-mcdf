`ifndef _BASE_TEST_SV
`define _BASE_TEST_SV

class base_test extends uvm_test;
	env_mcdf env;
    virtual_sqr v_sqr;
    // reg_model rm;
    // adapter reg_sqr_adapter;

	function new(string name = "base_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);

	`uvm_component_utils(base_test)

endclass

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = env_mcdf::type_id::create("env", this);
    v_sqr = virtual_sqr::type_id::create("v_sqr", this);
/*    rm = reg_model::type_id::create("rm", this);
    rm.configure(null, "");
    rm.build();
    rm.lock_model();
    rm.reset();
    reg_sqr_adapter = new("reg_sqr_adapter");
*/
// env.p_rm = this.rm;

endfunction

function void base_test::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
    foreach(v_sqr.chnl_sqrs[i])
        v_sqr.chnl_sqrs[i] = env.chnl_agts[i].sqr;
    v_sqr.reg_sqr = env.reg_agt.sqr;
    v_sqr.fmt_sqr = env.fmt_agt.sqr;
	// v_sqr.p_rm = this.rm;
/*    rm.default_map.set_sequencer(env.bus_agt.sqr, reg_sqr_adapter);
    rm.default_map.set_auto_predict(1);
*/
endfunction

function void base_test::report_phase(uvm_phase phase);
	uvm_report_server server;
    integer fid;
	int err_num;
    string test_name;
	super.report_phase(phase);
    
    if(get_report_verbosity_level() >= UVM_HIGH ) begin 
	    uvm_top.print_topology();
    end

    server = get_report_server();
	err_num = server.get_severity_count(UVM_ERROR);
   	test_name = get_type_name();
    $display("test_name: %s", test_name);

    fid = $fopen("result.log","a");

    if( err_num != 0 ) begin
		$display("----------------------------------------");
		$display("--         TEST CASE FAIlED !!!!!!");
		$display("has %0d error(s).", err_num);
        $display("!!!!!!!!!!!!!!!!!!");
		$fwrite( fid,$sformatf("FAILED:%s\n", test_name) );
	end else begin
		$display("----------------------------------------");
		$display("--         TEST CASE PASSED           --");
		$display("----------------------------------------");
		$fwrite( fid,$sformatf("PASSED:%s\n", test_name) );
	end


endfunction

`endif 


 
