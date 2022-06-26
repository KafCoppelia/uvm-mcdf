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
    logic                       penable;
    logic                       psel;
    logic                       pwrite;
    logic [`ADDR_WIDTH-1:0]     paddr;
    logic [`CMD_DATA_WIDTH-1:0] pwdata;
    logic [`CMD_DATA_WIDTH-1:0] prdata;
    
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        output psel, penable, pwrite, paddr, pwdata;
        input prdata;
    endclocking

    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input psel, penable, pwrite, paddr, pwdata, prdata;
    endclocking

endinterface

interface interface_formatter(input clk, input rstn);
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

interface interface_arbiter(input clk, input rstn);
    logic [1:0] slv_prios[3];
    logic slv_reqs[3];
    logic a2s_acks[3];
    logic f2a_id_req;
    clocking mon_ck @(posedge clk);
      default input #1ns output #1ns;
      input slv_prios, slv_reqs, a2s_acks, f2a_id_req;
    endclocking
  endinterface

interface interface_mcdf(input clk, input rstn);
    // USER TODO
    // To define those signals which do not exsit in
    // reg_if, chnl_if, arb_if or fmt_if
    logic chnl_en[3];
  
    clocking mon_ck @(posedge clk);
      default input #1ns output #1ns;
      input chnl_en;
    endclocking
endinterface    
 
`endif


