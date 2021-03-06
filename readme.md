# TsuSedMod #

######Implementation of the inverse tsunami sediment transport model first published in 2007 by Jaffe and Gelfenbaum (1). Model calculates tsunami hydrodynamic flow parameters using characteristics of tsunami sand deposits.######

###Basic Usage###

Basic usage requires a properly configured **run file**: `Run_07.m`, and an excel spreadsheet or csv file holding tsunami deposit data. The files `GS_Japan_Sendai_T3-16.csv` and `Japan_Site_Data_Interp_T3_Jogan.xls` are provided as examples of the file layouts that will work for deposit data input. The entire contents of this github repository must added to your *MATLAB PATH* but need not be in your working directory.

To work with TsuSedMod, save a version of the **run file** in the directory you want to work in, along with a properly formatted excel or csv file with deposit data. Open the **run file** and change the definitions of the variables defined in the *SETTINGS* section of the code to the desired values for your data. See the comments in the *SETTINGS* section of the **run file** code for instructions on what values to assign each settings variable. 

###Advanced Parameters###

There are many model parameters that can be changed beyond those defined in the *SETTINGS* section of the **run file**. Some are defined in an excel file in the *Inverse* directory: `Tsunami_InvVelModel_Default.xls`. Others can be passed as arguments to the **model function**, which is located in the *Inverse* directory: `Tsunami_InvVelModel_V3p7MB.m`. These are partially discussed in the *RUN MODEL* section of the **run file** and are further discussed in the function documentation of the **model function**. Running `help Tsunami_InvVelModel_V3p7MB` should display information on advanced parameters. Any parameter values passed as arguments to the **model function** will override values set in `Tsunami_InvVelModel_Default.xls`.

###Model Output###

In the default **run file** several model outputs files are automatically saved. A .csv file in the working directory will save some model input and output values. A unique .csv file will be created for each depth interval and trench run. Multiple model runs on the same depth interval and trench will be appended to the existing .csv file. In the *mat_outputs* subdirectory of the working directory (automatically created if it doesn't already exist), the model will save .mat files with all model data for every model run. In the *figures* subdirectory in the working directory (automatically created if it doesn't already exist), the model will save figures created by the model **run file**. By default new model runs will overwrite old versions of figures for the same depth interval and trench. Figure saving can be turned off in the *SETTINGS* section of the **run file** by setting `Save.ALL = 0`.

###Publications featuring TsuSedMod###

1. Jaffe, B. E., & Gelfenbuam, G. (2007). A simple model for calculating tsunami flow speed from tsunami deposits. *Sedimentary Geology*, 200(3), 347-361.
2. Jaffe, B. E., Morton, R. A., Kortekaas, S., Dawson, A. G., Smith, D. E., Gelfenbaum, G., ... & Shi, S. (2008). Reply to Discussion of articles in “Sedimentary features of tsunami deposits”. *Sedimentary Geology*, 211(3), 95-97.
3. Jaffe, B., Buckley, M., Richmond, B., Strotz, L., Etienne, S., Clark, K., ... & Goff, J. (2011). Flow speed estimated by inverse modeling of sandy sediment deposited by the 29 September 2009 tsunami near Satitoa, east Upolu, Samoa. *Earth-Science Reviews*, 107(1), 23-37.
4. Jaffe, B. E., Goto, K., Sugawara, D., Richmond, B. M., Fujino, S., & Nishimura, Y. (2012). Flow speed estimated by inverse modeling of sandy tsunami deposits: results from the 11 March 2011 tsunami on the coastal plain near the Sendai Airport, Honshu, Japan. *Sedimentary Geology*, 282, 90-109.
5. Spiske, M., Weiss, R., Bahlburg, H., Roskosch, J., & Amijaya, H. (2010). The TsuSedMod inversion model applied to the deposits of the 2004 Sumatra and 2006 Java tsunami and implications for estimating flow parameters of palaeo-tsunami. *Sedimentary Geology*, 224(1), 29-37.
6. Brill, D., Bruckner, H., Jankaew, K., Kelletat, D., Scheffers, S. (2011). Potential predecessors of the 2004 Indian Ocean Tsunami-sedimentary evidence of extreme wave events at Ban Bang Sak, SW Thailand. *Sedimentary Geology*, 239(3), 146-161.
7. Witter, R. C., Jaffe, B., Zhang, Y., & Priest, G. (2012). Reconstructing hydrodynamic flow parameters of the 1700 tsunami at Cannon Beach, Oregon, USA. *Natural Hazards*, 63(1), 223-240.

Contains code by Bruce Jaffe, Guy Gelfenbaum, Chris Sherwood, Andrew Stevens, Mark Buckley, Brent Lunghino, SeanPaul La Selle. Developed at the [USGS Pacific Coastal and Marine Science Center](http://walrus.wr.usgs.gov/index.html).
