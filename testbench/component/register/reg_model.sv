`ifndef REG_MODEL_SV
`define REG_MODEL_SV

// channel control register
class ctrl_reg extends uvm_reg;
    uvm_reg_field reserved;
    rand uvm_reg_field pkt_len;
    rand uvm_reg_field prio_level;
    rand uvm_reg_field chnl_en;

    // covergroup value_cg;
    //     option.per_instance = 1;
    //     reserved: coverpoint reserved.value[25:0];
    //     pkt_len: coverpoint pkt_len.value[2:0];
    //     prio_level: coverpoint prio_level.value[1:0];
    //     chnl_en: coverpoint chnl_en.value[0:0];
    // endgroup

    `uvm_object_utils(ctrl_reg)
    function new(input string name = "ctrl_reg");
	    // parameter: name, size, has_coverage
        super.new(name, 32, UVM_CVR_ALL);

        // void'(set_coverage(UVM_CVR_FIELD_VALS));
        // if(has_coverage(UVM_CVR_FIELD_VALS)) begin
        //     value_cg = new();
        // end
    endfunction
    
	virtual function void build();
        reserved = uvm_reg_field::type_id::create("reserved");
        pkt_len = uvm_reg_field::type_id::create("pkt_len");
        prio_level = uvm_reg_field::type_id::create("prio_level");
        chnl_en = uvm_reg_field::type_id::create("chnl_en");

        // parameter: parent, size, lsb_pos, access, volatile, reset value, has_reset, is_rand, individually accessible
        reserved.configure(this, 26, 6, "RO", 0, 26'h0, 1, 0, 0);
        pkt_len.configure(this, 3, 3, "RW", 0, 3'h0, 1, 1, 0);
        prio_level.configure(this, 2, 1, "RW", 0, 2'h3, 1, 1, 0);
        chnl_en.configure(this, 1, 0, "RW", 0, 1'h1, 1, 1, 0);
    endfunction

    // function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    //     super.sample(data, byte_en, is_read, map);
    //     sample_values(); 
    // endfunction
  
    // function void sample_values();
    //     super.sample_values();
    //     if (get_coverage(UVM_CVR_FIELD_VALS)) begin
    //         value_cg.sample();
    //     end
    // endfunction

endclass

// channel status register
class stat_reg extends uvm_reg;
    uvm_reg_field reserved;
    rand uvm_reg_field fifo_avail;

    `uvm_object_utils(stat_reg)
    function new(string name = "stat_reg");
        super.new(name, 32, UVM_CVR_ALL);

        // void'(set_coverage(UVM_CVR_FIELD_VALS));
        // if(has_coverage(UVM_CVR_FIELD_VALS)) begin
        //     value_cg = new();
        // end
    endfunction

    virtual function void build();
        reserved = uvm_reg_field::type_id::create("reserved");
        fifo_avail = uvm_reg_field::type_id::create("fifo_avail");
  
        reserved.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 0);
        fifo_avail.configure(this, 8, 0, "RO", 0, 8'h20, 1, 1, 0);
    endfunction

    // covergroup value_cg;
    //     option.per_instance = 1;
    //     reserved: coverpoint reserved.value[23:0];
    //     fifo_avail: coverpoint fifo_avail.value[7:0];
    // endgroup

    // function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    //     super.sample(data, byte_en, is_read, map);
    //     sample_values(); 
    // endfunction
  
    // function void sample_values();
    //     super.sample_values();
    //     if (get_coverage(UVM_CVR_FIELD_VALS)) begin
    //         value_cg.sample();
    //     end
    // endfunction

endclass


//MCDF top register block which includes child registers and the address map
class reg_model_mcdf extends uvm_reg_block;
    rand ctrl_reg chnl0_ctrl_reg;
    rand ctrl_reg chnl1_ctrl_reg;
    rand ctrl_reg chnl2_ctrl_reg;
    rand stat_reg chnl0_stat_reg;
    rand stat_reg chnl1_stat_reg;
    rand stat_reg chnl2_stat_reg;

    `uvm_object_utils(reg_model_mcdf)
    function new(string name = "reg_model_mcdf");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
      chnl0_ctrl_reg = ctrl_reg::type_id::create("chnl0_ctrl_reg");
      chnl0_ctrl_reg.configure(this);
      chnl0_ctrl_reg.build();

      chnl1_ctrl_reg = ctrl_reg::type_id::create("chnl1_ctrl_reg");
      chnl1_ctrl_reg.configure(this);
      chnl1_ctrl_reg.build();

      chnl2_ctrl_reg = ctrl_reg::type_id::create("chnl2_ctrl_reg");
      chnl2_ctrl_reg.configure(this);
      chnl2_ctrl_reg.build();

      chnl0_stat_reg = stat_reg::type_id::create("chnl0_stat_reg");
      chnl0_stat_reg.configure(this);
      chnl0_stat_reg.build();

      chnl1_stat_reg = stat_reg::type_id::create("chnl1_stat_reg");
      chnl1_stat_reg.configure(this);
      chnl1_stat_reg.build();

      chnl2_stat_reg = stat_reg::type_id::create("chnl2_stat_reg");
      chnl2_stat_reg.configure(this);
      chnl2_stat_reg.build();

      // map name, offset, number of bytes, endianess
      default_map  = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);

      default_map.add_reg(chnl0_ctrl_reg, 32'h00000000, "RW");
      default_map.add_reg(chnl1_ctrl_reg, 32'h00000004, "RW");
      default_map.add_reg(chnl2_ctrl_reg, 32'h00000008, "RW");
      default_map.add_reg(chnl0_stat_reg, 32'h00000010, "RO");
      default_map.add_reg(chnl1_stat_reg, 32'h00000014, "RO");
      default_map.add_reg(chnl2_stat_reg, 32'h00000018, "RO");

      // specify HDL path
      chnl0_ctrl_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV0_RW_REG), 0, 32);
      chnl1_ctrl_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV1_RW_REG), 0, 32);
      chnl2_ctrl_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV2_RW_REG), 0, 32);
      chnl0_stat_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV0_R_REG ), 0, 32);
      chnl1_stat_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV1_R_REG ), 0, 32);
      chnl2_stat_reg.add_hdl_path_slice($sformatf("mem[%0d]", `SLV2_R_REG ), 0, 32);

      add_hdl_path("tb_top.dut.ctrl_regs_inst");

      lock_model();
    endfunction
endclass


    
`endif
