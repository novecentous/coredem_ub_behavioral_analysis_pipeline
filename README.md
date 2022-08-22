# Behavioral Analysis Preprocessing Pipeline
Authors: Gloria Cecchini (MATLAB preprocessing scripts), Michael DePass (.mat to .csv Python script)
## Contents
1. MySQL database (.sql) for storing data 
2. MATLAB scripts (.m) for behavioral data preprocessing
    - Write data to MySQL database 
    - Load data from MySQL database
    - Plot behavior data including decisions & oculometry
    - Export data to .mat file 
3. .mat to .csv Python conversion script ideal for import to Pandas dataframe.

Example decisions plotted for Horizons 0 and 1 of the Consequential task:
| Horizon 1                           |                           Horizon 2 |
|-------------------------------------|-------------------------------------|
|![](./img/sample_behavior_data_h0.png)   |![](./img/sample_behavior_data_h1.png)   |

Example Pandas DataFrame after conversion to .csv:
![](./img/dataframe.png)
