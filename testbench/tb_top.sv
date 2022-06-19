`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "interface.sv"

`include "case0.sv"
`include "case1.sv"
`include "case2.sv"

module tb_top;

    logic         clk;
    logic         rstn;

    interface_channel chnl0_if(.*);
    interface_channel chnl1_if(.*);
    interface_channel chnl2_if(.*);
    interface_bus  reg_if(.*);
    interface_formatter fmt_if(.*);
    interface_mcdf mcdf_if(.*);
    interface_arbiter  arb_if(.*);
  
    mcdf dut(
        .clk_i       (clk                ),
        .rstn_i      (rstn               ),
        .cmd_i       (reg_if.cmd         ), 
        .cmd_addr_i  (reg_if.cmd_addr    ), 
        .cmd_data_i  (reg_if.cmd_data_w  ),  
        .cmd_data_o  (reg_if.cmd_data_r  ),  
        .ch0_data_i  (chnl0_if.ch_data   ),
        .ch0_vld_i   (chnl0_if.ch_valid  ),
        .ch0_ready_o (chnl0_if.ch_ready  ),
        .ch1_data_i  (chnl1_if.ch_data   ),
        .ch1_vld_i   (chnl1_if.ch_valid  ),
        .ch1_ready_o (chnl1_if.ch_ready  ),
        .ch2_data_i  (chnl2_if.ch_data   ),
        .ch2_vld_i   (chnl2_if.ch_valid  ),
        .ch2_ready_o (chnl2_if.ch_ready  ),
        .fmt_grant_i (fmt_if.fmt_grant   ), 
        .fmt_chid_o  (fmt_if.fmt_chid    ), 
        .fmt_req_o   (fmt_if.fmt_req     ), 
        .fmt_length_o(fmt_if.fmt_length  ),    
        .fmt_data_o  (fmt_if.fmt_data    ),  
        .fmt_start_o (fmt_if.fmt_start   ),  
        .fmt_end_o   (fmt_if.fmt_end     )  
    );

 	// mcdf interface monitoring MCDF ports and signals
 	assign mcdf_if.chnl_en[0] = dut.ctrl_regs_inst.slv0_en_o;
  	assign mcdf_if.chnl_en[1] = dut.ctrl_regs_inst.slv1_en_o;
  	assign mcdf_if.chnl_en[2] = dut.ctrl_regs_inst.slv2_en_o;

  	// arbiter interface monitoring arbiter ports
  	assign arb_if.slv_prios[0] = dut.arbiter_inst.slv0_prio_i;
  	assign arb_if.slv_prios[1] = dut.arbiter_inst.slv1_prio_i;
  	assign arb_if.slv_prios[2] = dut.arbiter_inst.slv2_prio_i;
  	assign arb_if.slv_reqs[0] = dut.arbiter_inst.slv0_req_i;
  	assign arb_if.slv_reqs[1] = dut.arbiter_inst.slv1_req_i;
  	assign arb_if.slv_reqs[2] = dut.arbiter_inst.slv2_req_i;
  	assign arb_if.a2s_acks[0] = dut.arbiter_inst.a2s0_ack_o;
 	assign arb_if.a2s_acks[1] = dut.arbiter_inst.a2s1_ack_o;
  	assign arb_if.a2s_acks[2] = dut.arbiter_inst.a2s2_ack_o;
  	assign arb_if.f2a_id_req = dut.arbiter_inst.f2a_id_req_i;

    initial begin
        // set the format for time display
        $timeformat(-9, 2, "ns", 10); 
        // do interface configuration from tb_top (HW) to verification env (SW)     
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[0].drv", "vif", chnl0_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[1].drv", "vif", chnl1_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[2].drv", "vif", chnl2_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[0].mon", "vif", chnl0_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[1].mon", "vif", chnl1_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[2].mon", "vif", chnl2_if);
        uvm_config_db#(virtual interface_bus)::set(uvm_root::get(), "uvm_test_top.env.reg_agt.drv", "vif", reg_if);
        uvm_config_db#(virtual interface_bus)::set(uvm_root::get(), "uvm_test_top.env.reg_agt.mon", "vif", reg_if);
        uvm_config_db#(virtual interface_formatter)::set(uvm_root::get(), "uvm_test_top.env.fmt_agt.drv", "vif", fmt_if);
        uvm_config_db#(virtual interface_formatter)::set(uvm_root::get(), "uvm_test_top.env.fmt_agt.mon", "vif", fmt_if);
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(), "uvm_test_top.env.mdl", "vif", mcdf_if);
        // set the interface for scoreboard
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(), 	"uvm_test_top.env.scb", "mcdf_vif", mcdf_if);      
        uvm_config_db#(virtual interface_arbiter)::set(uvm_root::get(), "uvm_test_top.env.scb", "arb_vif", 	arb_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(), "uvm_test_top.env.scb", "ch0_vif",  chnl0_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),	"uvm_test_top.env.scb", "ch1_vif",  chnl1_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),	"uvm_test_top.env.scb", "ch2_vif",  chnl2_if);
        // set the interface for coverage
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env.cov", "ch0_vif",  chnl0_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env.cov", "ch1_vif",  chnl1_if);
        uvm_config_db#(virtual interface_channel)::set(uvm_root::get(),     "uvm_test_top.env.cov", "ch2_vif",  chnl2_if);
        uvm_config_db#(virtual interface_bus)::set(uvm_root::get(),         "uvm_test_top.env.cov", "reg_vif",  reg_if);
        uvm_config_db#(virtual interface_formatter)::set(uvm_root::get(),   "uvm_test_top.env.cov", "fmt_vif",  fmt_if);
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(),        "uvm_test_top.env.cov", "mcdf_vif", mcdf_if);      
        uvm_config_db#(virtual interface_arbiter)::set(uvm_root::get(),     "uvm_test_top.env.cov", "arb_vif",  arb_if);
        // start run the test
        run_test();
    end

	// clock generation
    initial begin 
        clk <= 1'b0;
        forever begin
            #5 clk <= !clk;
        end
    end
      
    // reset trigger
    initial begin 
        #10 rstn <= 1'b0;
        repeat(10) @(posedge clk);
        rstn <= 1'b1;
    end


    initial begin 
        string testname;
        if($value$plusargs("TESTNAME=%s", testname)) begin
            $fsdbDumpfile({testname, "_sim_dir/", testname, ".fsdb"});
        end else begin
            $fsdbDumpfile("tb.fsdb");
        end
        $fsdbDumpvars(0, tb_top);
    end

endmodule
