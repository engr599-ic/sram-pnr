SHELL := /bin/bash

all: 
	make synth 
	make pnr 
	make run_checks

setup: 
	git submodule update --init

synth:
	genus -batch -files synthesis.tcl

pnr:
	innovus -stylus -batch -files pnr.tcl

.PHONY:  pegasus_drc
pegasus_drc: 
	./run_pegasus_drc.sh

.PHONY: pegasus_lvs
pegasus_lvs: 
	./run_pegasus_lvs.sh

run_checks: pegasus_drc pegasus_lvs

clean:
	rm -rf dbs* fv
	rm -rf *.log*
	rm -rf *.cmd*
	rm -rf innovus_temp_*
	rm -rf timingReports
	rm -rf timing_report
	rm -rf RPT_final*
	rm -rf client_log
	rm -rf *.vg *.gds.gz *.lib
	rm -rf pegasus_drc pegasus_lvs
	rm -rf *.rpt
