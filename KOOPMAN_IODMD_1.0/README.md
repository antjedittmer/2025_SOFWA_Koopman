# Source Code

The *MainPaper.m* script generates models based on lifting functions of 
linear, cubic and quadratic longitudinal wind speeds.

The *MainPaperKpsi.m* script generates models based on lifting functions of 
linear, cubic and quadratic longitudinal wind speeds and of lifting functions
defined in the function *K_psi_3D.m* applied to the turbine rotor speeds.

The *runGetVAFforDiffPos.m* script does a grid search for finding the
longitudinal position with the best variance-accounted for using the
function *getVAFforDifferentPositions.m*.

The main functionalities of the *MainPaper.m* and *MainPaperKpsi.m* are:

## 0/1. Initialise/Assess data
It goes through the following steps:
* **1. Create directory**
* **2. Load identification (turbine related) data set**
* **3. Load validation (turbine related) data set**
* **4. Define program parameters**
* **5. Define simulation parameters**

## 2. Dynamic Mode Decomposition
The relevant information is preprocessed and used to identify/compute the Reduce Order Models by using a suitable Dynamic Mode Decomposition algorithm, such as Input Output Dynamic Mode Decomposition.

It goes through the following steps:
* **1. Define time interval**
* **2. Read and pre process input-output identification data**
* **3. Read and pre process input-output validation data**
* **4. Define high order states for identification and validation**
* **5. Use Dynamic Mode Decomposition to compute models**

## 3. Validation
All computed Reduced Order Models are validated. Each one is simulated and using the Variance Accounted For criteria their fitness is assessed. A figure displaying the fitness of each model, with increasing number of modes used, given the identification and validation data set is then presented. The relevant variables are all saved to a specified directory, so that the models can be loaded afterwards.

* **1. Validate Reduced Order Models**
* **2. Present results**
* **3. Save results to mat files and print them to text files**
