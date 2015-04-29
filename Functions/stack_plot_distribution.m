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
            print('-r600','-depsc', fullfile(fpath, ['Stack_',...
            char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf.eps']))
    end
end