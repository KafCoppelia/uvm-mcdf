`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "interface.sv"

module tb_top;

    logic         clk;
    logic         rstn;

    interface_channel chnl0_if(.*);
    interface_channel chnl1_if(.*);
    interface_channel chnl2_if(.*);
    interface_bus  reg_if(.*);
    interface_formater fmt_if(.*);
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
        uvm_config_db#(virtual interface_formater)::set(uvm_root::get(), "uvm_test_top.env.fmt_agt.drv", "vif", fmt_if);
        uvm_config_db#(virtual interface_formater)::set(uvm_root::get(), "uvm_test_top.env.fmt_agt.mon", "vif", fmt_if);
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(), "uvm_test_top.env.mdl", "vif", mcdf_if);
        uvm_config_db#(virtual interface_mcdf)::set(uvm_root::get(), "uvm_test_top.env.scb", "mcdf_vif", mcdf_if);      
        uvm_config_db#(virtual interface_arbiter)::set(uvm_root::get(), "uvm_test_top.env.scb", "arb_vif", arb_if);
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


`ifdef DUMP_FSDB
    initial begin 
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(2, tb_top, "+all");
    end 
`endif 


endmodule
