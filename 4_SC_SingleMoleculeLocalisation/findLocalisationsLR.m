function [locFittedL, locFittedR] = findLocalisationsLR(folderpath,optionsL,optionsR)
%FINDLOCALISATION Summary of this function goes here
%   Detailed explanation goes here
optionsL.save = true;
optionsR.save = true;
% find names of L and R
filenameL = dir([folderpath 'L*']);
filenameR = dir([folderpath 'R*']);

stackfilenameL = [folderpath filenameL.name];
stackfilenameR = [folderpath filenameR.name];

%--

% stackfilenameL = [folderpath 'L_cropped.tif'];
% stackfilenameR = [folderpath 'R_cropped.tif'];

fprintf("Finding localisations L channel...\n")
[locFittedL, ~] = getStackLocalisations(stackfilenameL,optionsL);
fprintf("Finding localisations R channel...\n")
[locFittedR, ~] = getStackLocalisations(stackfilenameR,optionsR);
end

