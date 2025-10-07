function [locCell, PeakFitData] = extractPeakFitData(file_path,nFrames)
%EXTRACTFROMPEAKFIT is a function which takes as input a .txt file
%generated using the ImageJ plugin PeakFit
%(https://gdsc-smlm.readthedocs.io/en/latest/fitting_plugins.html#peak-fit)
% The output of said pluging usually consists in a file in which each row
% contains information regarding a localization in the order:
%
% Frame	origX	origY	origValue	Error	Noise (count)	Mean (count)	Background (count)	Intensity (count)	X (px)	Y (px)	Z (px)	Sx	Sy	Angle (rad)
%
% This code aims to create a cell array where each cell contains all the
% localizations for a given timestep.
%
% INPUTS
% locFile - a string with the path to the localization file
% tMAX - the number of frames in the original analyzed video
%
% OUTPUTS
% locCell - the cell array with all the localizations sorted
% PeakFit_Output - the original file, but as a usable matrix in MATLAB
% X 10 Y 11

% Load file with all localizations
PeakFitData = readmatrix(file_path,'FileType','text');

% Create empty cell array
locCell = cell(nFrames,1);

% the first column of PeakFit_Output, which contains the timestep for each
% localization
T = PeakFitData(:,1);

for t=1:nFrames
    locCell{t} = PeakFitData(T==t,10:11);
end

end

