function vArray = calculateSingleTrack3DVelocities(track3D,timestep)
%CALCULATESINGLETRACK3DVELOCITY Summary of this function goes here
%   Detailed explanation goes here
% Assume track3D is already in um [FRAME X Y Z]

dt = diff(track3D(:,1)).*timestep;
dx = diff(track3D(:,2));
dy = diff(track3D(:,3));
dz = diff(track3D(:,4));

vx = dx./dt;
vy = dy./dt;
vz = dz./dt;

%v = sqrt(dx.^2+dy.^2+dz.^2)./dt;
%v = sqrt(dx.^2+dy.^2)./dt;

vxy = sqrt(vx.^2+vy.^2);
vxyz = sqrt(vx.^2+vy.^2+vz.^2);

vArray = [track3D(2:end,1) vx vy vz vxy vxyz];
end

