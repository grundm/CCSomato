# Experimental control of tactile detection task

Control of DS5 Bipolar Constant Current Stimulator via MATLAB, Psychtoolbox and Data Acquisition Toolbox

## General

- Stimulation intensity relates to adjusted voltage and current (e.g., 10V:10mA -> signal of 5 relates to 5 mA)
- DS5 current and voltage output have to multiplied by 10 (1V signal equals 10mA resp. 10V)
- If input positive, then red output is positive, so current flows from black to red
- IMPORTANT: Wait until output is done "talking" (e.g., trigger(ao); wait(ao,1000);)

## Hardware Requirements

- Digitimer DS5
- Data Translation DT9812 USB module
  - Manual: https://www.mccdaq.com/PDFs/Manuals/UM9812-13-14.pdf

## Software Requirements

- Windows<sup>1</sup>
- MATLAB 32-bit<sup>1</sup>
- Data Acquisition Toolbox 32-bit (http://de.mathworks.com/products/daq/)<sup>1</sup>
- MATLAB Toolboxes
  - Psychtoolbox (http://psychtoolbox.org)
  - Palamedes Toolbox (http://palamedestoolbox.org) [included in the repository]
  - Mex-File Plug-in for Fast MATLAB Port I/O Access (http://apps.usd.edu/coglab/psyc770/IO32.html)
- Data Translation Open Layers (OEM)
  - Manual:  https://www.mccdaq.com/PDFs/manuals/UMOpenLayers.pdf
  - Download: https://www.mccdaq.com/Products/Data-Acquisition-Software/DT-Open-Layers-Class-Library
- Data Translation DAQ Adaptor for MATLAB
  - Manual: https://www.mccdaq.com/PDFs/manuals/UMDAQAdaptorMATLAB.pdf
  - Download: https://www.mccdaq.com/Products/Data-Acquisition-Software/MATLAB-Data-Acquisition

<sup>1</sup>Determined by Data Translation's DAQ Adaptor for MATLAB

### Setup Presentation Computer

- Windows 7 Professional (SP1)
- Intel Core i5-3320M @ 2.60 GHz
- 8 GB RAM
- MATLAB 8.5.1 (R2015aSP1)
- Data Acquisition Toolbox 3.7
- Psychtoolbox 3.0.11
- Palamedes 1.8.2
- DAQ Adaptor for MATLAB 1.0.10.22 
- Data Translation Open Layers (OEM) 7.8.0

## Installation

- Install DT OEM
- Install DT DAQ Adaptor for MATLAB
- Run in MATLAB: daqregister 'C:\Program Files (x86)\Data Translation\DAQ Adaptor for MATLAB\Dtol.dll'
- Download 'inpout32a.dll' (http://apps.usd.edu/coglab/psyc770/IO32on64.html)
- Copy 'inpout32a.dll' to 'C:\windows\system32' or follow instructions according to your setup

## Repository Structure

- CCSomato.m - main script to control experiment by executing sections step-by-step
- exp_init.m - helper function to initialize experiment
- CCSomato/ - directory with code for experimental block
- psi_1AFC/ - directory with code for threshold assessment
- assets/func - general functions used in multiple scripts
- assets/plot - functions to plot threshold assessment and analog input data
- assets/vendor - external code, e.g. Palamedes & io32
