function [deltaPhiUnwrapped] = findPhiSteps(fiducialTrajectoryAligned)
%FINDPHISTEPS Summary of this function goes here
%   Detailed explanation goes here

% Assume fiducial trajectory has already been aligned to x-axis.
% This means the fiducial marker will be moving in yz-plane

y = fiducialTrajectoryAligned(:,3);
z = fiducialTrajectoryAligned(:,4);

phi = atan2(z,y);

phiUnwrapped = unwrap(phi); % this is to avoid issues when finding step size
deltaPhiUnwrapped = diff(phiUnwrapped);
end

