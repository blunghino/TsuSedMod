for i = 1:length(param)
    AvgSpeed(i,1)=modelOUT(i).results.AvgSpeed;
    AvgFroude(i,1)=modelOUT(i).results.AvgFroude;
end

subplot(1,2,1)
    
plot(param, AvgSpeed);
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
    print('-r300','-djpeg', fullfile(fpath, ['Results_',...
        char(SedSize.Tname),'_',num2str(Drange(1)),'-',num2str(Drange(2)),'cm_gelf.jpg']))
end