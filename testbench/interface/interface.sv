`ifndef _INTERFACE_SV
`define _INTERFACE_SV

interface interface_channel(input clk, input rstn);
    logic [31:0] ch_data;
    logic        ch_valid;
    logic        ch_ready;
        
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        output ch_data, ch_valid;
        input ch_ready;
    endclocking
        
    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input ch_data, ch_valid, ch_ready;
    endclocking

endinterface


interface interface_bus(input clk, input rstn);
    logic [1:0]                 cmd;
    logic [`ADDR_WIDTH-1:0]     cmd_addr;
    logic [`CMD_DATA_WIDTH-1:0] cmd_data_r;
    logic [`CMD_DATA_WIDTH-1:0] cmd_data_w;
    
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        output cmd, cmd_addr, cmd_data_w;
        input cmd_data_r;
    endclocking

    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input cmd, cmd_addr, cmd_data_w, cmd_data_r;
    endclocking

endinterface

interface interface_formater(input clk, input rstn);
    logic        fmt_grant;
    logic [1:0]  fmt_chid;
    logic        fmt_req;
    logic [5:0]  fmt_length;
    logic [31:0] fmt_data;
    logic        fmt_start;
    logic        fmt_end;
    
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        input fmt_chid, fmt_req, fmt_length, fmt_data, fmt_start;
        output fmt_grant;
    endclocking
    
    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input fmt_grant, fmt_chid, fmt_req, fmt_length, fmt_data, fmt_start;
    endclocking
endinterface

`endif


