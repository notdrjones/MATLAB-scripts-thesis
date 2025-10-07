function [folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath)

fileparts = strsplit(folderPath,filesep);
disp(fileparts);
nSubs = length(fileparts);
folderName = [fileparts{nSubs-1} '\'];
dirName = [fileparts{nSubs-2} '\'];
mainDataFolderPath = [fileparts{1} '\'];
if nSubs > 4
    for n = 2:nSubs-3
        mainDataFolderPath = append(mainDataFolderPath, fileparts{n}, filesep);
    end
end
dataOutPath = [mainDataFolderPath, 'results\'];

end
