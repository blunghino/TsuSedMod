function [SedSize,Bulk,TrenchIDs]=uniform_GS_csv_reader(varargin)
% Read in information from TsuDB Uniform GS Data format 
% output SedSize structure of relevent information
% written by Brent Lunghino, USGS, 9/2014 based on SedSize_Reader_02.m, 
% uses code from SedSize_Reader_02.m
%
% check for infile argument
if any(strcmpi(varargin,'infile'))==1;
    indi=strcmpi(varargin,'infile');
    ind=find(indi==1);
    fname=varargin{ind+1};
    isFile=exist(fname,'file');
    if isFile == 0
        errordlg([fname, ' not found in Matlab path, '...
            'make sure the name is correct and try again.']);
    end
    infile = fname;
% gui to pick input file
else
    [fname, pname] = uigetfile('*.csv', 'Pick a .csv file with Model Input Grain Size Data');
    infile = fullfile(pname, fname);
end

% suppress empty cell warning messages from csvimport subfunction
warning('off', 'all');

% read in csv file to cell array
C = csvimport(infile);

% and turn warnings back on
warning('on', 'all');

% check for empty trailing cells in imported cell array
n_cols = find(cellfun(@isempty, C(12,:)));
if ~isempty(n_cols)
    n_cols = n_cols - 1;
else
    n_cols = length(C(12,:));
end
if length(n_cols) > 1
    n_cols = n_cols(1);
end
[n_rows, ~] = size(C);

% extract data from cell array into structure
gs.id = char(C(1,2));
gs.location = char(C(2,2));
gs.sublocation = char(C(3,2));
gs.gsfileoriginal = char(C(4,2));
gs.typegs = char(C(5,2));
gs.whosgs = char(C(6,2));
gs.depth_units = char(C(8,2));
gs.bin_units = char(C(9,2));
gs.distribution_units = char(C(10,2));
gs.layer_type = cellfun(@str2num, C(11,2:n_cols));
gs.layer = cellfun(@str2num, C(12,2:n_cols));
gs.trench_name = C(13,2:n_cols);
gs.sample_id = C(14,2:n_cols);
gs.min_depth = cellfun(@str2num, C(15,2:n_cols));
gs.max_depth = cellfun(@str2num, C(16,2:n_cols));
gs.bins = cellfun(@str2num, C(18:end, 1));
gs.data = ones(n_rows-18,n_cols-1);
for ii=18:n_rows;
    gs.data(ii-17,:) = cellfun(@str2num, C(ii,2:n_cols));
end
gs.mid_depth = (gs.min_depth+gs.max_depth) / 2;
TrenchIDs(:,1) = unique(gs.trench_name); 

% get phi bins
if ~strcmp(gs.bin_units, 'phi') && ~strcmp(gs.bin_units, 'phi mid') && ~strcmp(gs.bin_units, 'mm');
    % bin units are not phi or mm
    errordlg([fname, ' Grain size bin units must be in phi to use in inverse model']);
elseif strcmp(gs.bin_units, 'mm');
    % bin units are in mm, convert to phi
    gs.phi = -log2(gs.bins);
else
    gs.phi = gs.bins;
end

% Get min_layer setting and set up filters based on layer number
if any(strcmpi(varargin, 'min_layer')) == 1;
    indi = strcmpi(varargin, 'min_layer');
    ind = find(indi == 1);
    gs.min_layer = varargin{ind+1};
else
    gs.min_layer = 1;
end
ON = gs.layer >= gs.min_layer;

% get Drange argument and update ON filter to exclude depths outside Drange
if any(strcmpi(varargin,'Drange')) == 1;
    indi = strcmpi(varargin,'Drange');
    ind = find(indi == 1);
    Drange = varargin{ind+1};
    ON(gs.max_depth > max(Drange)) = 0;
    ON(gs.min_depth < min(Drange)) = 0;
end

rows = ~isnan(gs.phi);
% get PHIrange argument and set rows filter to exclude phi bins outside of PHIrange
if any(strcmpi(varargin,'PHIrange')) == 1;
    indi = strcmpi(varargin,'PHIrange');
    ind = find(indi == 1);
    PHIrange = varargin{ind+1};
    rows(gs.phi > max(PHIrange)) = 0;
    rows(gs.phi < min(PHIrange)) = 0;
end

