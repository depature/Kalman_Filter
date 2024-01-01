function ProcessFrame
mov=VideoReader("example.avi");
totalFrame=mov.NumFrames;
figure("Name",'show the movie');
for i=1:totalFrame
    frame=readFrame(mov);
    bmpName=strcat('workdata\imageFram',int2str(i),'.bmp');
    imwrite(frame,bmpName,'bmp');
    pause(0.02); 
end



