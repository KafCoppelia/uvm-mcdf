`ifndef DRIVER_CHANNEL_SV
`define DRIVER_CHANNEL_SV

// driver for one slave fifo channel
class driver_channel extends uvm_driver #(transaction_channel);
	virtual interface_channel vif;

	`uvm_component_utils(driver_channel)
	function new(string name = "drvier_channel", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface_channel)::get(this, "", "vif", vif))
			`uvm_fatal("driver_channel", "virtual interface must be set for vif!!!");
	endfunction

	virtual task run_phase(uvm_phase phase);
        fork
            this.do_reset();
            this.do_drive();
        join
    endtask
	
    extern virtual task do_reset();
	extern virtual task do_drive();
	extern virtual task drive_one_pkt(transaction_channel tr);

endclass

task driver_channel::do_drive();
	// transaction_channel req, rsp;
	while(!vif.rstn)
		@(posedge vif.clk);
	while(1) begin
		seq_item_port.get_next_item(req);
		`uvm_info("driver_channel", {"get one transaction from sequencer: \n", req.sprint()}, UVM_HIGH);
        
        drive_one_pkt(req);
        
        void'($cast(rsp, req.clone()));
        rsp.set_sequence_id(req.get_sequence_id());
        rsp.rsp = 1;
		seq_item_port.put_response(rsp);
        seq_item_port.item_done();
	end
endtask

task driver_channel::drive_one_pkt(transaction_channel tr);
	
    foreach(tr.data[i]) begin
        @(posedge vif.clk);
        vif.drv_ck.ch_valid <= 1;
        vif.drv_ck.ch_data <= tr.data[i];
        @(negedge vif.clk);
        wait(vif.ch_ready === 'b1);
        `uvm_info("driver_channel", $sformatf("set data 'h%8x", tr.data[i]), UVM_HIGH)
        repeat(tr.data_nidles) begin
            @(posedge vif.clk);
            vif.drv_ck.ch_valid <= 0;
            vif.drv_ck.ch_data <= 0;
        end
    end
    repeat(tr.pkt_nidles) begin
        @(posedge vif.clk);
        vif.drv_ck.ch_valid <= 0;
        vif.drv_ck.ch_data <= 0;
    end
endtask

task driver_channel::do_reset();
    vif.ch_valid <= 'b0;
    vif.ch_data <= 'h0;
    forever begin
        @(negedge vif.rstn);
        vif.ch_valid <= 'b0;
        vif.ch_data <= 'h0;
    end
endtask

`endif

