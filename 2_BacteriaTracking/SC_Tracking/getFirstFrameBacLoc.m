function [newLoc] = getFirstFrameBacLoc(track)
%FIXTRACKEMPTYFRAMES Summary of this function goes here
%   Detailed explanation goes here

% Assumes first three columns are [T X Y .. ..]
% and T is in FRAME N, not TIME

% nFrames = height(track);

cellLens = track(:,5);
cellWids = track(:,6);

x = track(1,2);
y = track(1,3);
theta = track(1,4);
init_cell_len = nanmean(cellLens);
init_cell_width = nanmean(cellWids);

lensfiltered = cellLens((cellLens/init_cell_len) < 1.25 & (cellLens/init_cell_len) > 0.8);
widsfiltered = cellWids((cellWids/init_cell_width) < 1.25 & (cellWids/init_cell_width) > 0.8);

cell_len = mean(lensfiltered);
cell_width = mean(widsfiltered);

newLoc = [x y theta cell_len cell_width];
end

