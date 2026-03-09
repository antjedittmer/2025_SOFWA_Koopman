# 2025_SOFWA_Koopman

This repository builds upon the foundational work by **Nassir Cassamo** on Koopman-based modeling for wind farm control. The SOWFA datasets and initial identification frameworks used in this study are derived from his previous research and repositories:

* **Cassamo's Repository:** [Cassamo/Koopman_MPC_WindFarm](https://github.com/nassircassamo/IODMD_SOWFA)
* **Related Publications:** [Cassamo et al. (2020)](https://doi.org/10.3390/en13246513) and [Cassamo et al. (2021)](https://ieeexplore.ieee.org/document/9482631)

This repository contains the code and data to reproduce the results and figures for the augmented sensing study:

> **"A Simulative Analysis of Physically-Motivated Koopman Lifted States for Wind Farm Model Predictive Control"** (2025)

## Table of Contents
* [Overview](#overview)
* [Key Features](#key-features)
* [Folder Structure](#folder-structure)
* [Requirements](#requirements)
* [How to Run](#how-to-run)
* [Citation](#citation)

## Overview
This study evaluates Koopman-based power prediction for wind farms using SOWFA (Simulator for Wind Farm Applications) data under varied sensing constraints. It investigates how sparse measurement configurations impact prediction fidelity and how physically motivated Koopman lifting functions (such as quadratic and cubic rotor speeds) can recover accuracy when spatial wind data is scarce.

The provided code compares:
1. **Wind Field Models:** Based on high-resolution 51,543-point grids.
2. **Sparse Wind Data:** Based on an optimized 84-point sparse grid.
3. **Wind at Turbine Models:** Utilizing 42 measurements restricted to the rotor disks.

## Key Features
- **runGetVAFforDiffPos.m:** Implementation of an exhaustive sweep across 2,310 longitudinal sensor combinations to identify optimal sampling zones.
- **MainPaper:** Get variance-accounted-for of different combinations.
- **MainPaperKpsi:** Integration of temporal lifting functions that align with the physical power-law relationship ($P \propto v^3$) to compensate for missing flow data.


## Requirements
The code has been tested using:
- **MATLAB R2023b** (or newer)
- **Control System Toolbox**

## How to Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/antjedittmer/2025_SOFWA_Koopman.git](https://github.com/antjedittmer/2025_SOFWA_Koopman.git)