function [yMSeg,zMSegd] = findLineMiddleAndParallelVector(inputArg1,inputArg2)
%FINDLINEMIDDLEANDPARALLELVECTOR Summary of this function goes here
%   Detailed explanation goes here
% Find centre of segment
    yMSeg = mean(ySeg);
    zMSeg = mean(zSeg);

    subplot(2,1,1);
    plot(ySeg,zSeg,'Color',cols(i,:));
    hold on
    plot(yMSeg,zMSeg,'r*');
    daspect([1 1 1])

    % Find vector parallel to segment
    dyAll = diff(ySeg);
    dzAll = diff(zSeg);
    dy = mean(dyAll);
    dz = mean(dzAll);

    normFactor = sqrt(dy.^2 + dz.^2);

    % Get unit vector
    dyNorm = dy./normFactor;
    dzNorm = dz./normFactor;

    % Calculate angle value
    ang =atan2(dzNorm,dyNorm);
end

