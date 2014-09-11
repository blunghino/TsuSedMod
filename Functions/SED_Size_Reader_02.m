function [SedSize,Bulk,TrenchIDs]=SED_Size_Reader_02(varargin)
%Read in information from SED_Size in Mark Buckley format 
%output SedData structure of relevent information
%columns contain information on SedData.Tname
%read in model inputs from excel file
if any(strcmpi(varargin,'infile'))==1;
    indi=strcmpi(varargin,'infile');
    ind=find(indi==1);
    fname=varargin{ind+1};

    isFile=exist(fname,'file');
    if isFile==0
        errordlg([fname, ' not found in Matlab path, '...
            'make sure the name is correct and try again.']);
    else
        [data,txt]=xlsread(fname,'SED_Size');
    end
else
    [fname, pname] = uigetfile('*.xls', 'Pick a .xls file with Model Parameters');
    [data,txt]=xlsread([pname,fname],'SED_Size');
end
%Find data turned on (over each column of wt in .xls place 1 for On on 0 for off)
ON= data(1,:)==1;
OFF= data(1,:)~=1;

%Get trench name
tname=txt(strcmpi(txt(:,2),'Trench Name'),ON);
%Get trench divitions: Based on trench number or letter
[unique_tname]=unique(tname);

temp=txt(strcmpi(txt(:,2),'Trench Name'),:);
temp(OFF)={'BLANK'};

if any(strcmpi(varargin,'Trench_ID'))==1;
    indi=strcmpi(varargin,'Trench_ID');
    ind=find(indi==1);
    clear unique_tname
    unique_tname=varargin{ind+1};
end
TrenchIDs(:,1)=unique_tname;

for i=1:length(unique_tname)
    SedSize(i).columns=strcmpi(temp,unique_tname(i));
    if any(strcmpi(varargin,'Drange'))==1;
        indi=strcmpi(varargin,'Drange');
        ind=find(indi==1);
        Drange=varargin{ind+1};
        SedSize(i).columns(data(strmatch('Max Depth (cm)',txt(:,2)),:)>max(Drange))=0;
        SedSize(i).columns(data(strmatch('Min Depth (cm)',txt(:,2)),:)<min(Drange))=0;
        clear TMP
    end
    if any(strcmpi(varargin,'PHIrange'))==1;
        indi=strcmpi(varargin,'PHIrange');
        ind=find(indi==1);
        PHIrange=varargin{ind+1};
        SedSize(i).rows=zeros(length(data(:,1)),1);
        SedSize(i).rows(strmatch('phi',txt(:,1)))=1;
        SedSize(i).rows(data(:,2)>max(PHIrange))=0;
        SedSize(i).rows(data(:,2)<min(PHIrange))=0;
        clear TMP
    end
    SedSize(i).Tname=char(unique_tname(i));
    SedSize(i).Sample_ID=txt(strmatch('Sample ID',txt(:,2)),SedSize(i).columns);
    SedSize(i).phi=data(SedSize(i).rows==1,2);
    
    SedSize(i).middepth=data(strmatch('Mid Depth (cm)',txt(:,2)),SedSize(i).columns);
    SedSize(i).maxdepth=data(strmatch('Max Depth (cm)',txt(:,2)),SedSize(i).columns);
    SedSize(i).mindepth=data(strmatch('Min Depth (cm)',txt(:,2)),SedSize(i).columns);
    SedSize(i).samplethickness=SedSize(i).maxdepth-SedSize(i).mindepth;
    SedSize(i).range=cell(1,length(SedSize(i).mindepth));
    for k=1:length(SedSize(i).middepth)
        SedSize(i).range(1,k)={[num2str(SedSize(i).mindepth(k)) '-' num2str(SedSize(i).maxdepth(k))]};
    end
    SedSize(i).thickness=data(strmatch('Deposit Thickness (cm)',SedSize(i).columns(1)));
    SedSize(i).xdistance=data(strmatch('Distance from shore (m)',SedSize(i).columns(1)));
    SedSize(i).zdistance=data(strmatch('Elevation (m)',txt(:,2)),SedSize(i).columns(1));
    
    %Make sure wt is normalized and rewrite
    clear k
    SedSize(i).wt=data(SedSize(i).rows==1,SedSize(i).columns);
    diff=zeros(1,length(SedSize(i).wt(1,:))); %Initialize matrix for normalization check
    for k=1:length(SedSize(i).wt(1,:))
        if sum(SedSize(i).wt(:,k))<10
            diff(i)=sum(SedSize(i).wt(:,k))-1;%if wt is fractional
        else
            diff(i)=(sum(SedSize(i).wt(:,k))-100)/100;%if wt is %
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
    if SedSize(i).phi(length(SedSize(i).phi))<SedSize(i).phi(1); val95=.95; val98=.02; 
    else val95=.05; val98=.02; 
    end 
    r=SedSize(i).phi(   Bulk.cumsum(:,i)==nearest(Bulk.cumsum(:,i),val95,'max')   );
    Bulk.D95(i,1)=r(1);
    clear r
    r=SedSize(i).phi(   Bulk.cumsum(:,i)==nearest(Bulk.cumsum(:,i),val98,'max')  );
    Bulk.D98(i,1)=r(1);
    clear r
end









