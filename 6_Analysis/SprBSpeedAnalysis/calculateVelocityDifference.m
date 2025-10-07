function [vSprBRelative] = calculateVelocityDifference(vSprB,vCell)
%CALCULATEVELOCITYDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here

% Assume both arrays have the form [T V]
vSprBRelative = vSprB;

for i=1:size(vSprBRelative,1)
    idx = vCell(:,1) == vSprBRelative(i,1);

    vSprBRelative(i,2) = vSprB(i,2)-vCell(idx,2);
end

end

