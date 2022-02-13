#-----------------------------------------------------------------------------------------------
#  compile option 
#-----------------------------------------------------------------------------------------------
#--- PRE ---
PRE_OPT += -full64 
PRE_OPT += -sverilog
PRE_OPT += +libext+.sv+.svh   #extend file type; svh for seperate head file and function file after 
#PRE_OPT += -timescale=1ns/100ps 
PRE_OPT += -override_timescale=1ns/1ps 
PRE_OPT += -debug_access+all  #this for ucil mode
PRE_OPT += +notimingcheck
PRE_INC += +incdir+../testbench/interface/
PRE_SRC += 
PRE_ALL += $(PRE_OPT) $(PRE_INC) $(PRE_SRC) 

#--- DUT --- 
DUT_SRC += -f ./rtl.list #How to write rtl.list ?
DUT_INC += +incdir+../dut 
DUT_ALL += $(DUT_INC) $(DUT_SRC)
#--- TB_TOP ---
TB_TOP_INC +=
# TB_TOP_SRC += ../testbench/tb_top.sv 
TB_TOP_OPT += 
TB_TOP_ALL += $(TB_TOP_INC) $(TB_TOP_SRC) $(TB_TOP_OPT)
#--- DUT_WRAP --
WRAP_INC += 
WRAP_SRC += 
WRAP_ALL += $(WRAP_INC) $(WRAP_SRC) 
#--- UVM  ---
UVM_SRC += 
UVM_INC += +incdir+../testbench/component/transaction/
UVM_OPT += -ntb_opts uvm-1.1
UVM_ALL += $(UVM_OPT) $(UVM_INC) $(UVM_SRC) 
#--- POST ---
#POST_OPT += -M
POST_OPT += -Mdir=MLib
POST_OPT += -Mlib=MLib
POST_OPT += +radincr
POST_OPT += -j 16
#POST_OPT += -o 
#--- FSDB WAVE --- 
FSDB_DEF += +define+DUMP_FSDB=1
# FSDB_OPT += -fsdb
FSDB_OPT += -lca
FSDB_OPT += -kdb
FSDB_ALL += $(FSDB_DEF) $(FSDB_OPT)

#-----------------------------------------------------------------------------------------------
#  sim option 
#-----------------------------------------------------------------------------------------------
CASE_NAME = case0
VERBOSITY ?= UVM_MEDIUM
SIM_OPT += +UVM_VERBOSITY=$(VERBOSITY)
# SIM_OPT += +UVM_TESTNAME=$(CASE_NAME) 
SIM_OPT += +UVM_TIMEOUT="10000000ns,YES"   #watch dog time out 
#SIM_OPT += +UVM_OBJECTION_TRACE            #debug: trace objection raise or drop

TOOL_CMD += vcs
NORMAL = $(TOOL_CMD) $(PRE_ALL) $(DUT_ALL) $(POST_OPT) 
ALL    = $(TOOL_CMD) $(PRE_ALL) $(DUT_ALL) $(WRAP_ALL) $(UVM_ALL) $(TB_TOP_ALL) $(POST_OPT) 


build_w: rtl.list
	$(ALL) $(FSDB_ALL) -o usimv

sim:
	./usimv $(SIM_OPT) +UVM_TESTNAME=$(CASE_NAME)  -l sim.log

case1:
	./usimv $(SIM_OPT) +UVM_TESTNAME=case1  -l sim.log

case2:
	./usimv $(SIM_OPT) +UVM_TESTNAME=case2  -l sim.log

verdi:
	verdi --ssv -ssy -ssf tb.fsdb -simflow -simBin ./usimv

.PHONY: clean clean_all 
clean:
	rm -rf csrc usimv usimv.daidir usimv.vdb ucli.key vc_hdrs.h novas* *fsdb
	rm -rf verdiLog *.log build_w sim
	rm -rf result
	rm -rf .simvision
clean_all:clean
	rm -rf core*
	rm -rf MLib
	rm -rf merge.vdb
	rm -rf urgReport
