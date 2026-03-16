# 2025_SOFWA_Koopman

## General

This repository contains the MATLAB code used to obtain the results in 
> A. Dittmer, H. Werner (2026) A Simulative Analysis of Physically-Motivated Koopman Lifted States for Wind Farm Model Predictive Control

submitted to Torque 2026.

It may be used to recreate the simulation results and figures from the paper. 

The paper and the code is based on the work by **Nassir Cassamo** on Koopman-based modeling for wind farm control. The SOWFA datasets and initial identification frameworks used in this study are derived from his previous research and repositories:

* **Cassamo's Repository:** [Cassamo/Koopman_MPC_WindFarm](https://github.com/nassircassamo/IODMD_SOWFA)
* **Related Publications:** [Cassamo et al. (2020)](https://doi.org/10.3390/en13246513) and [Cassamo et al. (2021)](https://ieeexplore.ieee.org/document/9482631)

The code needs the SOFWA data provided in [Cassamo/Koopman_MPC_WindFarm](https://github.com/nassircassamo/IODMD_SOWFA) to run.

## Overview
This study evaluates Koopman-based power prediction for wind farms using SOWFA (Simulator for Wind Farm Applications) data under varied sensing constraints. It investigates how sparse measurement configurations impact prediction fidelity and how physically motivated Koopman lifting functions (such as quadratic and cubic rotor speeds) can recover accuracy when spatial wind data is scarce.

The provided code compares:
1. **Wind Field Models:** Based on high-resolution 51,543-point grids.
2. **Sparse Wind Data:** Based on an a 84-point sparse grid.
3. **Wind at Turbine Models:** Based on an a 42-points at the rotor disks.

## Key Features
- **MainPaper:** generates models based on lifting functions of linear, cubic and quadratic longitudinal wind speeds.
- **MainPaperKpsi:** generates models based on the wind speed lifting functions and on lifted rotor speeds.
- **runGetVAFforDiffPos.m:** runs a sweep across 2,310 longitudinal position combinations to identify optimal measurement positions

## Requirements
The code has been tested using:
- **MATLAB R2023b** 
- **Control System Toolbox**

