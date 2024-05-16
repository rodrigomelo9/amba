TOPLEVEL_LANG = verilog

DUT      = rams
TOPLEVEL = $(DUT)
MODULE   = $(DUT)
VERILOG_SOURCES += ../rtl/$(DUT).sv
VERILOG_SOURCES += ../sim/$(DUT).sv

SIM ?= icarus

PLUSARGS        += -fst
VERILOG_SOURCES += dump.v
COMPILE_ARGS    += -s dump

include $(shell cocotb-config --makefiles)/Makefile.sim

dump.v:
	@echo 'module dump();'                   > $@
	@echo 'initial begin'                   >> $@
	@echo '    $$dumpfile("waves.fst");'    >> $@
	@echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	@echo 'end'                             >> $@
	@echo 'endmodule'                       >> $@

clean::
	@rm -rf __pycache__ *.xml dump.v *.fst

view:
	gtkwave waves.fst
