clc;clear
T=1;
N=60/T;
X=zeros(4,N);%目标真实位置、速度，
load("X.mat");
Z=zeros(1,N);
delta_w=1e-3;
Q=delta_w*diag([0.5,1]);%过程噪声均值
G=[T^2/2,0;T,0;0,T^2/2;0,T];%过程噪声驱动矩阵
R=5;%观测噪声方差
F=[1,T,0,0;0,1,0,0;0,0,1,T;0,0,0,1];%状态转移矩阵
x0=200;%观测站位置
y0=300;
Xstation=[x0,y0];%雷达站位置
%%%%%%%%%%%%%%
v=sqrtm(R)*randn(1,N);
for t=1:N
    Z(t)=Dist(X(:,t),Xstation)+v(t);%对目标观测，目标与雷达站的距离，含噪声
end
%%%%%%%%%%%%%
%UKF滤波，UT变换
L=4;%4个变量
alpha=1;
kalpha=0;
belta=2;
ramda=3-L;
for j=1:2*L+1
    Wm(j)=1/(2*(L+ramda));
    Wc(j)=1/(2*(L+ramda));
end
Wm(1)=ramda/(L+ramda);%权值Wm的初值需要另外定
Wc(1)=ramda/(L+ramda)+1-alpha^2+belta;%权值Wc的初值需要另外定
%%%%%%%%%%%%%%%%
Xukf=zeros(4,N);
Xukf(:,1)=X(:,1);%把X真值的初次数据赋给Xukf
P0=eye(4);%协方差阵初始化
for t=2:N
    xestimate=Xukf(:,t-1);%获取上一步的UKF点
    P=P0;%协方差阵
    %第一步：获得一组Sigma点集
    cho=(chol(P*(L+ramda)))';
    for k=1:L
        xgamaP1(:,k)=xestimate+cho(:,k);
        xgamaP2(:,k)=xestimate-cho(:,k);
    end
    Xsigma=[xestimate,xgamaP1,xgamaP2];%xestimate是上一步的点，相当于均值点
    %第二步：对Sigma点集进行一步预测
    Xsigmapre=F*Xsigma;%F是状态转移矩阵
    %第三步：利用第二步的结果计算均值和协方差
    Xpred=zeros(4,1);
    for k=1:2*L+1
        Xpred=Xpred+Wm(k)*Xsigmapre(:,k);%均值
    end
    Ppred=zeros(4,4);
    for k=1:2*L+1
        Ppred=Ppred+Wc(k)*(Xsigmapre(:,k)-Xpred)*(Xsigmapre(:,k)-Xpred)';%协方差矩阵
    end
    Ppred=Ppred+G*Q*G';
    %第四步：根据预测值，再一次使用UT变换，得到新的sigma点集
    chor=(chol((L+ramda)*Ppred))';
    for k=1:L
        XaugsigmaP1(:,k)=Xpred+chor(:,k);
        XaugsigmaP2(:,k)=Xpred-chor(:,k);
    end
    Xaugsigma=[Xpred XaugsigmaP1 XaugsigmaP2];
    %第五步：观测预测
    for k=1:2*L+1
        Zsigmapre(1,k)=hfun(Xaugsigma(:,k),Xstation);
    end
    %第六步：计算观测预测均值和协方差
    Zpred=0;
    for k=1:2*L+1
        Zpred=Zpred+Wm(k)*Zsigmapre(1,k);
    end
    Pzz=0;
    for k=1:2*L+1
        Pzz=Pzz+Wc(k)*(Zsigmapre(1,k)-Zpred)*(Zsigmapre(1,k)-Zpred)';
    end
    Pzz=Pzz+R;
    
    Pxz=zeros(4,1);
    for k=1:2*L+1
        Pxz=Pxz+Wc(k)*(Xaugsigma(:,k)-Xpred)*(Zsigmapre(1,k)-Zpred)';
    end
    %第七步：计算kalman增益
    K=Pxz*inv(Pzz);
    %第八步：状态和方差更新
    xestimate=Xpred+K*(Z(t)-Zpred);
    P=Ppred-K*Pzz*K';
    P0=P;
    Xukf(:,t)=xestimate;
end

%误差分析
for i=1:N
    Err_KalmanFilter(i)=Dist(X(:,i),Xukf(:,i));
end
%%%%%%%%%%%
%画图
figure
hold on ;box on
plot(X(1,:),X(3,:),'-k.');
plot(Xukf(1,:),Xukf(3,:),'-r+');
legend('真实轨迹','UKF轨迹')
figure
hold on ; box on
plot(Err_KalmanFilter,'-ks','MarkerFace','r')
save("Ukf.mat","Xukf");
%%%%%%%%%%%%%
%子函数
function d=Dist(X1,X2)
if length(X2)<=2
    d=sqrt((X1(1)-X2(1))^2+(X1(3)-X2(2))^2);
else
    d=sqrt((X1(1)-X2(1))^2+(X1(3)-X2(3))^2);
end
end
function [y]=hfun(x,xx)
y=sqrt((x(1)-xx(1))^2+(x(3)-xx(2))^2);
end