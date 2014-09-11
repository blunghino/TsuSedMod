%%
% This script is intended to be run with the working directory set to the
% location of the .xls file with the grain size data.
% all that is required in the directory is this run file
% and the grain size data. the directory with the inverse model must
% be added to your matlab path but need not be in the working directory.
%%
clear all; close all;
%Save figures?
Save.ALL=1;  % put 0 if don't want to save files
%Save figure path
fpath = fullfile(pwd, 'Figures');
if ~exist(fpath)
    mkdir(fpath);
end

%Site data file name
fname='Japan_Site_Data_interp_T3_Jogan.xls'; %Default .xls file IN CURRENT WORKING DIRECTORY

% path to model run file
inv_model_name = 'Tsunami_InvVelModel_V3p7MB';
[inv_model_path, ~, ~] = fileparts(which(inv_model_name));
% path to file specifying default model parameters
% if not using default model parameters, save model parameters file in pwd
% and use:
% inv_modelP_file = fullfile(pwd,'Name_Of_Non_Default_Model_Params_File.xls');
inv_modelP_file = fullfile(inv_model_path, 'Tsunami_InvVelModel_Default.xls');

%Site Name
sname='T3';
%Use to look at specific trenchs
Trench_ID=[{'T3-16'}];
%Depth range  *** change to look at different intervals of the deposit
Drange=[10 14];
%Phi range
PHIrange=[0 8];

%set which input file reader to use
%   2 = SED_Size_Reader_02.m
%   3 = SED_Size_Reader_03.m
%   0 = uniform_GS_csv_reader.m
rdr = 2;
%Run SED_Size_Reader
if rdr == 2
    [SedSize]=...
        SED_Size_Reader_02('infile',[fname],'Trench_ID',Trench_ID,'Drange',Drange,'PHIrange',PHIrange);
elseif rdr == 3
    [SedSize]=...
        SED_Size_Reader_03('infile',[fname],'Trench_ID',Trench_ID,'Drange',Drange,'PHIrange',PHIrange);
elseif rdr == 0
    % not yet implemented
    [SedSize]=...
        uniform_GS_csv_reader('infile',[fname],'Drange',Drange,'PHIrange',PHIrange);        
end
%%%
%Take what you need from SED_size_reader
matIn.phi=SedSize.phi;
matIn.wt=SedSize.Bulk.wt;
matIn.th=(max(SedSize.maxdepth)-min(SedSize.mindepth))/100;
%%
%Set parameter value if you want to loop and run inverse model
% If value not specified, then goes to defaults in
% Tsunami_InvVelModel_Default.xls
%added varargin options in V3p6:
% 'matIn'            structure to read in phi,wt,thickness
% 'h'                flow depth
% 'zotot'
% 'mannings'
% 'th'               thickness (will not work for distribution comparison)
% 'eddyViscShape' *** if 4, then eddie viscosity shape defined by newk
% function
% 'rhow'

% values to loop through for model runs
param=[0.02 0.03 0.04];   

% open file to write output
out_file_name = ['Inv-V3p7_results_',SedSize.Tname,'_',num2str(Drange(1)),...
                '-',num2str(Drange(2)),'cm_','RMSerror.csv'];
out_file_path = fullfile(pwd, out_file_name);
fid=fopen(out_file_path,'a');
     fprintf(fid,'%s\n',[datestr(now),' --- ', inv_model_name]);
     fprintf(fid,'%s %5.2f %5.2f\n','Phi Range is ',PHIrange);
     
