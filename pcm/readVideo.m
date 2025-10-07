function [vidframes] = readVideo(filepath)

vidObj = VideoReader(filepath);
numFrames = vidObj.NumFrames;
vidframes = zeros(135,240,numFrames);
for i = 1:numFrames
    vidFrame = readFrame(vidObj);
    vidFrame = rgb2gray(vidFrame);
    vidFrame = im2uint8(vidFrame);
    vidFrame = imresize(vidFrame,1./8,'bilinear');
    vidframes(:,:,i) = vidFrame;
end


end