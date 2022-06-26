//------------------------------------------------------------------------------------------------------------------------//
//2017-08-13: V0.1 zhangshi   Original version. 
//2017-11-09: V0.2 zhangshi   R&W register's reserved bit can't be wrote.
//------------------------------------------------------------------------------------------------------------------------//
 
`include "param_def.v"

module ctrl_regs(	
        clk_i,
        rstn_i,
        psel_i,
        pen_i,
        pwr_i,
        paddr_i,
        pwdata_i,
        prdata_o,
        slv0_pkglen_o,
        slv1_pkglen_o,
        slv2_pkglen_o,
        slv0_prio_o,
        slv1_prio_o,
        slv2_prio_o,		
        slv0_margin_i,
        slv1_margin_i,
        slv2_margin_i,
        slv0_en_o,
        slv1_en_o,
        slv2_en_o
    );
                        
    input clk_i;
    input rstn_i;

    input                           psel_i;
    input                           pen_i;
    input                           pwr_i;
    input  [`ADDR_WIDTH-1:0]        paddr_i; 
    input  [`CMD_DATA_WIDTH-1:0]    pwdata_i;
    output [`CMD_DATA_WIDTH-1:0]    prdata_o;

    input  [`FIFO_MARGIN_WIDTH-1:0] slv0_margin_i;
    input  [`FIFO_MARGIN_WIDTH-1:0] slv1_margin_i;
    input  [`FIFO_MARGIN_WIDTH-1:0] slv2_margin_i;
    output [`PAC_LEN_WIDTH-1:0]     slv0_pkglen_o;
    output [`PAC_LEN_WIDTH-1:0]     slv1_pkglen_o;
    output [`PAC_LEN_WIDTH-1:0]     slv2_pkglen_o;
    output [`PRIO_WIDTH-1:0]        slv0_prio_o;
    output [`PRIO_WIDTH-1:0]        slv1_prio_o;
    output [`PRIO_WIDTH-1:0]        slv2_prio_o;
    output   slv0_en_o;
    output   slv1_en_o;
    output   slv2_en_o;

    reg [`CMD_DATA_WIDTH-1:0] mem [5:0];
    reg [`CMD_DATA_WIDTH-1:0] cmd_data_reg;
    reg [`ADDR_WIDTH-1:0]     addr_r;

    reg [1:0] last_state, current_state ;

    parameter [1:0]     state_IDLE   = 2'b00 ;
    parameter [1:0]     state_SETUP  = 2'b01 ;
    parameter [1:0]     state_ENABLE = 2'b10 ;

    /* State Passing */
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) 
            last_state <= state_IDLE   ;
        else          
            last_state <= current_state    ;
    end

    /* State Transition */
    always @(*) begin
        case (last_state)
            state_IDLE:     if (psel_i) 
                                current_state <= state_SETUP;
                            else 
                                current_state <= state_IDLE;
            state_SETUP:    current_state <= state_ENABLE;  // PSEL=1 at this phase and goto state_ENABLE unconditionally
            state_ENABLE:   if (psel_i && !pen_i) begin
                                current_state <= state_SETUP;
                            end else begin
                                current_state <= state_IDLE;
                            end 
        endcase
    end
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            addr_r <= 0 ;
        end else begin
            if (current_state == state_SETUP)  begin
                addr_r <= paddr_i;
            end 
        end
    end 

    always @ (posedge clk_i or negedge rstn_i) 	begin			//Trace fifo's margin
        if (!rstn_i) begin
            mem [`SLV0_R_REG] <= 32'h00000020;   //FIFO's depth is 32
            mem [`SLV1_R_REG] <= 32'h00000020;
            mem [`SLV2_R_REG] <= 32'h00000020;
        end
        else begin
            mem [`SLV0_R_REG] <= {24'b0,slv0_margin_i};
            mem [`SLV1_R_REG] <= {24'b0,slv1_margin_i};
            mem [`SLV2_R_REG] <= {24'b0,slv2_margin_i};
        end
    end

    always @ (posedge clk_i or negedge rstn_i) 	begin			//write R&W register
        if (!rstn_i) begin 
            mem [`SLV0_RW_REG] = 32'h00000007;
            mem [`SLV1_RW_REG] = 32'h00000007;
            mem [`SLV2_RW_REG] = 32'h00000007;
        end
        else if ((current_state == state_ENABLE) & pwr_i) begin
            case(addr_r)
                `SLV0_RW_ADDR: mem[`SLV0_RW_REG]<= {26'b0,pwdata_i[`PAC_LEN_HIGH:0]};				
                `SLV1_RW_ADDR: mem[`SLV1_RW_REG]<= {26'b0,pwdata_i[`PAC_LEN_HIGH:0]};			
                `SLV2_RW_ADDR: mem[`SLV2_RW_REG]<= {26'b0,pwdata_i[`PAC_LEN_HIGH:0]};   
            endcase 
        end	
    end 

    always@ (posedge clk_i or negedge rstn_i)  begin// read R&W, R register
        if(!rstn_i)
            cmd_data_reg <= 32'b0;
        else if((current_state == state_SETUP) & (~pwr_i)) begin       
            case(paddr_i)
                `SLV0_RW_ADDR:  cmd_data_reg  <= mem[`SLV0_RW_REG];
                `SLV1_RW_ADDR:  cmd_data_reg  <= mem[`SLV1_RW_REG];
                `SLV2_RW_ADDR:  cmd_data_reg  <= mem[`SLV2_RW_REG];
                `SLV0_R_ADDR:   cmd_data_reg  <= mem[`SLV0_R_REG];
                `SLV1_R_ADDR:   cmd_data_reg  <= mem[`SLV1_R_REG];
                `SLV2_R_ADDR:   cmd_data_reg  <= mem[`SLV2_R_REG];
            endcase
        end
    end

    assign  prdata_o  = cmd_data_reg;
    assign  slv0_pkglen_o  = mem[`SLV0_RW_REG][`PAC_LEN_HIGH:`PAC_LEN_LOW];
    assign  slv1_pkglen_o  = mem[`SLV1_RW_REG][`PAC_LEN_HIGH:`PAC_LEN_LOW];
    assign  slv2_pkglen_o  = mem[`SLV2_RW_REG][`PAC_LEN_HIGH:`PAC_LEN_LOW];

    assign  slv0_prio_o  = mem[`SLV0_RW_REG][`PRIO_HIGH:`PRIO_LOW];
    assign  slv1_prio_o  = mem[`SLV1_RW_REG][`PRIO_HIGH:`PRIO_LOW];
    assign  slv2_prio_o  = mem[`SLV2_RW_REG][`PRIO_HIGH:`PRIO_LOW];
    
    assign  slv0_en_o = mem[`SLV0_RW_REG][0];
    assign  slv1_en_o = mem[`SLV1_RW_REG][0];
    assign  slv2_en_o = mem[`SLV2_RW_REG][0];

endmodule