% for i=1 because SedSize_Reader functions for reading from excel
% spreadsheets have a for loop here. 
for i=1;
    SedSize(i).rows = rows;
    SedSize(i).columns = ON;
    SedSize(i).middepth = gs.mid_depth(ON);
    SedSize(i).Tname = char(TrenchIDs(:,1));
    SedSize(i).Sample_ID = gs.sample_id(ON);
    SedSize(i).phi = gs.phi(rows);    
    SedSize(i).middepth = gs.mid_depth(ON);
    SedSize(i).maxdepth = gs.max_depth(ON);
    SedSize(i).mindepth = gs.min_depth(ON);
    SedSize(i).samplethickness = SedSize(i).maxdepth-SedSize(i).mindepth;
    n_samples = length(SedSize(i).mindepth);
    SedSize(i).range=cell(1,n_samples);
    for k=1:n_samples;
        SedSize(i).range(1,k)={[num2str(SedSize(i).mindepth(k)) '-' num2str(SedSize(i).maxdepth(k))]};
    end
    % this data is not included in the uniform GS file csv format.
    % if needed, thickness is easily calculated using min_depth and max_depth
    SedSize(i).thickness = [];
    SedSize(i).xdistance = [];
    SedSize(i).zdistance = [];
    
    %Make sure wt is normalized and rewrite
    clear k
    SedSize(i).wt = gs.data(SedSize(i).rows, SedSize(i).columns);
    diff=zeros(1,length(SedSize(i).wt(1,:))); %Initialize matrix for normalization check
    for k=1:n_samples;
        if sum(SedSize(i).wt(:,k)) < 10
            diff(i) = sum(SedSize(i).wt(:,k)) - 1; %if wt is fractional
        else
            diff(i) = (sum(SedSize(i).wt(:,k))-100) / 100; %if wt is %
        end
        if diff(i)>.01 %Display if fraction is off by greater than .01
            display(['Not normalized: ',char(SedSize(i).Sample_ID(k))...
                ,' is not normalized. Check original data. wt has been normalized']) %PUT something better here
        end
        SedSize(i).wt(:,k)=SedSize(i).wt(:,k)./sum(SedSize(i).wt(:,k)); %Normalize to fraction sum 1
    end
    %Calculate grain size statistics using function grading2
    %gradingOut is structure with trench statistics
    SedSize(i).gradOut=grading2(SedSize(i).Tname,SedSize(i).phi,SedSize(i).wt,...
        SedSize(i).middepth/100);
    close
    %Creat new structure for use with image plots needs extra row to plot properly
    SedSize(i).ImagegradOut=SedSize(i).gradOut;
    if length(SedSize(i).Sample_ID)>1 %more then 1 vertical samples
        SedSize(i).ImagegradOut.s(length(SedSize(i).gradOut.s(:,1))+1,:)=0;%Add some zeros
    end
    
    %Sum wt for trench to look at bulk grain size
    %Weigh samples for sample thickness
    for k=1:length(SedSize(i).wt(1,:))
        SedSize(i).wwt(:,k)=SedSize(i).wt(:,k)*SedSize(i).samplethickness(k);
    end
    
    SedSize(i).Bulk.wt=sum(SedSize(i).wwt,2)/sum(sum(SedSize(i).wwt,2));
    SedSize(i).Bulk.gradOut=grading2(SedSize(i).Tname,SedSize(i).phi,SedSize(i).Bulk.wt,1);
    close
    Bulk.s(:,i)=[SedSize(i).Bulk.gradOut.s]';
    Bulk.fwmean(i,1)=SedSize(i).Bulk.gradOut.fwmean;
    Bulk.fwsort(i,1)=SedSize(i).Bulk.gradOut.fwsort;
    Bulk.fwskew(i,1)=SedSize(i).Bulk.gradOut.fwskew;
    Bulk.stdev(i,1)=SedSize(i).Bulk.gradOut.stdev;
    Bulk.fwkurt(i,1)=SedSize(i).Bulk.gradOut.fwkurt;
    Bulk.cumsum(:,i)=cumsum(Bulk.s(:,i));
    if SedSize(i).phi(length(SedSize(i).phi)) < SedSize(i).phi(1); 
        val95=.95; 
        val98=.02; 
    else
        val95=.05; 
        val98=.02;
    end 
    r=SedSize(i).phi(   Bulk.cumsum(:,i)==nearest(Bulk.cumsum(:,i),val95,'max')   );
    Bulk.D95(i,1)=r(1);
    clear r
    r=SedSize(i).phi(   Bulk.cumsum(:,i)==nearest(Bulk.cumsum(:,i),val98,'max')  );
    Bulk.D98(i,1)=r(1);
    clear r
end