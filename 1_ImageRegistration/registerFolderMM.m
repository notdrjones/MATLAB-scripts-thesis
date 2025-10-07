function fixed = registerFolderMM(targetfolder,outputfolder,tform)
%REGISTERFOLDERMM Summary of this function goes here
%   Detailed explanation goes here
folderinfo = dir([targetfolder '\_*']);


% This snippet makes sure that only MM folders are included and not the
% _N_brightfield folders from the Alvium camera
foldernames = {folderinfo.name};
folderlengths = cellfun(@(x) strlength(x), foldernames);
foldernames = foldernames(folderlengths<4);



Nfolders = length(foldernames);

for i=1:Nfolders
    fprintf("Registering images in folder %i out of %i \n", i, Nfolders);
    % MM saves stacks in the following way
    % '_N/_N_MMStack_Default.ome.tif'
    N = foldernames{i};
    outputfolder_i = [outputfolder '\' N '\'];
    stackpath = [targetfolder '\' N '\' N '_MMStack_Default.ome.tif'];
    [fixed, ~] = registerLRZwo(stackpath, outputfolder_i, tform);
end

fixed = fixed(:,:,1);

end

