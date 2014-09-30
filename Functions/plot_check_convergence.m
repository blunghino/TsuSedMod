close all
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2.25 scrsz(4)/1.75]);
ax1 = subplot(2,1,1);
hold on
ax2 = subplot(2,1,2);
hold on
c = ['r', 'g', 'b'];
for ii=1:length(modelOUT);
    axes(ax1);
    h1(ii) = plot(modelOUT(ii).details.offa, c(ii));
    axes(ax2);
    h2(ii) = plot(modelOUT(ii).details.ustrca, c(ii));
end
info = modelOUT(1).siteInfo.matIn;
suptitle = char(strcat(info.Trench_ID(1), ', ', num2str(info.Drange(1)),...
                '-', num2str(info.Drange(2)), 'cm'));
suplabel(suptitle, 't');
labels = cellfun(@num2str, num2cell(param), 'UniformOutput', 0);
axes(ax1);
legend(h1, labels);
title('how far total suspended load is off from load required to create deposit');
ylabel('offa');
axes(ax2);
legend(h2, labels);
title('U * C');
ylabel('ustrca ');
xlabel('N iterations');
shg;
for jj=1:2;
    figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2.25 scrsz(4)/1.75]);
    ax1 = subplot(3,1,1);
    ax2 = subplot(3,1,2);
    ax3 = subplot(3,1,3);
    for ii=1:length(modelOUT);
        eval(['axes(ax',num2str(ii),');']);
        hold on
        if jj==1
            C = modelOUT(ii).details.ssfra';
            C_label = 'ss concentration';
        elseif jj==2
            C = modelOUT(ii).details.fra';
            C_label = 'bed concentration';
        end
        N = length(C(1,:));
        p = pcolor(linspace(1, N, N), modelOUT(ii).datain.phi', C);
        shading flat
        cbar = colorbar;
        cbar_title = get(cbar, 'Title');
        set(cbar_title, 'String', C_label);
        title(['Mannings n = ', labels(ii)]);
        ylabel('phi'); 
    end
    xlabel('N iterations')
    suplabel(suptitle, 't');
    shg;
end