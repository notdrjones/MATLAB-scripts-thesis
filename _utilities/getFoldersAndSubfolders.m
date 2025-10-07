function folderlist = getFoldersAndSubfolders(directory)
%GETFOLDERSANDSUBFOLDERS Summary of this function goes here
%   Detailed explanation goes here
folderlist = cell(0,0);
foldernames = dir(directory);
% remove all files (isdir property is 0)
foldernames = foldernames([foldernames(:).isdir]);
% remove '.' and '..' 
foldernames = foldernames(~ismember({foldernames(:).name},{'.','..'}));

for i=1:length(foldernames)
    currentfolder = foldernames(i).name;

    subfoldernames = dir([directory currentfolder '\']);
    % remove all files (isdir property is 0)
    subfoldernames = subfoldernames([subfoldernames(:).isdir]);
    % remove '.' and '..' 
    subfoldernames = subfoldernames(~ismember({subfoldernames(:).name},{'.','..'}));
    
    for j=1:length(subfoldernames)
        folderlist{end+1,1} = [currentfolder '\' subfoldernames(j).name '\'];
    end
end
end

