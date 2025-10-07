function [theta1] = fix_angles(theta)
%FIX Summary of this function goes here
%   Detailed explanation goes here
theta1 = theta;

dTheta = diff(theta);
changeFlag = find(abs(dTheta)>130); % only really big changes, which can only be the software getting things wrong

changeFlag1 = changeFlag;
changeFlag = changeFlag+1;

theta1(changeFlag(1):changeFlag(2)) = theta1(changeFlag(1):changeFlag(2))-dTheta(changeFlag1(1));
theta1(changeFlag(3):end) = theta1(changeFlag(3):end)-dTheta(changeFlag(3));

end

