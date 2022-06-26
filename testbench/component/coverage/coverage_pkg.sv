`ifndef COVERAGE_PKG_SV
`define COVERAGE_PKG_SV

// coverage model for MCDF
class coverage_mcdf extends uvm_component;
    local virtual interface_channel chnl_vifs[3]; 
    local virtual interface_arbiter arb_vif; 
    local virtual interface_mcdf mcdf_vif;
    local virtual interface_bus reg_vif;
    local virtual interface_formatter fmt_vif;
    local int delay_req_to_grant;

    `uvm_component_utils(coverage_mcdf)

    covergroup cg_mcdf_reg_write_read;
        addr: coverpoint reg_vif.mon_ck.paddr {
            type_option.weight = 0;
            bins slv0_rw_addr = {`SLV0_RW_ADDR};
            bins slv1_rw_addr = {`SLV1_RW_ADDR};
            bins slv2_rw_addr = {`SLV2_RW_ADDR};
            bins slv0_r_addr  = {`SLV0_R_ADDR };
            bins slv1_r_addr  = {`SLV1_R_ADDR };
            bins slv2_r_addr  = {`SLV2_R_ADDR };
        }
        cmd: coverpoint reg_vif.mon_ck.pwrite {
            type_option.weight = 0;
            bins write = {1'b1};
            bins read  = {1'b0};
        }
        cmdXaddr: cross cmd, addr {
            bins slv0_rw_addr = binsof(addr.slv0_rw_addr);
            bins slv1_rw_addr = binsof(addr.slv1_rw_addr);
            bins slv2_rw_addr = binsof(addr.slv2_rw_addr);
            bins slv0_r_addr  = binsof(addr.slv0_r_addr );
            bins slv1_r_addr  = binsof(addr.slv1_r_addr );
            bins slv2_r_addr  = binsof(addr.slv2_r_addr );
            bins write        = binsof(cmd.write);
            bins read         = binsof(cmd.read );
            bins write_slv0_rw_addr  = binsof(cmd.write) && binsof(addr.slv0_rw_addr);
            bins write_slv1_rw_addr  = binsof(cmd.write) && binsof(addr.slv1_rw_addr);
            bins write_slv2_rw_addr  = binsof(cmd.write) && binsof(addr.slv2_rw_addr);
            bins read_slv0_rw_addr   = binsof(cmd.read) && binsof(addr.slv0_rw_addr);
            bins read_slv1_rw_addr   = binsof(cmd.read) && binsof(addr.slv1_rw_addr);
            bins read_slv2_rw_addr   = binsof(cmd.read) && binsof(addr.slv2_rw_addr);
            bins read_slv0_r_addr    = binsof(cmd.read) && binsof(addr.slv0_r_addr); 
            bins read_slv1_r_addr    = binsof(cmd.read) && binsof(addr.slv1_r_addr); 
            bins read_slv2_r_addr    = binsof(cmd.read) && binsof(addr.slv2_r_addr); 
        }
    endgroup

    covergroup cg_mcdf_reg_illegal_access;
        addr: coverpoint reg_vif.mon_ck.paddr {
            type_option.weight = 0;
            bins legal_rw = {`SLV0_RW_ADDR, `SLV1_RW_ADDR, `SLV2_RW_ADDR};
            bins legal_r = {`SLV0_R_ADDR, `SLV1_R_ADDR, `SLV2_R_ADDR};
            bins illegal = {[8'h20:$], 8'hC, 8'h1C};
        }
        cmd: coverpoint reg_vif.mon_ck.pwrite {
            type_option.weight = 0;
            bins write = {1'b0};
            bins read  = {1'b1};
        }
        wdata: coverpoint reg_vif.mon_ck.pwdata {
            type_option.weight = 0;
            bins legal = {[0:'h3F]};
            bins illegal = {['h40:$]};
        }
        rdata: coverpoint reg_vif.mon_ck.prdata {
            type_option.weight = 0;
            bins legal = {[0:'hFF]};
            illegal_bins illegal = default;
        }
        cmdXaddrXdata: cross cmd, addr, wdata, rdata {
            bins addr_legal_rw = binsof(addr.legal_rw);
            bins addr_legal_r = binsof(addr.legal_r);
            bins addr_illegal = binsof(addr.illegal);
            bins cmd_write = binsof(cmd.write);
            bins cmd_read = binsof(cmd.read);
            bins wdata_legal = binsof(wdata.legal);
            bins wdata_illegal = binsof(wdata.illegal);
            bins rdata_legal = binsof(rdata.legal);
            bins write_illegal_addr = binsof(cmd.write) && binsof(addr.illegal);
            bins read_illegal_addr  = binsof(cmd.read) && binsof(addr.illegal);
            bins write_illegal_rw_data = binsof(cmd.write) && binsof(addr.legal_rw) && binsof(wdata.illegal);
            bins write_illegal_r_data = binsof(cmd.write) && binsof(addr.legal_r) && binsof(wdata.illegal);
        }
    endgroup

    covergroup cg_channel_disable;
        ch0_en: coverpoint mcdf_vif.mon_ck.chnl_en[0] {
            type_option.weight = 0;
            wildcard bins en  = {1'b1};
            wildcard bins dis = {1'b0};
        }
        ch1_en: coverpoint mcdf_vif.mon_ck.chnl_en[1] {
            type_option.weight = 0;
            wildcard bins en  = {1'b1};
            wildcard bins dis = {1'b0};
        }
        ch2_en: coverpoint mcdf_vif.mon_ck.chnl_en[2] {
            type_option.weight = 0;
            wildcard bins en  = {1'b1};
            wildcard bins dis = {1'b0};
        }
        ch0_vld: coverpoint chnl_vifs[0].mon_ck.ch_valid {
            type_option.weight = 0;
            bins hi = {1'b1};
            bins lo = {1'b0};
        }
        ch1_vld: coverpoint chnl_vifs[1].mon_ck.ch_valid {
            type_option.weight = 0;
            bins hi = {1'b1};
            bins lo = {1'b0};
        }
        ch2_vld: coverpoint chnl_vifs[2].mon_ck.ch_valid {
            type_option.weight = 0;
            bins hi = {1'b1};
            bins lo = {1'b0};
        }
        chenXchvld: cross ch0_en, ch1_en, ch2_en, ch0_vld, ch1_vld, ch2_vld {
            bins ch0_en  = binsof(ch0_en.en);
            bins ch0_dis = binsof(ch0_en.dis);
            bins ch1_en  = binsof(ch1_en.en);
            bins ch1_dis = binsof(ch1_en.dis);
            bins ch2_en  = binsof(ch2_en.en);
            bins ch2_dis = binsof(ch2_en.dis);
            bins ch0_hi  = binsof(ch0_vld.hi);
            bins ch0_lo  = binsof(ch0_vld.lo);
            bins ch1_hi  = binsof(ch1_vld.hi);
            bins ch1_lo  = binsof(ch1_vld.lo);
            bins ch2_hi  = binsof(ch2_vld.hi);
            bins ch2_lo  = binsof(ch2_vld.lo);
            bins ch0_en_vld = binsof(ch0_en.en) && binsof(ch0_vld.hi);
            bins ch0_dis_vld = binsof(ch0_en.dis) && binsof(ch0_vld.hi);
            bins ch1_en_vld = binsof(ch1_en.en) && binsof(ch1_vld.hi);
            bins ch1_dis_vld = binsof(ch1_en.dis) && binsof(ch1_vld.hi);
            bins ch2_en_vld = binsof(ch2_en.en) && binsof(ch2_vld.hi);
            bins ch2_dis_vld = binsof(ch2_en.dis) && binsof(ch2_vld.hi);
        }
    endgroup

    covergroup cg_arbiter_priority;
        ch0_prio: coverpoint arb_vif.mon_ck.slv_prios[0] {
            bins ch_prio0 = {0}; 
            bins ch_prio1 = {1}; 
            bins ch_prio2 = {2}; 
            bins ch_prio3 = {3}; 
        }
        ch1_prio: coverpoint arb_vif.mon_ck.slv_prios[1] {
            bins ch_prio0 = {0}; 
            bins ch_prio1 = {1}; 
            bins ch_prio2 = {2}; 
            bins ch_prio3 = {3}; 
        }
        ch2_prio: coverpoint arb_vif.mon_ck.slv_prios[2] {
            bins ch_prio0 = {0}; 
            bins ch_prio1 = {1}; 
            bins ch_prio2 = {2}; 
            bins ch_prio3 = {3}; 
        }
    endgroup

    covergroup cg_formatter_length;
      id: coverpoint fmt_vif.mon_ck.fmt_chid {
        bins ch0 = {0};
        bins ch1 = {1};
        bins ch2 = {2};
        illegal_bins illegal = default; 
      }
      length: coverpoint fmt_vif.mon_ck.fmt_length {
        bins len4  = {4};
        bins len8  = {8};
        bins len16 = {16};
        bins len32 = {32};
        illegal_bins illegal = default;
      }
    endgroup

    covergroup cg_formatter_grant();
      delay_req_to_grant: coverpoint this.delay_req_to_grant {
        bins delay1 = {1};
        bins delay2 = {2};
        bins delay3_or_more = {[3:10]};
        illegal_bins illegal = {0};
      }
    endgroup

    function new (string name = "mcdf_coverage", uvm_component parent);
        super.new(name, parent);
        this.cg_mcdf_reg_write_read = new();
        this.cg_mcdf_reg_illegal_access = new();
        this.cg_channel_disable = new();
        this.cg_arbiter_priority = new();
        this.cg_formatter_length = new();
        this.cg_formatter_grant = new();
    endfunction

    task run_phase(uvm_phase phase);
      fork 
        this.do_reg_sample();
        this.do_channel_sample();
        this.do_arbiter_sample();
        this.do_formatter_sample();
      join
    endtask

    task do_reg_sample();
      forever begin
        @(posedge reg_vif.clk iff reg_vif.rstn);
        this.cg_mcdf_reg_write_read.sample();
        this.cg_mcdf_reg_illegal_access.sample();
      end
    endtask

    task do_channel_sample();
      forever begin
        @(posedge mcdf_vif.clk iff mcdf_vif.rstn);
        if(chnl_vifs[0].mon_ck.ch_valid===1
          || chnl_vifs[1].mon_ck.ch_valid===1
          || chnl_vifs[2].mon_ck.ch_valid===1)
          this.cg_channel_disable.sample();
      end
    endtask

    task do_arbiter_sample();
      forever begin
        @(posedge arb_vif.clk iff arb_vif.rstn);
        if(arb_vif.slv_reqs[0]!==0 || arb_vif.slv_reqs[1]!==0 || arb_vif.slv_reqs[2]!==0)
          this.cg_arbiter_priority.sample();
      end
    endtask

    task do_formatter_sample();
      fork
        forever begin
          @(posedge fmt_vif.clk iff fmt_vif.rstn);
          if(fmt_vif.mon_ck.fmt_req === 1)
            this.cg_formatter_length.sample();
        end
        forever begin
          @(posedge fmt_vif.mon_ck.fmt_req);
          this.delay_req_to_grant = 0;
          forever begin
            if(fmt_vif.fmt_grant === 1) begin
              this.cg_formatter_grant.sample();
              break;
            end
            else begin
              @(posedge fmt_vif.clk);
              this.delay_req_to_grant++;
            end
          end
        end
      join
    endtask

    function void report_phase(uvm_phase phase);
      string s;
      super.report_phase(phase);
      s = "\n---------------------------------------------------------------\n";
      s = {s, "COVERAGE SUMMARY \n"}; 
      s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
      s = {s, $sformatf("  cg_mcdf_reg_write_read coverage: %.1f \n", this.cg_mcdf_reg_write_read.get_coverage())}; 
      s = {s, $sformatf("  cg_mcdf_reg_illegal_access coverage: %.1f \n", this.cg_mcdf_reg_illegal_access.get_coverage())}; 
      s = {s, $sformatf("  cg_channel_disable_test coverage: %.1f \n", this.cg_channel_disable.get_coverage())}; 
      s = {s, $sformatf("  cg_arbiter_priority_test coverage: %.1f \n", this.cg_arbiter_priority.get_coverage())}; 
      s = {s, $sformatf("  cg_formatter_length_test coverage: %.1f \n", this.cg_formatter_length.get_coverage())}; 
      s = {s, $sformatf("  cg_formatter_grant_test coverage: %.1f \n", this.cg_formatter_grant.get_coverage())}; 
      s = {s, "---------------------------------------------------------------\n"};
      `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch0_vif", chnl_vifs[0]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch1_vif", chnl_vifs[1]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_channel)::get(this, "", "ch2_vif", chnl_vifs[2]))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_bus)::get(this, "", "reg_vif", reg_vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_formatter)::get(this, "", "fmt_vif", fmt_vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_arbiter)::get(this, "", "arb_vif", arb_vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
        if(!uvm_config_db#(virtual interface_mcdf)::get(this, "", "mcdf_vif", mcdf_vif))
            `uvm_fatal(get_type_name(), "virtual interface must be set for !!!");
    endfunction
endclass: coverage_mcdf

`endif

