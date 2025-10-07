function interpolatedTrack = interpolateTrack(track, interpolatetheta)
%INTERPOLATETRACK Summary of this function goes here
%   Detailed explanation goes here

% get a track and interpolate it where the values are nan

t = track(:,1);
x = track(:,2);
y = track(:,3);

% interpolate x values
x(isnan(x)) = interp1(t(~isnan(x)),x(~isnan(x)),t(isnan(x)));
y(isnan(y)) = interp1(t(~isnan(y)),y(~isnan(y)),t(isnan(y)));

if interpolatetheta == true
    theta = track(:,4);
    theta(isnan(theta)) = interp1(t(~isnan(theta)),theta(~isnan(theta)),t(isnan(theta)));
    interpolatedTrack = [t x y theta track(:,5:end)];
else
    interpolatedTrack = [t x y track(:,4:end)];
end

end
