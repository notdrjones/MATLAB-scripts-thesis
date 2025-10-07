function convertmp4toavi_multifile(dirPath)

files = dir(fullfile(dirPath, '*.mp4'));
disp(files);
nFiles = numel(files);
for i = 1:nFiles
    filename = files(i).name;
    disp(filename);
    filebasename = filename(1:end-4);
    disp(filebasename);
    if ~ exist(fullfile(dirPath, [filebasename, '.tif']), 'file')
        videostack = readVideo(fullfile(dirPath, filename));
    
        saveastiff(videostack, fullfile(dirPath, [filebasename, '.tif']));
    end
end
end