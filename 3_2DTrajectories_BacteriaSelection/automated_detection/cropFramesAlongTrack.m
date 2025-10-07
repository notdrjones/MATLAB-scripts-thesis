function [croppedFrames] = cropFramesAlongTrack(stack,track,L)
%CROPFRAMESALONGTRACK Summary of this function goes here
%   Detailed explanation goes here
N = size(track,1); % length of the track
                
%croppedFrames = uint8(L+1,L+1,N); % pre-allocate memory for speed

for i=1:N
    T = track(i,1);
    x = track(i,2);
    y = track(i,3);

    currentFrame = stack(:,:,T);

    croppedFrame = imcrop(currentFrame, [x-L/2,y-L/2,L,L]);

%     try
%     rotatedFrame = imrotate(croppedFrame, -track(i,4),'crop');
%     catch
%     % Need to find previous non-nan value
%         theta = track(i,4);
%         I = 1;
%         while isnan(theta)
%             theta = track(i-I,4);
%             I = I +1;
%         end 
%         % Now try again with a non-NaN value
%         rotatedFrame = imrotate(croppedFrame, -theta,'crop');
%     end
    try
    croppedFrames(:,:,i) = croppedFrame; % crop image
    catch
        fprintf("The box is too close to the edge. Image not usable. \n")
        break
    end
end
end

