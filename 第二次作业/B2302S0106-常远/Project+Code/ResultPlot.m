clc;
close all;
%% 数据读取
m_ref = out.simout(:, 1);
m_wls1 = out.simout(:, 2);
m_wls2 = out.simout(:, 3);
m_wls3 = out.simout(:, 4);
m_ls = out.simout(:, 5);
slope_ref = out.simout(:, 6);
slope_wls1 = out.simout(:, 7);
slope_wls2 = out.simout(:, 8);
slope_wls3 = out.simout(:, 9);
slope_ls = out.simout(:, 10);
time = out.simout(:, 11);

%% 绘图
wordsize = 10;
% 质量估计
figure(1);
set(gcf,'Units','centimeters', 'position',[1 5 12 12]);
set(gca, 'FontSize', wordsize, 'FontName', 'Times', 'position',[.15 .4 .8 .4]);
plot(time, m_ref, 'k', 'linewidth', 1.2);
hold on;
plot(time, m_wls1, 'r', 'linewidth', 1.2);
hold on;
plot(time, m_wls2, 'b', 'linewidth', 1.2);
hold on;
plot(time, m_wls3, 'color', [34,139,34]/255, 'linewidth', 1.2);
hold on;
plot(time, m_ls, 'color', [218,165,32]/255, 'linewidth', 1.2);
legend('实际质量', 'WLSM: Huber函数更新', 'WLSM: Tukey biweight函数更新', 'WLSM: 核函数更新', 'LSM');
title('基于不同最小二乘方法的质量估计结果');
xlabel('时间(秒)');
ylabel('质量(千克)');
% 坡度估计
figure(2);
set(gcf,'Units','centimeters', 'position',[15 5 12 12]);
set(gca, 'FontSize', wordsize, 'FontName', 'Times', 'position',[.1 .4 .8 .4]);
plot(time, slope_ref, 'k', 'linewidth', 1.2);
hold on;
plot(time, slope_wls1, 'r', 'linewidth', 1.2);
hold on;
plot(time, slope_wls2, 'b', 'linewidth', 1.2);
hold on;
plot(time, slope_wls3, 'color', [34,139,34]/255, 'linewidth', 1.2);
hold on;
plot(time, slope_ls, 'color', [218,165,32]/255, 'linewidth', 1.2);
legend('实际坡度', 'WLSM: Huber函数更新', 'WLSM: Tukey biweight函数更新', 'WLSM: 核函数更新', 'LSM');
title('基于不同最小二乘方法的坡度估计结果');
xlabel('时间(秒)');
ylabel('坡度(度)');

%% 数据统计
% 质量估计结果的AAE
AAE_m_wls1 = mean(abs(m_ref - m_wls1));
AAE_m_wls2 = mean(abs(m_ref - m_wls2));
AAE_m_wls3 = mean(abs(m_ref - m_wls3));
AAE_m_ls = mean(abs(m_ref - m_ls));
% 坡道估计结果的AAE
AAE_slope_wls1 = mean(abs(slope_ref - slope_wls1));
AAE_slope_wls2 = mean(abs(slope_ref - slope_wls2));
AAE_slope_wls3 = mean(abs(slope_ref - slope_wls3));
AAE_slope_ls = mean(abs(slope_ref - slope_ls));





