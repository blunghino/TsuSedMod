
function [gradOut]=grading2(ID,phi,wt,midint)
%calculate grain size statistics
for i=1:length(wt(1,:))
[m1(i),stdev(i),m3(i),m4(i),fwmedian(i),...
    fwmean(i),fwsort(i),fwskew(i),fwkurt(i)]...
=sedstats(phi,wt(:,i)');
p(i,:)=phi;
s(i,:)=wt(:,i)';
wpc(i,:)=wt(:,i)'*100;
end

set(0,'units','pixels');ssize=get(0,'screensize');
lp=round(ssize(3)*0.2);
bp=round(ssize(4)*0.1);
wp=round(ssize(3)*0.6);
hp=round(ssize(4)*0.8);

hfig=figure('position',[lp bp wp hp]);

titler={[ID,': Grain Statistics, 1st Moment for layers'];...
    [ID,': Grain Statistics, Standard Deviation for layers'];...
    [ID,': Grain Statistics, FW mean for layers'];...
    [ID,': Grain Statistics, FW sorting for layers'];...
    [ID,': Grain Statistics, FW Skewness for layers'];...
    [ID,': Grain Statistics, FW Kurtosis for layers']};

xlabelr={'1st Moment (phi)';...
    'Standard Deviation (phi)';...
    'FW Mean (phi)';...
    'Sorting (phi)';...
    'Skewness';...
    'Kurtosis'};


ylabelr={'Midpoint of Layer (m)';...
    'Midpoint of Layer (m)';...
    'Midpoint of Layer (m)';...
    'Midpoint of Layer (m)';...
    'Midpoint of Layer (m)';...
    'Midpoint of Layer (m)'};

gradD.list1=uicontrol('style','popup',...
    'units','normalized','position',[0.1 0 0.35 0.05],...
    'string',titler,'callback',@updatePlot);

gradD.ax1=axes;
gradD.p1=plot(m1,midint,'.-','linewidth',2);
gradD.title=title([ID, ': Grain Statistics, 1st Moment for layers'],...
    'fontsize',16);
gradD.xlabel=xlabel('1st Moment (phi)','fontsize',14);
gradD.ylabel =ylabel('Midpoint of Layer (m)','fontsize',14);

pos=get(gradD.ax1,'position');
pos(1)=pos(1)+0.2*pos(3);
pos(2)=pos(2)+0.1*pos(4);
pos(3)=0.6*pos(3);
pos(4)=0.8*pos(4);
set(gradD.ax1,'fontsize',12)

gradD.m1=m1;
gradD.stdev=stdev;
gradD.fwmean=fwmean;
gradD.fwsort=fwsort;
gradD.fwskew=fwskew;
gradD.fwkurt=fwkurt;
gradD.midint=midint;
gradD.titler=titler;
gradD.xlabelr=xlabelr;
gradD.ylabelr=ylabelr;

gradOut.midint=midint;
gradOut.m1=m1;
gradOut.stdev=stdev;
gradOut.fwmean=fwmean;
gradOut.fwsort=fwsort;
gradOut.fwskew=fwskew;
gradOut.fwkurt=fwkurt;
gradOut.p=p;
gradOut.s=s;
gradOut.wpc=wpc;
guidata(hfig,gradD);

%%%% GUI callback %%-----------------------------------------
function updatePlot(hfig,eventdata,handles)

gradD=guidata(hfig);
gradD.dtype=get(gradD.list1,'value');

switch gradD.dtype
    case 1
        set(gradD.p1,'xdata',gradD.m1);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
        
    case 2
        set(gradD.p1,'xdata',gradD.stdev);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
    case 3
        set(gradD.p1,'xdata',gradD.fwmean);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
    case 4
        set(gradD.p1,'xdata',gradD.fwsort);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
    case 5
        set(gradD.p1,'xdata',gradD.fwskew);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
    case 6
        set(gradD.p1,'xdata',gradD.fwkurt);
        set(gradD.p1,'ydata',gradD.midint);
        set(gradD.ax1,'xscale','linear');
end

set(gradD.title,'string',gradD.titler{gradD.dtype});
set(gradD.xlabel,'string',gradD.xlabelr{gradD.dtype});
set(gradD.ylabel,'string',gradD.ylabelr{gradD.dtype});