function ProcessPixel
mov=VideoReader("example.avi");
totalFrame=mov.NumFrames;
imageLogo=imread("logo.jpg");
imageSize= imresize(imageLogo,0.25,"box");
[height width channel]=size(imageSize);
figure('Name','Processing Pixel')
for i=1:totalFrame
    frameData=readFrame(mov);
    subplot(1,2,1);
    imshow(frameData);
    xlabel('The original video');
    for ii=1:height
        for jj=1:width
            for kk=1:channel
                frameData(ii,jj,kk)=imageLogo(ii,jj,kk);


            end
        end
    end
    subplot(1,2,2);
    imshow(frameData)
    xlabel('处理过的视频');
    pause(0.02)
end

