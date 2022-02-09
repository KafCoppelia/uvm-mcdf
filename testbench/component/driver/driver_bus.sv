`ifndef DRIVER_BUS_SV
`define DRIVER_BUS_SV

class driver_bus extends uvm_driver #(transaction_bus);
	virtual interface_bus vif;

	`uvm_component_utils(driver_bus)
	function new(string name = "drvier_reg", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface_bus)::get(this, "", "vif", vif))
			`uvm_fatal("driver_bus", "virtual interface must be set for vif!!!");
	endfunction

	extern virtual task run_phase(uvm_phase phase);
	extern virtual task do_drive();
	extern virtual task do_reset();
	extern virtual task drive_one_pkt(transaction_bus tr);
endclass

task driver_bus::run_phase(uvm_phase phase);
	fork
        this.do_drive();
        this.do_reset();
    join
endtask
 
task driver_bus::do_reset();
    vif.cmd_addr <= 0;
    vif.cmd <= `IDLE;
    vif.cmd_data_w <= 0;
    forever begin
        @(negedge vif.rstn);
        vif.cmd_addr <= 0;
        vif.cmd <= `IDLE;
        vif.cmd_data_w <= 0;
	end
endtask
   
task driver_bus::do_drive();
    @(posedge vif.rstn);
    forever begin
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);
        // rsp.set_sequence_id(req);
        rsp.set_id_info(req);
        rsp.rsp = 1;
        seq_item_port.item_done(rsp);
	end
endtask

task driver_bus::drive_one_pkt(transaction_bus tr);
	// `uvm_info("driver_bus", "begin to driver one pkt ", UVM_LOW);
	@(posedge vif.clk iff (vif.rstn == 1'b1));
    
    case(tr.cmd)
        `WRITE: begin
            vif.drv_ck.cmd_addr <= tr.addr;
            vif.drv_ck.cmd <= tr.cmd;
            vif.drv_ck.cmd_data_w <= tr.data;
        end
        `READ: begin
            vif.drv_ck.cmd_addr <= tr.addr;
            vif.drv_ck.cmd <= tr.cmd;
            repeat(2) @(negedge vif.clk)
            tr.data = vif.cmd_data_r;
        end
        `IDLE: begin
            @(posedge vif.clk);
            vif.drv_ck.cmd_addr <= 0;
            vif.drv_ck.cmd <= `IDLE;
            vif.drv_ck.cmd_data_w <= 0;
        end
        default: $error("command %b is illegal", tr.cmd);
    endcase
    `uvm_info("driver_bus", $sformatf("sent addr %2x, cmd %2b, data %8x", tr.addr, tr.cmd, tr.data), UVM_HIGH)

endtask

`endif

