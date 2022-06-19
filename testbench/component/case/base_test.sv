`ifndef _BASE_TEST_SV
`define _BASE_TEST_SV

`include "sequence.sv"
`include "env.sv"

class base_test extends uvm_test;
    env_mcdf env;
    virtual_sqr v_sqr;

    `uvm_component_utils(base_test)
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

endclass

function void base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = env_mcdf::type_id::create("env", this);
    v_sqr = virtual_sqr::type_id::create("v_sqr", this);

endfunction

function void base_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    foreach(v_sqr.chnl_sqrs[i])
        v_sqr.chnl_sqrs[i] = env.chnl_agts[i].sqr;
    v_sqr.reg_sqr = env.reg_agt.sqr;
    v_sqr.fmt_sqr = env.fmt_agt.sqr;
    v_sqr.p_rm = env.rm;
    if(get_report_verbosity_level() >= UVM_HIGH ) begin 
        uvm_top.print_topology();
    end
endfunction

function void base_test::report_phase(uvm_phase phase);
    uvm_report_server server;
    integer fid;
    int err_num;
    string testname;
    $value$plusargs("TESTNAME=%s", testname);
    super.report_phase(phase);

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    $system("date +[%F/%T] >> sim_result.log");
    fid = $fopen("sim_result.log","a");

    if( err_num != 0 ) begin
        $display("==================================================");
        $display("%s TestCase Failed !!!", testname);
        $display("It has %0d error(s).", err_num);
        $display("!!!!!!!!!!!!!!!!!!");
        $fwrite( fid, $sformatf("TestCase Failed: %s\n\n", testname) );
    end else begin
        $display("==================================================");
        $display("TestCase Passed: %s", testname);
        $display("==================================================");
        $fwrite( fid, $sformatf("TestCase Passed: %s\n\n", testname) );
    end

endfunction

`endif 
