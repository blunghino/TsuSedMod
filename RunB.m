% Brent Lunghino updated 9/2014. 
% BL updated again on 4/29/2015 (moved many things into subfunctions)
%
% 4/29/15 BL fixed csv output file issue (RSE values correct but in
% wrong order) see issue #5 on github
%
% This script is intended to be run with the working directory set to the
% location of the .xls file with the grain size data.
% all that is required in the directory is this run file
% and the grain size data. the directory with the inverse model and all subfolders
% must be added to your matlab path but need not be in the working directory.
%
% This script brings together all the files needed for to complete a model
% run. It also allows some model run options to be specified. It calls scripts 
% write an output file with model inputs and outputs. It calls scripts to 
% creates some plots of model results.
clear all; close all;

%% SETTINGS - to be changed by user

%Site data file name, .xls or .csv file IN CURRENT WORKING DIRECTORY
fname='Japan_Site_Data_Interp_T3_Jogan.xls'; 
% Site Name
sname='T3';
% Use to look at specific trenchs
Trench_ID=[{'T3-16'}];
% Depth range - change to look at different intervals of the deposit
Drange=[10 14];
% Phi range
PHIrange=[0 8];
% flow depth (m)
flow_depth = 5;
% grading (m)       
% eg .01 if regular 1 cm samples
grading = .01;
% set which input file reader to use
%    2 = SED_Size_Reader_02.m
%    3 = SED_Size_Reader_03.m
%    0 = uniform_GS_csv_reader.m
rdr = 2;
% values to loop through for model runs. the default is to loop over 
% mannings n bottom roughness values.
% To loop over a different model input, you must change 
% the reference to param where the core model function is called
param = [0.02 0.03 0.04];

%% OUTPUT SETTINGS
% settings for plots and output files

% Save figures? put 0 if don't want to save figures
Save.ALL=0;
% write csv output file
WriteCSV = 1;
% save model output structure as a .mat file
SaveMat = 1;
% Speed and Froude number plot
SpdFrd = 1;
% Stack plot: Distribution
% plot modeled distributions on top of data
StackDist = 1;
% concentration profiles plot
Cfig=0;
% plot observed distributions
ObsDist=1;
% plot modeled distributions
ModDist=0;
% plot deposit formation history
LayerForm=1;
% plot check convergence
% useful figures if the model is not converging
% shows how parameters change for each iteration 
CheckConv = 0;

%% SETUP - get paths and input data ready for model runs

% path to model run file
inv_model_name = 'Tsunami_InvVelModel_V3p8';
[inv_model_path, ~, ~] = fileparts(which(inv_model_name));
% path to file specifying default model parameters
% if not using default model parameters, save model parameters file in pwd
% and use:
% inv_modelP_file = fullfile(pwd,'Name_Of_Non_Default_Model_Params_File.xls');
inv_modelP_file = fullfile(inv_model_path, 'Tsunami_InvVelModel_Default.xls');

%Run SED_Size_Reader
if rdr == 2
    [SedSize]=...
        SED_Size_Reader_02('infile',[fname],'Trench_ID',Trench_ID,'Drange',Drange,'PHIrange',PHIrange);
elseif rdr == 3
    [SedSize]=...
        SED_Size_Reader_03('infile',[fname],'Trench_ID',Trench_ID,'Drange',Drange,'PHIrange',PHIrange);
elseif rdr == 0
    [SedSize]=...
        uniform_GS_csv_reader('infile',[fname],'Drange',Drange,'PHIrange',PHIrange);        
end

% Take what you need from SED_size_reader, make structure to input to model
matIn.phi=SedSize.phi;
matIn.wt=SedSize.Bulk.wt;
matIn.interval_weights = SedSize.wt;
matIn.mindepth = SedSize.mindepth;
matIn.maxdepth = SedSize.maxdepth;
matIn.th=(max(SedSize.maxdepth)-min(SedSize.mindepth))/100;
matIn.Trench_ID = SedSize.Tname;
matIn.Drange = Drange;
matIn.PHIrange = PHIrange;


%% RUN MODEL - model runs here, and error calculations

%Set parameter value if you want to loop and run inverse model
% If value not specified, then goes to defaults in
% Tsunami_InvVelModel_Default.xls
%added varargin options in V3p6:
% 'matIn'            structure to read in phi,wt,thickness
% 'h'                flow depth
% 'zotot'            specify a total bed roughness parameter
% 'mannings'         specify a mannings n component of bed roughness (model will calculate total
% 'th'               thickness (will not work for distribution comparison)
% 'eddyViscShape'   
% function
% 'rhow'

% loop through param values, run model with each value
for i=1:length(param)
    % write param to console
    fprintf(1, '\n\n%s\n%s %4.2f\n',...
            '#########################################################',...
            'param = ', param(i))
    % run model 
    [modelOUT(i)]=Tsunami_InvVelModel_V3p8('infile', inv_modelP_file,...
                                             'grading', grading,...
                                             'matIn', matIn,...
                                             'mannings', param(i),...
                                             'h', flow_depth,...
                                             'sname', sname,...
                                             'eddyViscShape', 3);
    
    % close figures made by grading subfunction
    close
   
end

%% Save figure folder

fpath = fullfile(pwd, 'figures');
if ~exist(fpath) && Save.ALL == 1
    mkdir(fpath);
end

%% write csv output file

if WriteCSV == 1
    % create file path to write output csv to
    out_file_name = ['Inv-V3p8_results_',SedSize.Tname,'_',num2str(Drange(1)),...
                '-',num2str(Drange(2)),'cm_','model_output.csv'];
    out_file_path = fullfile(pwd, out_file_name);
    write_csv_output_file
end

%% save model output structure as a .mat file

if SaveMat == 1
    % Save mat folder
    mpath = fullfile(pwd, 'mat_outputs');
    if ~exist(mpath)
        mkdir(mpath);
    end
    % save mat name
    mat_name=strcat('Inv-V3p8_results_',SedSize.Tname,'_',num2str(Drange(1)),...
                    '-',num2str(Drange(2)),'cm_',datestr(now, 30),'.mat');
    save(fullfile(mpath, mat_name), 'modelOUT', 'param')
end

%% Speed and Froude number plot

if SpdFrd == 1
    speed_and_froude_number_plot
end

%% Stack plot: Distribution
% plot modeled distributions on top of data

if StackDist == 1
    stack_plot_distribution
end

%% concentration profiles plot

if Cfig==1
    concentration_profiles_plot
end

%% plot observed distributions

if ObsDist==1
    plot_observed_distributions
end

%% plot modeled distributions

if ModDist==1
    plot_modeled_distributions
end

%% plot deposit formation history

if LayerForm==1
    plot_deposit_formation_history
end

%% plot check convergence
% useful figures if the model is not converging
% shows how parameters change for each iteration 

if CheckConv == 1
    plot_check_convergence
end
