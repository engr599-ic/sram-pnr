# How to Run Pegasus LVS

This document details running Pegasus LVS, and how to view/interpret the results. 

## Pegasus LVS

Layout Versus Schematic (LVS) checking compares the extracted netlist from the layout to the original schematic netlist to determine if they match.  It first generates two SPICE files, one from layout circuit and the other from the schematic circuit.  It then compares the two SPICE files to ensure their are no differences between layout and schematic.  

One common reason for LVS errors is two nets being shorted together in layout.  Here the schematic sees two logically-seperate nets, but the physical layout sees them as a single (shorted) net.  This discrepency results in LVS errors.  

### Running with the Command Line

Assuming your GDS is streamed out from Innovus, you can launch Pegasus LVS with the following command line: 

```
  ./run_pegasus_lvs.sh
```

This script does roughly the following: 
 - Sets number of parallel CPUs = 4 (editable)
 - Figures out the TOP_MODULE name from synthesis.tcl
 - Creates the `pegasus_lvs` working folder
 - Generates a `pegasuslvsctrl` file that contains all the control switches for Pegasus, including location of the GDS.
 - Runs Pegasus in LVS mode
 - Checks the resulting files for LVS mismatches
 - Reports PASS/FAIL based on the mismatch result


### Viewing Results in Innovus

I have been unable to get Innovus do automatically interface with Pegasus.  Your milage may vary.  

### Viewing LVS Results in Virtuoso

For LVS issues, it's often best to go straight to Virtuoso.  You may want to keep the Innovus database up as an additional reference point.  

#### Import into Virtuoso
First, we'll need to import the GDS into Virtuoso.  For that we provide the following script:

```
 ./run_virtuoso_import.sh
```

It does the following tasks: 
 - Setup the Virtuoso libraries through a `cds.lib` file.
 - StreamIn the GDS

Now launch Virtuoso and navigate to the appropiate library.  We recommend launching it in the `virtuoso` folder as follows: 

```
  cd virtuoso
  virtuoso
```

#### View DRCs in Virtuoso

In Virtuoso, open the Library Manager (Tools -> Library Manager), and open the Layout of the cell: 

<img width="1159" height="506" alt="image" src="https://github.com/user-attachments/assets/dd4c8003-0f27-4940-8ea4-a1584b5bee8d" />

(If it asks about layout tools, select the "XL" version).  

Now open the Pegasus DRC run as in Innovus (Pegasus->Open Run).  This time you may need to go up a directory to find the `pegasus_drc` folder.  

Once opened, select a DRC rule and violation, and it will be highlighted in Virtuoso's Layout View: 

<img width="1246" height="687" alt="image" src="https://github.com/user-attachments/assets/e3f865d8-068d-40b0-b594-1a44737a41de" />

Recall that more details about the individual Design Rules are given in the [Complete Design Rule Guide](#complete-design-rule-guide).

### Complete Design Rule Guide

A complete manual for the Sky130 Design Rules can be found here: 

`https://skywater-pdk.readthedocs.io/en/main/rules.html`

## Pegasus LVS

