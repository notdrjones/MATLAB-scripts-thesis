function [fiducialTrajectoryCELL,helixTrajectoryCELL] = LAB2CELL(bacteriaTrajectory,fiducialTrajectoryLAB,helixTrajectoryLAB)
%LAB2CELL Summary of this function goes here
% A function which takes as input a bacteria trajectory, a fiducial marker
% trajectory and the trajectory of a fluorophore of interest in the LAB
% frame of reference and builds trajectory in the CELL frame of reference.

% bacteriaTrajectory - array with [T X Y THETA] info from brightfield data
% fiducialTrajectoryLAB - the fiducial trajectory [T X Y Z]
% helixTrajectoryLAB - the marker trajectory of interest [T X Y Z]


% The idea is that we first transpose the points (i.e. imagine if the image
% is always centred on the bacterium as it moves), then we rotate the
% points (now the cell always points in the same direction - imagine if the
% cells were stuck on agar. Lastly, we deal with the cell rotating on its
% axis by analysis the fiducial trajectory and determining the rate at
% which it rotates, and rotating points accordingly.

% SPACE ALLOCATION - this makes things run a bit faster.
fiducialTrajectoryCELL = fiducialTrajectoryLAB;
helixTrajectoryCELL = helixTrajectoryLAB;

% Step 1 - Apply translation
fiducialTrajectoryCELL(:,2:3) = fiducialTrajectoryCELL(:,2:3) - bacteriaTrajectory(:,2:3);
helixTrajectoryCELL(:,2:3) = helixTrajectoryCELL(:,2:3) - bacteriaTrajectory(:,2:3);

% Step 2 - Rotate Points
for i=1:length(fiducialTrajectoryCELL)
    [fiducialTrajectoryCELL(i,2), fiducialTrajectoryCELL(i,3)] = rotatePoints(fiducialTrajectoryCELL(i,2),fiducialTrajectoryCELL(i,3),bacteriaTrajectory(i,4)+pi/2);
    [helixTrajectoryCELL(i,2), helixTrajectoryCELL(i,3)] = rotatePoints(helixTrajectoryCELL(i,2),helixTrajectoryCELL(i,3),bacteriaTrajectory(i,4)+pi/2);
end

% Step 3 - find angles of rotation from fiducial trajectory and rotate
% points in the yz plane
%[phi] = findPhiAngles(fiducialTrajectoryCELL);
[dPhi] = findPhiSteps(fiducialTrajectoryCELL);

% for i=1:length(fiducialTrajectoryCELL)
%     [fiducialTrajectoryCELL(i,3), fiducialTrajectoryCELL(i,4)] = rotatePoints(fiducialTrajectoryCELL(i,3),fiducialTrajectoryCELL(i,4),-phi(i));
%     [helixTrajectoryCELL(i,3), helixTrajectoryCELL(i,4)] = rotatePoints(helixTrajectoryCELL(i,3),helixTrajectoryCELL(i,4),-phi(i));
% end

for i=2:length(fiducialTrajectoryCELL)
    [fiducialTrajectoryCELL(i:end,3), fiducialTrajectoryCELL(i:end,4)] = rotatePoints(fiducialTrajectoryCELL(i:end,3),fiducialTrajectoryCELL(i:end,4),-dPhi(i-1));
    [helixTrajectoryCELL(i:end,3), helixTrajectoryCELL(i:end,4)] = rotatePoints(helixTrajectoryCELL(i:end,3),helixTrajectoryCELL(i:end,4),-dPhi(i-1));
end
end

