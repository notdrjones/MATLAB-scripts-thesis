function registerFolderBrightfield(targetfolder,outputfolder,fixed,flipFlag,tform)
%REGISTERFOLDERMM Summary of this function goes here
%   Detailed explanation goes here
folderinfo = dir([targetfolder '\_*_brightfield']);


% This snippet makes sure that only MM folders are included and not the
% _N_brightfield folders from the Alvium camera
foldernames = {folderinfo.name};

Nfolders = length(foldernames);

for i=1:Nfolders
    fprintf("Registering images in folder %i out of %i \n", i, Nfolders);
    % MM saves stacks in the following way
    % '_N/_N_MMStack_Default.ome.tif'
    N = foldernames{i};
    outputfolder_i = [outputfolder '\' strrep(N,'_brightfield','') '\'];
    stackpath = [targetfolder '\' N '\stack\' N '_stack.tif'];
    registerBrightfieldL(stackpath,outputfolder_i, fixed,flipFlag,tform);
end
end