% loop through param values, running model with each value
for i=1:length(param)
     
    [modelOUT(i)]=Tsunami_InvVelModel_V3p7MB...
        ('infile',inv_modelP_file,'grading',0.01,'matIn',matIn,'mannings',param(i),'h',0.5,'sname',sname,'eddyViscShape',3);
    
    AvgSpeed(i,1)=modelOUT(i).results.AvgSpeed;
    AvgFroude(i,1)=modelOUT(i).results.AvgFroude;
    
    %     Calculate RMS error between modeled and observed distributions for each 1-cm (or other) interval in suspension graded layer
    %     calculated for only the 1st model parameter
    FlipSedWt=fliplr(SedSize.wt)*100;  %flip so order of levels in observed and modeled wts match
    for j=1:length(modelOUT(1).gradOut.midint);
        RmsError(i,j)=sqrt(sum(((FlipSedWt(:,j))'-modelOUT(i).gradOut.wpc(j,:)).^2))/numel(modelOUT(i).gradOut.wpc(j,:));

        % write out the RMS errors
        fprintf(fid,'%s %4.2f %s %i %s %4.2f \n','RMS error for ',param(i), 'interval', j, ' : ', RmsError(i,j));
        fprintf(1,'%s %4.2f %s %i %s %4.2f \n','RMS error for ',param(i), 'interval', j, ' : ', RmsError(i,j))

    end
    MeanRmsError(i)=mean(RmsError(i,:));
    fprintf(fid,'%s %4.2f %s %4.2f \n','RMS error for ',param(i), 'for the entire layer is ',MeanRmsError(i));
    fprintf(1,'%s %4.2f %s %4.2f \n','RMS error for ',param(i), 'for the entire layer is ',MeanRmsError(i))
    fprintf(1,'%s %5.2f %5.2f\n','Phi Range is ',PHIrange);
     
    close;  % closes Tsunami_InvVelModel_V3p6 figures  get rid of close if you want those figures
    
end
% write out the RMS errors

%     fprintf(fid,'%4.2f \n',MaxFroude);
%     fprintf(fid,'%s ,','avg. Froude: ');
%     fprintf(fid,'%4.2f \n',AvgFroude);
%     fprintf(fid, '%s %5.1f %s \n','50% of layer forms in' ,gradOut.hittime(min(find(gradOut.thickness>0.5*siteInfo.depositThickness))), 'seconds');

%% Speed and Froude number plot
%close all;clc; Mark closes all figures and clear the command line for
%running in cells
subplot(1,2,1)
plot(param,AvgSpeed);
box on; grid on;


xlabel('Parameter value');
ylabel('AvgSpeed (m/s)');
subplot(1,2,2)
plot(param,AvgFroude);
box on; grid on;
xlabel('Parameter value');
ylabel('AvgFroude');
% change if you want to resize figures
set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
    'position',[1 1 6 5], 'PaperPosition', [0 0 6 5])

% change -r300 to up the dpi; e.g., -r600 is 600 dpi
% to change file type to editable in illustrator change '-djpeg' to
% '-depsc' or '-dill'
if Save.ALL==1
    print('-r300','-djpeg',['Results_',...
        char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf'])
end
%% Stack plot: Distribution
%close all;clc; Mark closes all figures and clear the command line for
%running in cells
max_shift=50;  % change if distributions are overlapping vert.  default 25
%Plot: Image with stats
figure('name',['Plot: Image with stats: ' sname '_' SedSize.Tname]); hold on;
for tt=1:length(SedSize.phi)
    temp=0:max_shift:(length(SedSize.wt(1,:))-1)*max_shift;
    ttemp(tt,:)=temp;
end
% Bruce changed plotting to data marked with dots and model a line
if length(SedSize.Sample_ID)>1
    plot(SedSize.phi,fliplr(fliplr(SedSize.wt)*100+ttemp),'.')%flipped to make lengend work better
    for i=1:length(param)
        if i==1;
            plot(SedSize.phi,(modelOUT(i).gradOut.wpc)'+ttemp,'m')%flipped to make lengend work better
        elseif i==2
            plot(SedSize.phi,(modelOUT(i).gradOut.wpc)'+ttemp,'c')%flipped to make lengend work better
        else
            plot(SedSize.phi,(modelOUT(i).gradOut.wpc)'+ttemp,'k')%flipped to make lengend work better
        end
    end
    title([sname ': ' SedSize.Tname])
    ylim([0 (length(SedSize.Sample_ID))*max_shift])
    if length(SedSize.Sample_ID)<15
        set(gca,'ytick',[0:max_shift/2:(length(SedSize.Sample_ID))*max_shift],'yticklabel',[0 max_shift/2],'Ygrid','on')
    else
        set(gca,'ytick',[0:max_shift:(length(SedSize.Sample_ID))*max_shift],'yticklabel',[],'Ygrid','on')
    end
    xlabel('Grain Size [phi]')
    ylabel('weight %')
    t= legend(SedSize.range,'orientation','vertical','location','eastoutside');
    set(get(t, 'title'), 'String' , 'Depth [cm]');
    grid on
    box on
    % sets display and print size  of figure
    set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
        'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

    if Save.ALL==1
        %print('-r200','-djpeg',['Stack_',...
            print('-r600','-dill',['Stack_',...
            char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf'])
    end
end
%%
% looking at concentration profiles
Cfig=0;
if Cfig==1
    figure
    plot(modelOUT(1).details.C,modelOUT(1).details.z)
    figure
    semilogx(modelOUT(1).details.C,modelOUT(1).details.z);xlim([0,0.01])
end
%%
% plotting distributions observed together, modeled distribution together
% plot observed distributions
ObsDist=1;
if ObsDist==1
    figure
    plot(SedSize.phi,fliplr(fliplr(SedSize.wt)*100))
    title([sname ': ' SedSize.Tname ' Observed Distributions'])
    ylim([0 30]) % default is 25 for Wt. percent, can change
   % if length(SedSize.Sample_ID)<15
   %     set(gca,'ytick',[0:max_shift/2:(length(SedSize.Sample_ID))*max_shift],'yticklabel',[0 max_shift/2],'Ygrid','on')
   % else
   %    set(gca,'ytick',[0:max_shift:(length(SedSize.Sample_ID))*max_shift],'yticklabel',[],'Ygrid','on')
   % end
    xlabel('Grain Size [phi]')
    ylabel('weight %')
    t= legend(SedSize.range,'orientation','vertical','location','eastoutside');
    set(get(t, 'title'), 'String' , 'Depth [cm]');clear figures
    
    box on
    % sets display and print size  of figure
    set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
        'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

    if Save.ALL==1
        print('-r600','-dill',['Observed_Dists_',...
            char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf'])
    end
end

%%
% plot modeled distributions
ModDist=0;
if ModDist==1
    figure
    plot(SedSize.phi,flipud(modelOUT.gradOut.wpc))
    title([sname ': ' SedSize.Tname ' Modeled Distributions'])
    ylim([0 25])
    xlabel('Grain Size [phi]')
    ylabel('% weight')
    t= legend(SedSize.range,'orientation','vertical','location','eastoutside');
    set(get(t, 'title'), 'String' , 'Depth [cm]');
    box on
    % sets display and print size  of figure
    set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
        'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

    if Save.ALL==1
        print('-r600','-dill',['Modeled_Dists_',...
            char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf'])
    end
end

%%
% plot deposit formation history
LayerForm=1;
if LayerForm==1
    figure
    semilogx(gradingD.hittime,gradingD.thickness)
    title([sname ': ' SedSize.Tname ' Layer Formation ' num2str(Drange(1)),'-',num2str(Drange(2)) ' cm'])
    ylim([0 max(gradingD.thickness)])
    xlabel('Time [s]')
    ylabel('Thickness [m]')
   
    % sets display and print size  of figure
    set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
        'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

    if Save.ALL==1
        print('-r600','-dill',['Layer-Formation_',...
            char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf'])
    end
end
