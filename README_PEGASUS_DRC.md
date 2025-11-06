# How to Run Pegasus DRC

This document details running Pegasus DRC, and how to view their results in both Innovus and Virtuoso 

## Pegasus DRC

Pegasus Design Rule Check (DRC) is the foundry-approved rule deck to check for manufacturability.  The foundry will typically not manufacture anything with DRC violations.  

### Running with the Command Line

Assuming your GDS is streamed out from Innovus, you can launch Pegasus DRC with the following command line: 

```
  ./run_pegasus_drc.sh
```

This script does roughly the following: 
 - Sets number of parallel CPUs = 4 (editable)
 - Figures out the TOP_MODULE name from synthesis.tcl
 - Creates the `pegasus_drc` working folder
 - Generates a `pegasusdrcctrl` file that contains all the control switches for Pegasus, including location of the GDS.
 - Runs Pegasus in DRC mode
 - Checks the resulting summary file (`.sum`) for the total DRC count
 - Reports PASS/FAIL based on DRC count


### Viewing Results in Innovus

You can load the DRC results from the following drop-down menu: 

<img width="762" height="349" alt="image" src="https://github.com/user-attachments/assets/c006b9bb-94a1-496f-9d39-4c62df91146b" />

Then selecting the `pegasus_drc` run folder and clocking "Open".  Note don't double-clock on or expand/open the folder, just select it.  

<img width="619" height="437" alt="image" src="https://github.com/user-attachments/assets/e3b78237-f038-4db8-a19b-4cd9aaf7ee8b" />

This will show all the current DRC violations: 

<img width="1016" height="314" alt="image" src="https://github.com/user-attachments/assets/e8511b06-dee7-4d25-b4a2-eb643113f216" />

The middle paine shows the rules that are violated, and the right paine shows the individual violations.  If we select one of the rules and one of the violations, we get something like this:  

<img width="791" height="339" alt="image" src="https://github.com/user-attachments/assets/c07a8908-a591-44d6-871c-185aa6110395" />

The bottom shows the individual rule that was violated, in this case: 

`"CDRW: Min spacing of huge_met4 to met4 excluding features checked by m4.3c: 0.40 um"`

Clicking on the indivdual violation should also show you a detailed view of the violation in Innovus: 

<img width="1214" height="713" alt="image" src="https://github.com/user-attachments/assets/0ab8117e-3f03-44b4-b0ed-617c1a02b8cf" />

More details about the individual Design Rules are given in the [Complete Design Rule Guide](#complete-design-rule-guide).

### Viewing DRC Results in Virtuoso

Innovus contains an incomplete view of the final GDS, which can make debugging DRC violations difficult at times.  When that happens, it's best to switch to Virtuoso.  

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

