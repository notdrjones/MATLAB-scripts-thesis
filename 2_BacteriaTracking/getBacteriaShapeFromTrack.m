function [bacshape] = getBacteriaShapeFromTrack(stack, track)

sumImage = zeros(250,250);
for i= 1:len(track)
    if ismember(i, track(:,1))
        thisImage = double(imread(fullFileName));
        thisImage = imcomplement(thisImage);
        
        sumImage = sumImage + thisImage*0.01;
    end
end
