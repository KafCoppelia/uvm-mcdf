//------------------------------------------------------------------------------------------------------------------------//
//change log 2017-08-20 Move package length select to Arbiter  
//------------------------------------------------------------------------------------------------------------------------//
`include "param_def.v"
module mcdf(
    input clk_i,
    input rstn_i,

    input                           pen_i,
    input                           psel_i,
    input                           pwr_i,
    input  [`ADDR_WIDTH-1:0]        paddr_i, 
    input  [`CMD_DATA_WIDTH-1:0]    pwdata_i,
    output [`CMD_DATA_WIDTH-1:0]    prdata_o,

    input [31:0] ch0_data_i,
    input  ch0_vld_i,
    input [31:0] ch1_data_i,
    input  ch1_vld_i,
    input [31:0] ch2_data_i,
    input  ch2_vld_i,
    output  ch0_ready_o,
    output  ch1_ready_o,
    output  ch2_ready_o,

    input  fmt_grant_i,
    output [1:0] fmt_chid_o,
    output fmt_req_o,
    output [5:0]  fmt_length_o,
    output [31:0] fmt_data_o,
    output fmt_start_o,
    output fmt_end_o 
    );

    //--------------register To slave_fifo
    wire  slv0_en_s;
    wire  slv1_en_s;
    wire  slv2_en_s;
    wire [5:0] slv0_margin_s;
    wire [5:0] slv1_margin_s;
    wire [5:0] slv2_margin_s;

    //--------------register To arbiter 
    wire [`PRIO_WIDTH-1:0] slv0_prio_s;
    wire [`PRIO_WIDTH-1:0] slv1_prio_s;
    wire [`PRIO_WIDTH-1:0] slv2_prio_s;
    wire  [`PAC_LEN_WIDTH-1:0]  slv0_pkglen_s;
    wire  [`PAC_LEN_WIDTH-1:0]  slv1_pkglen_s;
    wire  [`PAC_LEN_WIDTH-1:0]  slv2_pkglen_s;

    //--------------slave_fifo to arbiter 
    wire [31:0]  slv0_data_s;
    wire [31:0]  slv1_data_s;
    wire [31:0]  slv2_data_s;

    wire slv0_req_s;
    wire slv1_req_s;
    wire slv2_req_s;

    wire slv0_val_s;
    wire slv1_val_s;
    wire slv2_val_s;

    wire a2s0_ack_s;
    wire a2s1_ack_s;
    wire a2s2_ack_s;

    //--------------formater to arbiter
    wire   			f2a_ack_s;
    wire    			a2f_val_s;
    wire    			f2a_id_req_s;
    wire[31:0] 		a2f_data_s;
    wire[1:0]   	a2f_id_s;
    wire[2:0] 		pkglen_sel_s;


    ctrl_regs ctrl_regs_inst(
        .clk_i(clk_i),   
        .rstn_i(rstn_i),
        .paddr_i(paddr_i),
        .pwr_i(pwr_i),
        .pen_i(pen_i),
        .psel_i(psel_i),
        .pwdata_i(pwdata_i),
        .prdata_o(prdata_o),
        .slv0_pkglen_o(slv0_pkglen_s),
        .slv1_pkglen_o(slv1_pkglen_s),
        .slv2_pkglen_o(slv2_pkglen_s),
        .slv0_prio_o(slv0_prio_s),
        .slv1_prio_o(slv1_prio_s),
        .slv2_prio_o(slv2_prio_s),		
        .slv0_margin_i({2'b0, slv0_margin_s}),
        .slv1_margin_i({2'b0, slv1_margin_s}),
        .slv2_margin_i({2'b0, slv2_margin_s}),
        .slv0_en_o(slv0_en_s),
        .slv1_en_o(slv1_en_s),
        .slv2_en_o(slv2_en_s)
    );

    slave_fifo slv0_inst(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .chx_data_i(ch0_data_i),
        .chx_valid_i(ch0_vld_i),
        
        .chx_ready_o(ch0_ready_o),
        .slvx_en_i(slv0_en_s),
        .margin_o(slv0_margin_s),
        .a2sx_ack_i(a2s0_ack_s),
        .slvx_req_o(slv0_req_s),
        .slvx_val_o(slv0_val_s),
        .slvx_data_o(slv0_data_s)
    );
    slave_fifo slv1_inst(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .chx_data_i(ch1_data_i),
        .chx_valid_i(ch1_vld_i),
        
        .chx_ready_o(ch1_ready_o),
        .slvx_en_i(slv1_en_s),
        .margin_o(slv1_margin_s),
        .slvx_req_o(slv1_req_s),
        .a2sx_ack_i(a2s1_ack_s),
        .slvx_val_o(slv1_val_s),
        .slvx_data_o(slv1_data_s)
    );
    slave_fifo slv2_inst(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .chx_data_i(ch2_data_i),
        .chx_valid_i(ch2_vld_i),
        
        .chx_ready_o(ch2_ready_o),
        .slvx_en_i(slv2_en_s),
        .margin_o(slv2_margin_s),
        .slvx_req_o(slv2_req_s),
        .a2sx_ack_i(a2s2_ack_s),
        .slvx_val_o(slv2_val_s),
        .slvx_data_o(slv2_data_s)
    );
             
    arbiter arbiter_inst(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
                                
        //connect ith registers
        .slv0_prio_i(slv0_prio_s),
        .slv1_prio_i(slv1_prio_s),
        .slv2_prio_i(slv2_prio_s),

        //connect with slave port
        .slv0_data_i(slv0_data_s),
        .slv1_data_i(slv1_data_s),
        .slv2_data_i(slv2_data_s),
        .slv0_req_i(slv0_req_s),
        .slv1_req_i(slv1_req_s),
        .slv2_req_i(slv2_req_s),
        .slv0_val_i(slv0_val_s),
        .slv1_val_i(slv1_val_s),
        .slv2_val_i(slv2_val_s),
        .slv0_pkglen_i(slv0_pkglen_s),
        .slv1_pkglen_i(slv1_pkglen_s),
        .slv2_pkglen_i(slv2_pkglen_s),  
                                
        .a2s0_ack_o(a2s0_ack_s),
        .a2s1_ack_o(a2s1_ack_s),
        .a2s2_ack_o(a2s2_ack_s),
                                
        //connect with formater
        .a2f_pkglen_sel_o(pkglen_sel_s),
        .f2a_ack_i(f2a_ack_s),
        .f2a_id_req_i(f2a_id_req_s),
        .a2f_val_o(a2f_val_s),
        .a2f_id_o(a2f_id_s),
        .a2f_data_o(a2f_data_s)
    );

    formater formater_inst(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .a2f_val_i(a2f_val_s),
        .pkglen_sel_i(pkglen_sel_s),
        .a2f_id_i(a2f_id_s),
        .a2f_data_i(a2f_data_s),
        .f2a_ack_o(f2a_ack_s),
        .fmt_id_req_o(f2a_id_req_s),
        .fmt_chid_o(fmt_chid_o),
        .fmt_length_o(fmt_length_o),
        .fmt_req_o(fmt_req_o),
        .fmt_grant_i(fmt_grant_i),
        .fmt_data_o(fmt_data_o),
        .fmt_start_o(fmt_start_o),
        .fmt_end_o(fmt_end_o)
    );

endmodule

