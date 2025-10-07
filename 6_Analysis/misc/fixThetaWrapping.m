function [thetaNew,thetaNewUnwrapped] = fixThetaWrapping(theta)
%FIXTHETAWRAPPING Summary of this function goes here
%   Detailed explanation goes her

thetaNew = zeros(size(theta));
thetaNew(1) = theta(1);



% Initial theta values are between -pi/2 and pi/2
for i=2:size(theta,1)
    if isnan(theta(i))
        theta(i) = theta(i-1);
    end
    thetaCurrent = theta(i);

    thetaOptions = [thetaCurrent; thetaCurrent-180.*sign(thetaCurrent)];

    thetaPrevious = thetaNew(i-1);

    thetaDistances = thetaPrevious - thetaOptions;
    thetaDistances(thetaDistances>180) = thetaDistances(thetaDistances>180) - 360;
    thetaDistances(thetaDistances<-180) = thetaDistances(thetaDistances<-180) + 360;

    [~, minIdx] = min(abs(thetaDistances));

    thetaNew(i) = thetaOptions(minIdx);  
end

thetaNewRad = deg2rad(thetaNew);
thetaNewUnwrapped = rad2deg(unwrap(thetaNewRad));


end

