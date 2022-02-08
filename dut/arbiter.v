//------------------------------------------------------------------------------------------------------------------------//
//change log 2017-08-20 Arbiter complete package length select and keep Not in Formater
//                      Need to update to configurable round robin arbiter  -----  @@ZS
//------------------------------------------------------------------------------------------------------------------------//
module arbiter(
    input                   clk_i,
    input                   rstn_i,

    //connect with registers
    input [1:0]             slv0_prio_i,
    input [1:0]             slv1_prio_i,
    input [1:0]             slv2_prio_i,
    input [2:0]             slv0_pkglen_i,
    input [2:0]             slv1_pkglen_i,
    input [2:0]             slv2_pkglen_i,

    //connect with slave port
    input [31:0]            slv0_data_i,
    input [31:0]            slv1_data_i,
    input [31:0]            slv2_data_i,
    input                   slv0_req_i,
    input                   slv1_req_i,
    input                   slv2_req_i,
    input                   slv0_val_i,
    input                   slv1_val_i,
    input                   slv2_val_i,
    output                  a2s0_ack_o,
    output                  a2s1_ack_o,
    output                  a2s2_ack_o,

    //connect with formater
    input                   f2a_id_req_i,
    input                   f2a_ack_i,
    output                  a2f_val_o,
    output [1:0]            a2f_id_o,
    output [31:0]           a2f_data_o,
    output [2:0]            a2f_pkglen_sel_o
    );


    reg         a2f_val_r;
    reg [1:0]   a2f_id_r;
    reg [31:0]  a2f_data_r;
    reg [1:0]   id_sel_r;
    reg [2:0]   a2f_pkglen_sel_r;

    always @ (posedge clk_i or negedge rstn_i) begin : CHANEL_SELECT
        if (!rstn_i) 
            id_sel_r  = 2'b11;
        else if (f2a_id_req_i)
            case ({slv2_req_i,slv1_req_i,slv0_req_i})  
                3'b001: begin 
                    id_sel_r <= 2'b00;
                    a2f_pkglen_sel_r = slv0_pkglen_i;
                end 		
                3'b010: begin
                    id_sel_r <= 2'b01;
                    a2f_pkglen_sel_r = slv1_pkglen_i;
                end 
                3'b011: begin
                    if(slv1_prio_i >= slv0_prio_i) begin
                        id_sel_r <= 2'b00;
                        a2f_pkglen_sel_r = slv0_pkglen_i;
                    end 
                    else begin
                        id_sel_r <= 2'b01;
                        a2f_pkglen_sel_r = slv1_pkglen_i;
                    end 
                end
                3'b100: begin
                    id_sel_r <= 2'b10;
                    a2f_pkglen_sel_r = slv2_pkglen_i;
                end 			
                3'b101: begin
                    if(slv2_prio_i >= slv0_prio_i) begin
                        id_sel_r <= 2'b00;
                        a2f_pkglen_sel_r = slv0_pkglen_i;
                    end 
                    else begin
                        id_sel_r <= 2'b10;
                        a2f_pkglen_sel_r = slv2_pkglen_i;
                    end 
                end
                3'b110: begin
                    if(slv2_prio_i >= slv1_prio_i) begin
                        id_sel_r <= 2'b01;
                        a2f_pkglen_sel_r = slv1_pkglen_i;
                    end 
                    else begin
                        id_sel_r <= 2'b10;
                        a2f_pkglen_sel_r = slv2_pkglen_i;
                    end 
                end
                3'b111: begin
                    if(slv2_prio_i >= slv0_prio_i && slv1_prio_i >= slv0_prio_i) begin      //priority 0>1 && 0>2
                        id_sel_r <= 2'b00;
                        a2f_pkglen_sel_r = slv0_pkglen_i;
                    end  																	
                    if(slv2_prio_i >= slv0_prio_i && slv1_prio_i < slv0_prio_i) begin       //priority 1>0>2
                        id_sel_r <= 2'b01;              									
                        a2f_pkglen_sel_r = slv1_pkglen_i;
                    end 
                    if(slv2_prio_i < slv0_prio_i && slv2_prio_i >= slv1_prio_i) begin       //priority 1>2>0
                        id_sel_r <= 2'b01; 													
                        a2f_pkglen_sel_r = slv1_pkglen_i;
                    end 	
                    if(slv2_prio_i < slv0_prio_i && slv2_prio_i < slv1_prio_i) begin        //priority 2>0 && 2>1
                        id_sel_r <= 2'b10; 													
                        a2f_pkglen_sel_r = slv2_pkglen_i;
                    end 
                end
                default: begin 
                    id_sel_r <= 2'b11;
                    a2f_pkglen_sel_r = 3'b111;
                end             
             endcase 
        else begin
            id_sel_r <= id_sel_r;
            a2f_pkglen_sel_r <= a2f_pkglen_sel_r;
        end 
    end 


    always@( id_sel_r or slv0_data_i or slv1_data_i or slv2_data_i or slv0_val_i or slv1_val_i or slv2_val_i) begin
        case ( id_sel_r)
            2'b00: begin
                a2f_id_r = 2'b00;
                a2f_data_r = slv0_data_i;
                a2f_val_r = slv0_val_i;
            end
            2'b01: begin
                a2f_id_r = 2'b01;
                a2f_data_r = slv1_data_i;
                a2f_val_r = slv1_val_i;
            end
            2'b10: begin
                a2f_id_r = 2'b10;
                a2f_data_r = slv2_data_i;
                a2f_val_r = slv2_val_i;
            end
            default :begin
                a2f_id_r = 2'b11;               
                a2f_data_r = 32'hffff_ffff; 
                a2f_val_r = 1'b0;
            end
        endcase
    end

    assign a2s0_ack_o = ( id_sel_r == 2'b00)?f2a_ack_i:1'b0;
    assign a2s1_ack_o = ( id_sel_r == 2'b01)?f2a_ack_i:1'b0;
    assign a2s2_ack_o = ( id_sel_r == 2'b10)?f2a_ack_i:1'b0;

    assign a2f_val_o = a2f_val_r;
    assign a2f_id_o = a2f_id_r;
    assign a2f_data_o = a2f_data_r;
    assign a2f_pkglen_sel_o = a2f_pkglen_sel_r;

endmodule
