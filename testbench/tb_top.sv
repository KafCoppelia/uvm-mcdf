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

    // clock generation
    initial begin 
        clk <= 0;
        forever begin
            #5 clk <= !clk;
        end
    end
      
    // reset trigger
    initial begin 
        #10 rstn <= 0;
        repeat(10) @(posedge clk);
        rstn <= 1;
    end

    initial begin
        // run_test();
    end

    initial begin
        // set the format for time display
        $timeformat(-9, 2, "ns", 10);      
        // do interface configuration from tb_top (HW) to verification env (SW)
        // uvm_config_db # (virtual interface_dut)::set(null, "uvm_test_top.env.in_agt.drv", "vif", input_if);
        // uvm_config_db # (virtual interface_dut)::set(null, "uvm_test_top.env.in_agt.mon", "vif", input_if);
        // uvm_config_db # (virtual interface_dut)::set(null, "uvm_test_top.env.out_agt.mon", "vif", output_if);
        // uvm_config_db # (virtual interface_bus)::set(null, "uvm_test_top.env.bus_agt.drv", "vif", bus_if);
        // uvm_config_db # (virtual interface_bus)::set(null, "uvm_test_top.env.bus_agt.mon", "vif", bus_if);
        // uvm_config_db # (virtual interface_backdoor)::set(null, "uvm_test_top", "vif", bk_if);
        #10000;
        $display("Hell world!");
        $finish(2);
    end

`ifdef DUMP_FSDB
    initial begin 
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars;
    end 
`endif 


endmodule
