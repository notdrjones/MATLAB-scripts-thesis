function splitChannelsAllFolders(mainFolder)
stackFolders = dir(fullfile(mainFolder, '_*'));
disp(stackFolders);
nFolders = numel(stackFolders);
for i=1:nFolders
    stackFolder = fullfile(mainFolder, stackFolders(i).name);
    stackFolder = [stackFolder '/'];
    fullfilename = fullfile(stackFolder, 'L.tif');
    splitChannelsToStacks(stackFolder);
    % if ~ exist(fullfilename, 'file')
    %     splitChannelsToStacks(stackFolder);
    % end
end
