function theta = fix_angles2(theta)
%FIX_ANGLES2 Summary of this function goes here
%   Detailed explanation goes here

thetaold = theta;
for i=2:length(theta)
    diffValue = theta(i)-theta(i-1);

    if abs(diffValue)>130
        theta(i) = theta(i)-sign(diffValue)*180;
    end
end

end

