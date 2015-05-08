figure
plot(SedSize.phi,flipud(modelOUT.gradOut.wpc))
title([sname ': ' SedSize.Tname ' Modeled Distributions'])
ylim([0 25])
xlabel('Grain Size [phi]')
ylabel('% weight')
t= legend(SedSize.range,'orientation','vertical','location','eastoutside');
try
    set(get(t, 'title'), 'String' , 'Depth [cm]');
catch
end
box on
% sets display and print size  of figure
set(gcf, 'PaperPositionMode', 'manual','PaperUnits','inches','units','inches',...
    'position',[1 1 8 10], 'PaperPosition', [1 1 4 5])

if Save.ALL==1
    print('-r600','-depsc', fullfile(fpath, ['Modeled_Dists_',...
        char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf.eps']))
end