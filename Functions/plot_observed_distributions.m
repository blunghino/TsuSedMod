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
try
    set(get(t, 'title'), 'String' , 'Depth [cm]');clear figures
catch
end
box on
% sets display and print size  of figure
set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
    'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

if Save.ALL==1
    print('-r600','-depsc', fullfile(fpath, ['Observed_Dists_',...
        char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf.eps']))
end