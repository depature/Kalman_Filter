clear;
load("X.mat");
load("Z.mat");
load("Ukf.mat");
load("kf.mat");
load("ekf.mat");

figure
hold on;
box on;
plot(X(1,:),X(3,:),'-K');
plot(Z(1,:),Z(2,:),'-b.');
plot(Xkf(1,:),Xkf(3,:),'-r+');
plot(Xekf(1,:),Xekf(3,:),'-y+');
plot(Xukf(1,:),Xukf(3,:),'-g+');
legend("真实轨迹","观测轨迹","kf","ekf","ukf");
xlabel('横坐标X/m');
ylabel('纵坐标Y/m');
title("delta_w=0.01")