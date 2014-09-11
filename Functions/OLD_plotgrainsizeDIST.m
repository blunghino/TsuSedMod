function plotgrainsizeDIST(SedSize,varargin)

NoGaps=0;
ShowStats=0;
ShowLine=1;
cmap=flipud(gray);
lcolor='w';
lwidth=2;
xxlim=[];
yylim=[];
cmax=[];
LFullLayer=0;
ShowCmap=1;
OverLay=0;
SetMinDepth=999;
fontsize=10;
Use_mm=0;

if any(strcmpi(varargin,'NoGaps'))==1;
    indi=strcmpi(varargin,'NoGaps');
    ind=find(indi==1);
    NoGaps=varargin{ind+1};
end
if any(strcmpi(varargin,'ShowStats'))==1;
    indi=strcmpi(varargin,'ShowStats');
    ind=find(indi==1);
    ShowStats=varargin{ind+1};
end

if any(strcmpi(varargin,'ShowLine'))==1;
    indi=strcmpi(varargin,'ShowLine');
    ind=find(indi==1);
    ShowLine=varargin{ind+1};
end

if any(strcmpi(varargin,'ShowCmap'))==1;
    indi=strcmpi(varargin,'ShowCmap');
    ind=find(indi==1);
    ShowCmap=varargin{ind+1};
    lcolor='k';
elseif ShowCmap==0
    lcolor='k';
end

if any(strcmpi(varargin,'cmap'))==1;
    indi=strcmpi(varargin,'cmap');
    ind=find(indi==1);
    cmap=varargin{ind+1};
end

if any(strcmpi(varargin,'lcolor'))==1;
    indi=strcmpi(varargin,'lcolor');
    ind=find(indi==1);
    lcolor=varargin{ind+1};
end

if any(strcmpi(varargin,'lwidth'))==1;
    indi=strcmpi(varargin,'lwidth');
    ind=find(indi==1);
    lwidth=varargin{ind+1};
end

if any(strcmpi(varargin,'SetMinDepth'))==1;
    indi=strcmpi(varargin,'SetMinDepth');
    ind=find(indi==1);
    SetMinDepth=varargin{ind+1};
end
if any(strcmpi(varargin,'fontsize'))==1;
    indi=strcmpi(varargin,'fontsize');
    ind=find(indi==1);
    fontsize=varargin{ind+1};
end
if any(strcmpi(varargin,'SetXlim'))==1;
    indi=strcmpi(varargin,'setXlim');
    ind=find(indi==1);
    xxlim=varargin{ind+1};
end

if any(strcmpi(varargin,'SetYlim'))==1;
    indi=strcmpi(varargin,'setYlim');
    ind=find(indi==1);
    yylim=varargin{ind+1};
end

if any(strcmpi(varargin,'SetCmax'))==1;
    indi=strcmpi(varargin,'setCmax');
    ind=find(indi==1);
    cmax=varargin{ind+1};
end

if any(strcmpi(varargin,'LFullLayer'))==1;
    indi=strcmpi(varargin,'LFullLayer');
    ind=find(indi==1);
    LFullLayer=varargin{ind+1};
end
if any(strcmpi(varargin,'VertRef'))==1;
    indi=strcmpi(varargin,'VertRef');
    ind=find(indi==1);
    VertRef=varargin{ind+1};
else
    display('No VertRef set: Using deposit base!')
end

if any(strcmpi(varargin,'mm'))==1;
    Use_mm=1;
end


if any(strcmpi(varargin,'OverLay'))==1;
    indi=strcmpi(varargin,'OverLay');
    ind=find(indi==1);
    OverLay=varargin{ind+1};
    
    NoGaps=0;
    ShowStats=0;
    ShowLine=1;
    cmap=flipud(gray);
    lcolor='w';
    lwidth=2;
    xxlim=[];
    yylim=[];
    cmax=[];
    LFullLayer=0;
    ShowCmap=0;
end


%row=phi
%columns=samples

%SedSize

