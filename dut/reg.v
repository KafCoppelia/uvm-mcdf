//------------------------------------------------------------------------------------------------------------------------//
//2017-08-13: V0.1 zhangshi   Original version. 
//2017-11-09: V0.2 zhangshi   R&W register's reserved bit can't be wrote.
//------------------------------------------------------------------------------------------------------------------------//
 
`include "param_def.v"

module ctrl_regs(	
    clk_i,
    rstn_i,
    cmd_i,
    cmd_addr_i,
    cmd_data_i,
    cmd_data_o,
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
    input [1:0] cmd_i;
    input [`ADDR_WIDTH-1:0]  cmd_addr_i; 
    input [`CMD_DATA_WIDTH-1:0]  cmd_data_i;
    input [`FIFO_MARGIN_WIDTH-1:0] slv0_margin_i;
    input [`FIFO_MARGIN_WIDTH-1:0] slv1_margin_i;
    input [`FIFO_MARGIN_WIDTH-1:0] slv2_margin_i;

    reg [`CMD_DATA_WIDTH-1:0] mem [5:0];
    reg [`CMD_DATA_WIDTH-1:0] cmd_data_reg;

    output  [`CMD_DATA_WIDTH-1:0] cmd_data_o;
    output  [`PAC_LEN_WIDTH-1:0]  slv0_pkglen_o;
    output  [`PAC_LEN_WIDTH-1:0]  slv1_pkglen_o;
    output  [`PAC_LEN_WIDTH-1:0]  slv2_pkglen_o;
    output  [`PRIO_WIDTH-1:0]  slv0_prio_o;
    output  [`PRIO_WIDTH-1:0]  slv1_prio_o;
    output  [`PRIO_WIDTH-1:0]  slv2_prio_o;
    output   slv0_en_o;
    output   slv1_en_o;
    output   slv2_en_o;

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
         else if (cmd_i== `WRITE) begin
            case(cmd_addr_i)
                `SLV0_RW_ADDR: mem[`SLV0_RW_REG]<= {26'b0,cmd_data_i[`PAC_LEN_HIGH:0]};				
                `SLV1_RW_ADDR: mem[`SLV1_RW_REG]<= {26'b0,cmd_data_i[`PAC_LEN_HIGH:0]};			
                `SLV2_RW_ADDR: mem[`SLV2_RW_REG]<= {26'b0,cmd_data_i[`PAC_LEN_HIGH:0]};   
            endcase 
        end	
    end 

    always@ (posedge clk_i or negedge rstn_i) // read R&W, R register
        if(!rstn_i)
            cmd_data_reg <= 32'b0;
        else if(cmd_i == `READ) begin       
        case(cmd_addr_i)
            `SLV0_RW_ADDR:		cmd_data_reg  <= mem[`SLV0_RW_REG];
            `SLV1_RW_ADDR:		cmd_data_reg  <= mem[`SLV1_RW_REG];
            `SLV2_RW_ADDR:	  cmd_data_reg  <= mem[`SLV2_RW_REG];					
            `SLV0_R_ADDR: 		cmd_data_reg  <= mem[`SLV0_R_REG];
            `SLV1_R_ADDR: 		cmd_data_reg  <= mem[`SLV1_R_REG];
            `SLV2_R_ADDR: 		cmd_data_reg  <= mem[`SLV2_R_REG];
        endcase
    end

    assign  cmd_data_o  = cmd_data_reg;
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

