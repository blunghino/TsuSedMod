close all
% do you have the suplabel function (available online)
have_suplabel=1;
scrsz = get(0,'ScreenSize');
n_runs = length(modelOUT);
%% figure showing U*c and ss load off vs N iterations
figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2.25 scrsz(4)/1.75]);
ax1 = subplot(2,1,1);
hold on
ax2 = subplot(2,1,2);
hold on
c = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];
for ii=1:n_runs;
    axes(ax1);
    h1(ii) = plot(modelOUT(ii).details.offa, c(ii));
    axes(ax2);
    h2(ii) = plot(modelOUT(ii).details.ustrca, c(ii));
end
info = modelOUT(1).siteInfo.matIn;
suptitle = char(strcat(info.Trench_ID(1), ', ', num2str(info.Drange(1)),...
                '-', num2str(info.Drange(2)), 'cm'));
% check that suplabel function is available
if have_suplabel==1
    try
        suplabel(suptitle, 't');
    catch err
        have_suplabel = 0;
    end
end
labels = cellfun(@num2str, num2cell(param), 'UniformOutput', 0);
axes(ax1);
ylim([-10 100])
legend(h1, labels);
title('how far total suspended load is off from load required to create deposit');
ylabel('offa');
axes(ax2);
ylim([-1 1])
legend(h2, labels);
title('U*c');
ylabel('ustrca ');
xlabel('N iterations');
shg;
%% figures: ss concentration, bed concentration, ss deviation from desired
% 1 figure made per loop
for jj=1:3;
    figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2.25 scrsz(4)/1.65]);
    % 1 axes plotted per loop
    for ii=1:n_runs;
        % set which axis to work on
        ax = subplot(n_runs,1,ii);
        hold on
        % set which parameter to plot
        if jj == 1
            C = modelOUT(ii).details.ssfra';
            C_label = 'ss concentration';
        elseif jj == 2
            C = modelOUT(ii).details.fra';
            C_label = 'bed concentration';
        elseif jj == 3
            C = modelOUT(ii).details.ssoffa';
            C_label = 'ss deviation from desired';
        end
        N = length(C(1,:));
        p = pcolor(linspace(1, N, N), modelOUT(ii).datain.phi, C);
        shading interp
        cbar = colorbar;
        try
            cbar_title = get(cbar, 'Title');
            set(cbar_title, 'String', C_label);
        catch
            cbar.Label.String = C_label;
        end
        title(['Param = ', labels(ii)]);
        ylabel('phi'); 
        try
            xlim([0, plot_check_convergence_x_zoom]);
        catch
        end
    end
    xlabel('N iterations')
    if have_suplabel == 1
        suplabel(suptitle, 't');
    end
    shg;
end