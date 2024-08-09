[N, E] = getNE();
xy = N(:,2:3);
x = xy(:, 1);
y = xy(:, 2);
% z = xy(:, 3);
U = getU();
% U1 = getU1();
load('up.mat')
% u = ones(7745, 2);
u_abaqus = U(:, 2:3);
% u_abaqus = u;
% u_abaqus1 = U1(:, 2:4);
d1 = 1;
d2 = 2;
d3 = 3;
f = 100;
c = u_abaqus(:, d1);
c_p = u(:, d1);
l = u_abaqus(:, d2);
l_p = u(:, d2);
% m = u_abaqus(:, d3);
% m_p = u(:, d3) / f;
load('ii.mat')

% ii = [];
% 
% for e = 1:length(E)
%     i = E(e,2:5);
%     index = [1; 2; 3; 4];    
%     ii = [ii i']; 
% end
x1 = x(ii);
y1 = y(ii);
% z1 = z(ii);
% z1 = z(ii);
c1 = c(ii);
cp1 = c_p(ii);
c2 = l(ii);
cp2 = l_p(ii);
% c3 = m(ii);
% cp3 = m_p(ii);

figure(1);
patch(x1, y1, c1, 'FaceColor','interp');
shading interp;
% set(gcf,'unit','centimeters','position',[10,5,30,15]);
colormap(jet)
% hold off
% view([1,0,0])
colorbar();
% colorbar('horiz');
xlabel('x')
ylabel('y')
% zlabel('z')
title(strcat('FEM:u'))
xlim([-20 20])
ylim([-20 20])
% axis equal

figure(2);
patch(x1, y1, cp1, 'FaceColor','interp');
shading interp;
% set(gcf,'unit','centimeters','position',[10,5,30,15]);
colormap(jet)
% hold off
% view([1,0,0])
colorbar();
xlabel('x')
ylabel('y')
% zlabel('z')
title(strcat('PINN:u'))
% xlim([-20, 20])
% ylim([-20, 20])
% axis equal

figure(3);
patch(x1, y1, abs(cp1-c1), 'FaceColor','interp');
shading interp;
colormap(jet)
% view([1,0,0])
colorbar();
xlabel('x')
ylabel('y')
title(strcat('Abs error:u'))
axis([-20 20 -20, 20]) 
% xlim([-20, 20])
% ylim([-20, 20])
% axis equal

figure(4);
patch(x1, y1, c2, 'FaceColor','interp');
shading interp;
% set(gcf,'unit','centimeters','position',[10,5,30,15]);
colormap(jet)
% hold off
% view([1,0,0])
colorbar();
xlabel('x')
ylabel('y')
% zlabel('z')
title(strcat('FEM:v'))
% xlim([-20, 20])
% ylim([-20, 20])
axis([-20 20 -20, 20]) 
% axis equal

figure(5);
patch(x1, y1, cp2, 'FaceColor','interp');
shading interp;
% set(gcf,'unit','centimeters','position',[10,5,30,15]);
colormap(jet)
% hold off
% view([1,0,0])
colorbar();
xlabel('x')
ylabel('y')
% zlabel('z')
title(strcat('PINN:v'))
% xlim([-20, 20])
% ylim([-20, 20])
axis([-20 20 -20, 20]) 
% axis equal

figure(6);
patch(x1, y1, abs(cp2-c2), 'FaceColor','interp');
shading interp;
colormap(jet)
% view([1,0,0])
colorbar();
xlabel('x')
ylabel('y')
title(strcat('Abs error:v'))
% xlim([-20, 20])
% ylim([-20, 20])
axis([-20 20 -20, 20]) 
% axis equal