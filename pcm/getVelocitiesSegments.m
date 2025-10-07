function [velocities] = getVelocitiesSegments(bacTracks, options)

if nargin < 2 % Use default options
    options.seglength = 10;
end
[nr,~]=size(bacTracks);
velocities = [];
for k=1:nr
    currBac = bacTracks{k,:};
    nSeg = floor(height(currBac)/options.seglength);
    if nSeg >0
        firstframe = currBac(1,1);
        currBac(:,1) = currBac(:,1) - firstframe + 1;
        for i= 1:nSeg
            startframe = (i-1)*options.seglength +1;
            endframe = (i)*options.seglength;
            velocity = sqrt((currBac(startframe,2) - currBac(endframe,2))^2 + (currBac(startframe,3) - currBac(endframe,3))^2)/options.seglength;
            velocities = vertcat(velocities, velocity);
        end
    end

end
end