%%CAUTION SWITCH TO mm, but keep "phi" as variable name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Use_mm==1
phi(1,:)=phi2mm(SedSize.phi);
end
%%%%%%%%%%%%%%%%%%%%%%

if length(SedSize.maxdepth)>1;
maxdepth(:,1)=SedSize.maxdepth;
mindepth(:,1)=SedSize.mindepth;
midint(:,1)=SedSize.middepth;
samplethickness(:,1)=maxdepth-mindepth;
if max(abs(samplethickness))<1;
    maxdepth=maxdepth*100;
    mindepth=mindepth*100;
    midint=midint*100;
    samplethickness=samplethickness*100;
end

if SetMinDepth~=999;
    mmindepth=min(mindepth);
    maxdepth=maxdepth-mmindepth+SetMinDepth;
    mindepth=mindepth-mmindepth+SetMinDepth;
    midint=midint-mmindepth+SetMinDepth;
end

if isempty(yylim)==1;
    yylim=[min(mindepth) max(maxdepth)];
end
if isempty(xxlim)==1;
    xxlim=[min(phi) max(phi)];
end

slen=length(midint);
plen=length(phi);

lmax(:,1)=ones(slen,1);
lmax(:,1)=min(samplethickness);

s=zeros(slen+1,plen);
try
    s(1:slen,:)=SedSize.wt;
catch
    s(1:slen,:)=SedSize.wt';
end

%normalize s
for k=1:length(midint)
    s(k,:)=s(k,:)/sum(s(k,:));
end
if isempty(cmax)==1;
    cmax=max(max(s))+.01;
elseif cmax>1;
    cmax=cmax/100;
end
mm=1;
hold on; box on;
if ShowCmap==1
    if mm==0;
        if NoGaps==1
            pcolor(phi+(abs(phi(1)-phi(2))/2),[mindepth ;max(maxdepth)],s)
        else
            for kkk=1:length(mindepth)
                pcolor(phi-(abs(phi(1)-phi(2))/2),...
                    [mindepth(kkk) maxdepth(kkk)],[s(kkk,:);s(kkk,:)])
            end
        end
    else
        if NoGaps==1
            xx=zeros(size(phi));
            xx(2:length(phi))=abs(diff(phi)/2);
            pcolor(phi+xx,[mindepth ;max(maxdepth)],s);
        else
            for kkk=1:length(mindepth)
                xx=zeros(size(phi));
                xx(2:length(phi))=abs(diff(phi)/2);
                pcolor(phi+xx,...
                    [mindepth(kkk) maxdepth(kkk)],[s(kkk,:);s(kkk,:)])
            end
        end
        
    end

    colormap(cmap); shading flat; hold on
end
if ShowStats==1
    fwmean(1,:)=SedSize.gradOut.fwmean;
    fwsort(1,:)=SedSize.gradOut.fwsort;
    fwskew(1,:)=SedSize.gradOut.fwskew;
    plot(fwmean,midint,...
        '-ro',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r',...
        'MarkerSize',3)
    plot(fwsort,midint,...
        '-bo',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','b',...
        'MarkerSize',3)
    plot(fwskew,midint,...
        '-go',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','g',...
        'MarkerFaceColor','g',...
        'MarkerSize',3)
    %     legend('%','fwmean','fwsort','fwskew','orientation','horizontal','location','bestoutside')
end

if ShowLine==1
    for kk=1:slen;
        if sum(s(kk,:))~=0
            if LFullLayer==1
                lmax(kk)=samplethickness(kk);
            end
            if strcmpi(VertRef,'top')==1;
                plot(phi,maxdepth(kk)-((s(kk,:)/cmax)*lmax(kk)),'color',lcolor,'linewidth',lwidth);
                set(gca,'YDir','reverse')
            else
                plot(phi,((s(kk,:)/cmax)*lmax(kk))+mindepth(kk),'color',lcolor,'linewidth',lwidth);
            end
        end
    end
end

