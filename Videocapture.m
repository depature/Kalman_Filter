clc;
clear;
close all;
fig = figure ;
aviobj = VideoWriter('example');
obj=videoinput('winvideo',1,'YUY2_640x480'); 
aviobj.FrameRate=30;
%预览视频 
preview(obj);                 
% 设置视频录制的帧数（时间），以便让录制停止 
T=100; 
k=0;
open(aviobj);
while (k<T) 
    %捕获图像并显示在左边小窗口中 
    frame=getsnapshot(obj);  
    subplot(1,2,1) 
    imshow(frame); 
     
    % 转成彩色,显示在右边，这个frame就可以按照自己意愿处理了 
    frameRGB=ycbcr2rgb(frame); 
    writeVideo(aviobj,frameRGB);
    subplot(1,2,2); 
    imshow(frameRGB); 
     
    % 序列自增 
    k=k+1;
end 
% 关闭avi对象，同时将截取的图像统一写入avi文件中 
close(aviobj);  
%删除对象 
delete(obj);  