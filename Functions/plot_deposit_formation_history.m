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
    print('-r600','-depsc', fullfile(fpath, ['Layer-Formation_',...
        char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf.eps']))
end