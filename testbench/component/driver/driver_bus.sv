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
    vif.penable <= 0;
    vif.psel <= 0;
    vif.pwrite <= 0;
    vif.paddr <= 0;
    vif.pwdata <= 0;
    vif.prdata <= 0;
    forever begin
        @(negedge vif.rstn);
        vif.penable <= 0;
        vif.psel <= 0;
        vif.pwrite <= 0;
        vif.paddr <= 0;
        vif.pwdata <= 0;
        vif.prdata <= 0;
    end
endtask
   
task driver_bus::do_drive();
    transaction_bus req, rsp;
    @(posedge vif.clk iff (vif.rstn == 1'b1));
    forever begin
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);

        void'($cast(rsp, req.clone()));
        rsp.set_id_info(req);
        rsp.rsp = 1;
        // rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
endtask

task driver_bus::drive_one_pkt(transaction_bus tr);

    wait(vif.rstn == 1'b1);
    
    case(tr.cmd)
        `WRITE: begin
            vif.drv_ck.paddr <= tr.addr;
            vif.drv_ck.pwrite <= 1'b1;
            vif.drv_ck.psel <=1'b1;
            vif.drv_ck.penable <= 1'b0;
            vif.drv_ck.pwdata <= tr.data;
            @(posedge vif.clk);
            vif.drv_ck.penable <= 1'b1;
            @(posedge vif.clk);
            vif.drv_ck.psel <=1'b0;
            vif.drv_ck.penable <= 1'b0;
            vif.drv_ck.pwdata <= 0;        
        end
        `READ: begin
            vif.drv_ck.paddr <= tr.addr;
            vif.drv_ck.pwrite <= 1'b0;
            vif.drv_ck.psel <=1'b1;
            vif.drv_ck.penable <= 1'b0;
            vif.drv_ck.pwdata <= tr.data;
            @(posedge vif.clk);
            vif.drv_ck.penable <= 1'b1;
            @(posedge vif.clk);
            tr.data = vif.prdata;
            vif.drv_ck.psel <=1'b0;
            vif.drv_ck.penable <= 1'b0;
            vif.drv_ck.pwdata <= 0; 
        end
        `IDLE: begin
            vif.drv_ck.psel <=1'b0;
            vif.drv_ck.penable <= 1'b0;
            vif.drv_ck.pwdata <= 0;
        end
        default: $error("command %b is illegal", tr.cmd);
    endcase

    `uvm_info("driver_bus", $sformatf("sent addr %2x, cmd %2b, data %8x", tr.addr, tr.cmd, tr.data), UVM_HIGH)

endtask

`endif

