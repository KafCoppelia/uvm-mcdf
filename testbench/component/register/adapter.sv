`ifndef _ADAPTER_SV
`define _ADAPTER_SV

class adapter extends uvm_reg_adapter;
    string tID = get_type_name();

    `uvm_object_utils(adapter)
    function new(string name = "adapter");
        super.new(name);
        provides_responses = 1;
    endfunction
    
    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        transaction_bus tr;
        tr = new("tr");
        tr.addr = rw.addr;
        tr.cmd = (rw.kind == UVM_READ) ? `WRITE : `READ;
        tr.data = rw.data;
        return tr;
    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        transaction_bus tr;
        if(!$cast(tr, bus_item)) begin
            `uvm_fatal(tID, "Provided bus_item is not of the correct type. Expecting bus_trans action")
            return;
        end
        rw.kind = (tr.cmd == `WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr = tr.addr;
        rw.data = tr.data;
        rw.status = UVM_IS_OK;
    endfunction

endclass

`endif

