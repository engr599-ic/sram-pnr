SHELL := /bin/bash

setup: 
	git submodule update --init

synth:
	genus -batch -files synthesis.tcl

pnr:
	innovus -stylus -batch -files pnr.tcl

run_checks:
	./run_checks.sh

all: 
	make synth 
	make pnr 
	make run_checks

clean:
	rm -rf dbs* fv
	rm -rf *.log*
	rm -rf *.cmd*
	rm -rf innovus_temp_*
	rm -rf timingReports
	rm -rf timing_report
	rm -rf *.vg
	rm -rf RPT_final*
	rm -rf client_log
	rm -rf *.vg
	rm -rf pegasus_drc pegasus_lvs
	rm -rf *.gds.gz
	rm -rf *.rpt
