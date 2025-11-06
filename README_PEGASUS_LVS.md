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

Hopefully you pass.  If not, I find it best to switch to a more manual approach.  

### Viewing Results in Innovus

I have been unable to get Innovus do automatically interface with Pegasus.  Your milage may vary.  

###  LVS  in Virtuoso

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

#### Run LVS Manually in Virtuoso

In Virtuoso, open the Library Manager (Tools -> Library Manager), and open the Layout of the cell: 

<img width="1159" height="506" alt="image" src="https://github.com/user-attachments/assets/dd4c8003-0f27-4940-8ea4-a1584b5bee8d" />

(If it asks about layout tools, select the "XL" version).  

Now open the Pegasus LVS sub-menu  (Pegasus->Run LVS). 

This should bring up the main LVS interface.  Fill out the 'Run Directory' as follows: 

<img width="795" height="715" alt="image" src="https://github.com/user-attachments/assets/b3c58330-2adb-4707-ba7b-c066008ceea2" />

Now switch to the 'Rules' tab (on the left), and fill it out as follows:
 - Under 'Rules', click 'Add'.  Then add `/l/sky130_release_0.1.0/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl`

<img width="796" height="715" alt="image" src="https://github.com/user-attachments/assets/07ecee54-0307-4a35-bd98-2df4c7c7266b" />

Now switch to the 'Inputs' tab (left), and fill it out as follows: 
 - Use Existing GDS, this is likely `../sram_8_1024_sky130A.gds.gz`
 - Create SPICE.  The default path is fine
 - Under Schematic, use 'Netlist'
 - Under Schematic -> Netlist Files, select 'Verilog', then click 'Add' and add `../post_pnr_lvs.vg`
 - Under Schematic -> Netlist Files, select 'CDL', then click 'Add' and add `../pegagus_lvs/include.cdl`.  If this file doesn't exist,  run the command-line version above first.    
 - Make sure they are in the correct order (Verilog on top, CDL on bottom)

<img width="797" height="713" alt="image" src="https://github.com/user-attachments/assets/563add18-cb3f-4e1f-9119-1d5f409d7f26" />

Now switch to the 'Outputs' tab (left).  
 - Make sure 'Automatch' is selected under H-Cell Settings.

<img width="800" height="622" alt="image" src="https://github.com/user-attachments/assets/1abadcfb-fb1f-46bf-9737-64cfff65a55f" />

LVS Options -> Extract Options

<img width="795" height="698" alt="image" src="https://github.com/user-attachments/assets/2d423d36-2b5f-4003-be7e-62ffb74138d3" />

Now click 'Apply'.  This will run Pegagus LVS.  


#### Analyize LVS 

Once LVS completes, you should get a window like what is below.  If there are no errors (everything is green), you are done.  If there are errors, click on 'Open' to debug them.

<img width="348" height="403" alt="image" src="https://github.com/user-attachments/assets/f0a254c3-5cda-45e1-8e39-69d7d6a5a407" />

We suggest turning on all the "Show" options at the top: 
<img width="149" height="44" alt="image" src="https://github.com/user-attachments/assets/997f5a84-031c-412a-ad78-5d96e653e393" />

When you select a problem, you should see something like the screenshot below.  

<img width="1440" height="735" alt="image" src="https://github.com/user-attachments/assets/2896c9a7-7dd2-43d0-9447-dd8375298482" />

 - On the top-center is the description of the LVS problem.  Pegasus believes there are 2 seperate physical nets in the Layout, but only 1 net in the Schematic/Netlist.  
 - On the bottom-left is an extract SPICE netlist derived from the GDS.  It's highlighting the two seperate nets. 
 - On the bottom-center is the schematic/netlist view.  It's highlighting the single net.
 - On the right is the Virtuoso view, with the two different nets highlighted.



