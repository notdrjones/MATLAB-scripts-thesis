function v=calculateInstantVelocity(track)
%CALCULATEVELOCITY Summary of this function goes here
%   Detailed explanation goes here
t= track(:,1); x = track(:,2); y = track(:,3);

dt = diff(t); dx = diff(x); dy = diff(y);

v = sqrt(dx.^2+dy.^2)./dt;
end