%Set limits
xlim(xxlim)
ylim(yylim)
set(gca,'ytick',round(yylim(1)):1:round(yylim(2)))
%Set labels
if Use_mm==1
   xlabel('Grain Size (mm)') 
else
xlabel('Grain Size (phi)')
end
if strcmpi(VertRef,'top')==1;
    ylabel('Depth (cm)')
else
    ylabel('Elevation from Base (cm)')
end
set(gca,'fontsize',fontsize)
set(get(gca,'XLabel'),'fontsize',fontsize)
set(get(gca,'YLabel'),'fontsize',fontsize)
if ShowCmap==1
    %Colorbar
    caxis([0 cmax])
    t = colorbar( 'peer',gca);
    set(get(t, 'title'), 'String' , 'Weight %');
    set(t,'yticklabel',get(t,'ytick')*100);
end

box on;

if OverLay==1
    hold off;
    plot(phi,s(1:slen,:),'linewidth',lwidth);
    set(gca,'yticklabel',get(gca,'ytick')*100);
    if Use_mm==1
        xlabel('Grain Size (mm)')
    else
        xlabel('Grain Size (phi)')
    end
    ylabel('Weight %')
    box on;
end
set(gca,'fontsize',fontsize)
set(get(gca,'XLabel'),'fontsize',fontsize)
set(get(gca,'YLabel'),'fontsize',fontsize)
else%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(xxlim)==1;
    xxlim=[min(phi) max(phi)];
end
%normalize s
plen=length(phi);
s=zeros(2,plen);
try
    s(1,:)=SedSize.wt;
    s(2,:)=SedSize.wt;
catch
    s(1,:)=SedSize.wt';
    s(2,:)=SedSize.wt';
end
s=s./sum(s(1,:));

if isempty(cmax)==1;
    cmax=max(max(s))+.01;
elseif cmax>1;
    cmax=cmax/100;
end

YLIM=cmax*100;

hold on; box on;
if ShowCmap==1
    pcolor(phi-(abs(phi(1)-phi(2))/2),[0;YLIM],s)
    colormap(cmap); shading flat; hold on
end
if ShowCmap==1
    %Colorbar
    caxis([0 cmax])
    t = colorbar('peer',gca);
    set(get(t, 'title'), 'String' , 'Weight %');
    set(t,'yticklabel',get(t,'ytick')*100);
end
if ShowStats==1
    fwmean(1,:)=SedSize.gradOut.fwmean;
    fwsort(1,:)=SedSize.gradOut.fwsort;
    fwskew(1,:)=SedSize.gradOut.fwskew;
    plot(fwmean,YLIM/2,...
        '-ro',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r',...
        'MarkerSize',3)
    plot(fwsort,YLIM/2,...
        '-bo',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','b',...
        'MarkerSize',3)
    plot(fwskew,YLIM/2,...
        '-go',...
        'LineWidth',lwidth,...
        'MarkerEdgeColor','g',...
        'MarkerFaceColor','g',...
        'MarkerSize',3)
    %     legend('%','fwmean','fwsort','fwskew','orientation','horizontal','location','bestoutside')
end

if ShowLine==1
        if sum(s(1,:))~=0
            plot(phi,s(1,:)*100,'color',lcolor,'linewidth',lwidth);
        end
end

%Set limits
xlim(xxlim)
ylim([0 YLIM])
set(gca,'ytick',0:2:YLIM)
%Set labels
if Use_mm==1
   xlabel('Grain Size (mm)') 
else
xlabel('Grain Size (phi)')
end
ylabel('wt %')
box on;

if OverLay==1
    hold off;
    plot(phi,s(1,:),'linewidth',lwidth);
    set(gca,'yticklabel',get(gca,'ytick')*100);
    if Use_mm==1
        xlabel('Grain Size (mm)')
    else
        xlabel('Grain Size (phi)')
    end
    ylabel('Weight %')
    box on;
end
set(gca,'fontsize',fontsize)
set(get(gca,'XLabel'),'fontsize',fontsize)
set(get(gca,'YLabel'),'fontsize',fontsize)
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end