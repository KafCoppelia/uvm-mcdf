TESTNAME?=case0

COV?=0
ifeq (${COV},1)
COV_COMP_OPT= -cm line+cond+fsm+branch+tgl -cm_dir ./coverage/sim_${TESTNAME}.vdb -cm_hier ./cov.cfg +define+COV_EN
COV_SIM_OPT= -cm line+cond+fsm+branch+tgl -cm_dir ./coverage/sim_${TESTNAME}.vdb -cm_name ${TESTNAME}
else
COV_COMP_OPT=
COV_SIM_OPT=
endif

INC_DIR= +incdir+../testbench/interface/
INC_DIR+=+incdir+../testbench/component/case
INC_DIR+=+incdir+../testbench/component/transaction/
INC_DIR+=+incdir+../testbench/component/sequencer/
INC_DIR+=+incdir+../testbench/component/driver/
INC_DIR+=+incdir+../testbench/component/monitor/
INC_DIR+=+incdir+../testbench/component/agent/
INC_DIR+=+incdir+../testbench/component/model/
INC_DIR+=+incdir+../testbench/component/scoreboard/
INC_DIR+=+incdir+../testbench/component/env/
INC_DIR+=+incdir+../testbench/component/register/
INC_DIR+=+incdir+../testbench/component/coverage/

#  sim option 
VERBOSITY ?= UVM_MEDIUM
SIM_OPT += +UVM_VERBOSITY=$(VERBOSITY)
SIM_OPT += +UVM_TIMEOUT="1000000000ns,YES"   #watch dog time out
SIM_OPT += +ntb_random_seed_automatic
#SIM_OPT += +UVM_OBJECTION_TRACE            #debug: trace objection raise or drop

all:comp sim

comp:
	[ -d ${TESTNAME}_sim_dir ] || mkdir -m 777 ${TESTNAME}_sim_dir
	vcs -full64 -sverilog -q -debug_access+all -ntb_opts uvm-1.1 -lca -kdb -timescale=1ns/1ns \
	+notimingcheck ${COV_COMP_OPT} ${INC_DIR} \
	-f rtl.list	+define+DUMP_FSDB=1	\
	-l ${TESTNAME}_sim_dir/vcs_compile.log \
	-top tb_top ../testbench/tb_top.sv

sim:
	[ -d ${TESTNAME}_sim_dir ] || mkdir ${TESTNAME}_sim_dir
	./simv ${SIM_OPT} ${COV_SIM_OPT} -l ${TESTNAME}_sim_dir/sim_${TESTNAME}.log \
	+TESTNAME=${TESTNAME} +UVM_TESTNAME=${TESTNAME}

verdi:
	verdi --ssv -ssy -ssf tb.fsdb -simflow -simBin ./simv &

merge.vdb:
	urg -full64 -format both -dir ./coverage/*.vdb -dbname merge.vdb

cov: merge.vdb
	firefox urgReport/dashboard.html &
	verdi -cov -covdir merge.vdb &

.PHONY: clean cleanall
clean:
	rm -rf csrc simv simv.* *.fsdb .__solver_cache__
	rm -rf novas* ucli.key vc_hdrs.h

cleanall:clean
	rm -rf coverage merge.vdb urgReport vdCovLog
	rm -rf verdiLog *.log *_sim_dir
