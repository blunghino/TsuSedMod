## TsuSedMod ##

######Implementation of the inverse tsunami sediment transport model first published in 2007 by Jaffe and Gelfenbaum (1).######

###Basic Usage###

Basic usage requires a properly configured **run file**: `Run_07.m`, and an excel spreadsheet or csv file holding tsunami deposit data. `GS_Japan_Sendai_T3-16.csv` and `Japan_Site_Data_Interp_T3_Jogan.xls` are provided as examples of the file layouts that will work for deposit data input. The entire contents of this github repository must added to your *MATLAB PATH* but need not be in your working directory.

To work with TsuSedMod, save a version of the **run file** in the directory you want to work in, along with a properly formatted excel or csv file with deposit data. Open the **run file** and change the definitions of the variables defined in the **SETTINGS** section to the desired values for your data. See the comments in the **SETTINGS** section of the **run file** code for instructions on what values to assign each settings variable. 

###Advanced Parameters###

There are many model parameters that can be changed outside of those defined in the **SETTINGS** section. Some are defined in an excel file in the *Inverse* directory: `Tsunami_InvVelModel_Default.xls`. Others can be passed as arguments to the **model function**, which is located in the *Inverse* directory: `Tsunami_InvVelModel_V3p7MB.m`. These are partially discussed in the **RUN MODEL** section of the **run file** and are further discussed in the function documentation of the **model function**. Running `help Tsunami_InvVelModel_V3p7MB` should display information on advanced parameters.

###Publications featuring TsuSedMod###

1. Jaffe, B.E. and Gelfenbaum, G., 2007, *A simple model for calculating tsunami flow speed from tsunami deposits*, Sedimentary Geology, 200, p. 347-361, doi:10.1016/j.sedgeo.2007.01.013

contains code by Bruce Jaffe, Guy Gelfenbaum, Chris Sherwood, Andrew Stevens, Mark Buckley, Brent Lunghino, SeanPaul La Selle
