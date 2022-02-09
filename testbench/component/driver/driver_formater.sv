`ifndef DRIVER_FORMATER_SV
`define DRIVER_FORMATER_SV

class driver_formater extends uvm_driver #(transaction_formater);
	local virtual interface_formater vif;
    local mailbox #(bit[31:0]) fifo;
    local int fifo_bound;
    local int data_consum_peroid;

	`uvm_component_utils(driver_formater)
	function new(string name = "drvier_fmt", uvm_component parent = null);
		super.new(name, parent);
	    this.fifo = new();
        this.fifo_bound = 4096;
        this.data_consum_peroid = 1;
    endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// `uvm_info("my_driver", "build_phase is called", UVM_LOW);

		if(!uvm_config_db#(virtual interface_formater)::get(this, "", "vif", vif))
			`uvm_fatal("driver_formater", "virtual interface must be set for vif!!!");

	endfunction

	extern virtual task run_phase(uvm_phase phase);
	extern virtual task do_receive();
	extern virtual task do_consume();
	extern virtual task do_config();
	extern virtual task do_reset();
	// extern virtual task drive_one_pkt(transaction_formater tr);
endclass

task driver_formater::run_phase(uvm_phase phase);
    fork 
        this.do_reset();
        this.do_config();
        this.do_consume();
        this.do_receive();
    join
endtask

task driver_formater::do_config();
    // transaction_formater req, rsp;
    forever begin
		seq_item_port.get_next_item(req);
        case(req.fifo)
            SHORT_FIFO: this.fifo_bound = 64;
            MED_FIFO: this.fifo_bound = 256;
            LONG_FIFO: this.fifo_bound = 512;
            ULTRA_FIFO: this.fifo_bound = 2048;
        endcase
        this.fifo = new(this.fifo_bound);
        case(req.bandwidth)
            LOW_WIDTH: this.data_consum_peroid = 8;
            MED_WIDTH: this.data_consum_peroid = 4;
            HIGH_WIDTH: this.data_consum_peroid = 2;
            ULTRA_WIDTH: this.data_consum_peroid = 1;
        endcase
        rsp = new("rsp");
        rsp.set_id_info(req);
		rsp.rsp = 1;
        seq_item_port.put_response(rsp);
        seq_item_port.item_done();
	end
endtask

task driver_formater::do_receive();
	forever begin
        @(posedge vif.fmt_req);
	    forever begin
		    @(posedge vif.clk);
		    if((this.fifo_bound - this.fifo.num()) >= vif.fmt_length)
                break;
        end
        vif.drv_ck.fmt_grant <= 1'b1;
        @(posedge vif.fmt_start);
        fork
            begin
                @(posedge vif.clk);
                vif.drv_ck.fmt_grant <= 0;
            end
        join_none
        repeat(vif.fmt_length) begin
            @(negedge vif.clk);
            this.fifo.put(vif.fmt_data);
	    end
    end
endtask

task driver_formater::do_consume();
    bit[31:0] data;
    forever begin
        void'(this.fifo.try_get(data));
        repeat($urandom_range(1, this.data_consum_peroid))
            @(posedge vif.clk);
    end
endtask

task driver_formater::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.fmt_grant <= 0;
    end
endtask

`endif

