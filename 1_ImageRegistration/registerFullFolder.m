function registerFullFolder(folderpath,outputfolderpath,tformbrightfield,tformfluorescence,flipFlag)
%REGISTERFULLFOLDER is a function used to register a full folder made up of
%subdirectories of the type _1, _1_brightfield, _2, _2_brightfield
%   Detailed explanation goes here

fprintf("Registering fluorescence images...\n");
fixed = registerFolderMM(folderpath,outputfolderpath, tformfluorescence);
fprintf("Done.\n")

% Need to load up a sample image to make sure the brightfield images are in
% the same size



fprintf("Registering brightfield images...\n");
registerFolderBrightfield(folderpath,outputfolderpath, fixed, flipFlag, tformbrightfield);
fprintf("Done.\n")
end

