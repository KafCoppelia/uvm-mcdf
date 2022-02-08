//------------------------------------------------------------------------------------------------------------------------//
//change log 2017-08-20 Move package length select to Arbiter 
//------------------------------------------------------------------------------------------------------------------------//
module formater(
    input                   clk_i,
    input                   rstn_i,
        
    //connect with arbiter
    output                  f2a_ack_o,
    output                  fmt_id_req_o,
    input                   a2f_val_i,
    input [1:0]             a2f_id_i,
    input [31:0]            a2f_data_i,
    input [2:0]             pkglen_sel_i,
        
    //connect with outside
    input                   fmt_grant_i,
    output [1:0]            fmt_chid_o,                  
    output [5:0]            fmt_length_o,                  
    output                  fmt_req_o,
    output [31:0]           fmt_data_o,
    output                  fmt_start_o,
    output                  fmt_end_o
    );

    reg [5:0]     length_r;
    reg [31:0]    fmt_fifo [0:31];
    reg [5:0]     cnt_rec_r;
    reg [5:0]     cnt_sen_r;
    reg [31:0]    slv0_buffer_r;
    reg [31:0]    slv1_buffer_r;
    reg [31:0]    slv2_buffer_r;
    reg [31:0]    fmt_data_r;
    reg [2:0]     c_state, n_state;

    reg buffer0_val_r;
    reg buffer1_val_r;
    reg buffer2_val_r;

    reg fmt_end_r;
    reg fmt_start_r;
    reg fmt_req_r;
    reg fmt_ack_r;
    reg fmt_send_r;
    reg fmt_id_req_r;


    //---------------------------------package length decode-------------------------// 
    always @ (*) begin
        if (!rstn_i) 
            length_r = 6'd32;
        else 
        case (pkglen_sel_i) 
            3'd0 : length_r = 6'd4;
            3'd1 : length_r = 6'd8;
            3'd2 : length_r = 6'd16;
            3'd3 : length_r = 6'd32;
            default : length_r = 6'd32;
        endcase
    end 

    //-----------------------------formater fifo write pointer increase---------------------//
    always @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) 
            cnt_rec_r <= 1'b0;
        else if (fmt_id_req_r) 
            cnt_rec_r <= 1'b0;
        else 
        case (a2f_id_i)
            2'b00 : if ((a2f_val_i | buffer0_val_r) && fmt_ack_r) cnt_rec_r <= cnt_rec_r + 1'b1;
            2'b01 : if ((a2f_val_i | buffer1_val_r) && fmt_ack_r) cnt_rec_r <= cnt_rec_r + 1'b1;
            2'b10 : if ((a2f_val_i | buffer2_val_r) && fmt_ack_r) cnt_rec_r <= cnt_rec_r + 1'b1;
            default : cnt_rec_r <= cnt_rec_r;
        endcase 
    end 

    //--------------------------fullfill formater fifo && buffer------------------------------------//
    always @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin  
            fmt_fifo[cnt_rec_r] <= 32'hffff_ffff;
            slv0_buffer_r <= 32'hffff_ffff; 
            buffer0_val_r <= 1'b0;
            slv1_buffer_r <= 32'hffff_ffff;
            buffer1_val_r <= 1'b0;
            slv2_buffer_r <= 32'hffff_ffff;
            buffer2_val_r <= 1'b0;
        end 
        else if (fmt_ack_r) 
        case (a2f_id_i)
            2'b00 : begin
                if (buffer0_val_r && fmt_ack_r) begin 
                    fmt_fifo[cnt_rec_r] <= slv0_buffer_r; 
                    buffer0_val_r <= 1'b0; 
                end 
                else if (a2f_val_i && fmt_ack_r) 
                    fmt_fifo[cnt_rec_r] <= a2f_data_i;
            end 
            2'b01 : begin
                if (buffer1_val_r && fmt_ack_r) begin 
                    fmt_fifo[cnt_rec_r] <= slv1_buffer_r; 
                    buffer1_val_r <= 1'b0; 
                end 
                else if (a2f_val_i && fmt_ack_r) begin 
                    fmt_fifo[cnt_rec_r] <= a2f_data_i;
                end 
            end 
            2'b10 : begin
                if (buffer2_val_r && fmt_ack_r) begin 
                    fmt_fifo[cnt_rec_r] <= slv2_buffer_r; 
                    buffer2_val_r <= 1'b0; 
                end 
                else if (a2f_val_i && fmt_ack_r) begin
                    fmt_fifo[cnt_rec_r] <= a2f_data_i;
                end 
            end
        endcase
        else 
        case (a2f_id_i)
            2'b00 : if (a2f_val_i && !fmt_ack_r) begin slv0_buffer_r <= a2f_data_i; buffer0_val_r <= 1'b1; end
            2'b01 : if (a2f_val_i && !fmt_ack_r) begin slv1_buffer_r <= a2f_data_i; buffer1_val_r <= 1'b1; end
            2'b10 : if (a2f_val_i && !fmt_ack_r) begin slv2_buffer_r <= a2f_data_i; buffer2_val_r <= 1'b1; end 
        endcase 
    end 

    //----------------------------formater fifo read pointer increase----------------------//
    always @ (posedge clk_i or negedge rstn_i) begin 
        if (!rstn_i) 
            cnt_sen_r <= 1'b0;
        else if (fmt_id_req_r) 
            cnt_sen_r <= 1'b0;
        else if (fmt_send_r) 
            cnt_sen_r <= cnt_sen_r + 1'b1;
    end 

    //--------------------------empty formater fifo-------------------------------------//
    always @ (*)
    begin
        if (!rstn_i) fmt_data_r <= 32'hffff_ffff;
        else if (fmt_send_r) fmt_data_r <= fmt_fifo[cnt_sen_r];
        else fmt_data_r <= 32'hffff_ffff;
    end 

    //-------------------------------------FSM start ------------------------------//
    parameter FMT_REQ = 3'b000;
    parameter FMT_WAIT_GRANT = 3'b001;
    parameter FMT_START = 3'b011;
    parameter FMT_SEND = 3'b010;
    parameter FMT_END = 3'b110;
    parameter FMT_IDLE = 3'b111;

    always @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) c_state <= FMT_IDLE;
        else c_state <= n_state;
    end 

    always @ (*) begin                //need length_r
        if (!rstn_i) 
	        n_state = FMT_IDLE;
	    else 
        case (c_state)
	        FMT_IDLE : 	begin
				if (cnt_rec_r == length_r - 2'd1) //need to decode and pay attention to cnt_rec_r start from 0 
					n_state = FMT_REQ;      //pay attention to datapath and FSM structure
				else 
					n_state = FMT_IDLE;
			end	
	        FMT_REQ : begin
                if(cnt_rec_r >= length_r)	n_state = FMT_WAIT_GRANT;
                else n_state = FMT_REQ;
            end
            FMT_WAIT_GRANT : begin
				if(fmt_grant_i) n_state = FMT_START;
				else n_state = FMT_WAIT_GRANT;
			end 
            FMT_START :  begin
                n_state = FMT_SEND;
            end
            FMT_SEND  : begin
				if (cnt_sen_r == length_r - 2'd2) n_state = FMT_END;
				else n_state = FMT_SEND;
			end 
			FMT_END : begin
                n_state = FMT_IDLE;	
            end 
	        default : n_state = FMT_IDLE;
	    endcase 
    end 

    always @ (*) begin
        if (!rstn_i)begin
            fmt_end_r = 1'b0;
            fmt_start_r = 1'b0;
            fmt_req_r = 1'b0;
            fmt_ack_r = 1'b0;
            fmt_send_r = 1'b0;
            fmt_id_req_r = 1'b1;
        end
        else 
        case (c_state)
            FMT_IDLE : begin
                if (a2f_id_i != 2'b11) 
                    fmt_ack_r = 1'b1;
                else 
                    fmt_ack_r = 1'b0;
                if (a2f_id_i == 2'b11) 
                    fmt_id_req_r = 1'b1;
                else 
                    fmt_id_req_r = 1'b0;
                fmt_end_r = 1'b0;
                fmt_start_r = 1'b0;
                fmt_req_r = 1'b0;
                fmt_send_r = 1'b0;
            end 
            FMT_REQ : begin
                if (cnt_rec_r >= length_r)  fmt_ack_r = 1'b0;
                else fmt_ack_r = 1'b1;
                fmt_req_r = 1'b1;
                //fmt_ack_r = 1'b0;
                fmt_end_r = 1'b0;
                fmt_start_r = 1'b0;
                fmt_send_r = 1'b0;
                fmt_id_req_r = 1'b0;
            end
            FMT_WAIT_GRANT : begin
                fmt_req_r = 1'b1;
                fmt_ack_r = 1'b0;
                fmt_start_r = 1'b0;
                fmt_end_r = 1'b0;
                fmt_send_r = 1'b0;
                fmt_id_req_r = 1'b0;
            end
            FMT_START : begin
                fmt_req_r = 1'b0;
                fmt_ack_r = 1'b0;
                fmt_start_r = 1'b1;
                fmt_end_r = 1'b0;
                fmt_send_r = 1'b1;
                fmt_id_req_r = 1'b0;
            end
            FMT_SEND : begin
                fmt_req_r = 1'b0;
                fmt_ack_r = 1'b0;
                fmt_start_r = 1'b0;
                fmt_end_r = 1'b0;
                fmt_send_r = 1'b1;
                fmt_id_req_r = 1'b0;
            end
            FMT_END : begin 
                fmt_req_r = 1'b0;
                fmt_ack_r = 1'b0;
                fmt_start_r = 1'b0;
                fmt_end_r = 1'b1;
                fmt_send_r = 1'b1;
                fmt_id_req_r = 1'b1;
            end
        endcase 
    end //end of FSM

    assign fmt_id_req_o = fmt_id_req_r;
    assign fmt_chid_o = a2f_id_i;
    assign fmt_length_o = length_r;
    assign fmt_req_o = fmt_req_r;
    assign fmt_start_o = fmt_start_r;
    assign fmt_end_o = fmt_end_r; 
    assign f2a_ack_o = fmt_ack_r;
    assign fmt_data_o = fmt_data_r;

endmodule 
 
