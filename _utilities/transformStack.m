function [newstack] = transformStack(imgstack, tform)

exframe = imgstack(:,:,1);
sameAsInput = affineOutputView(size(exframe),tform,"BoundsStyle","SameAsInput");
[h,w,nFrames] = size(imgstack);

newstack = zeros(h,w,nFrames);

for i= 1:nFrames
    currFrame = imgstack(:,:,i);
    newcurrFrame = imwarp(currFrame, tform, "cubic", "OutputView",sameAsInput);
    newcurrFrame = uint8(newcurrFrame);
    newstack(:,:,i) = newcurrFrame;

end

end
