function getFramesForTraining(folderpath,N)
%GETFRAMESFORTRAINING Summary of this function goes here
%   Detailed explanation goes here

outputpath = [folderpath '\trainingSet'];

    if ~exist("outputpath","dir")
        mkdir(outputpath)
    end

    folders = dir([folderpath '\_*']);

    % Check if there is an even number of folders in the directory. If
    % there is not an even number of folders in the directory, it must mean
    % that the folders are not matched up (i.e. there's some spare ones)
    % and the user must fix that before running the code to avoid problems.

    nFolders = length(folders);

    % Go through all the names in the directory
    % If the string contains "brightfield", the entry is removed from the
    % structure
    foldersToDelete = [];
    for i=1:nFolders
        folderName = folders(i).name;

        if contains(folderName,'brightfield')
            foldersToDelete = [foldersToDelete; i];
        end
    end

    folders(foldersToDelete) = [];

    % Once you've cleared the folder list, loop through each folder and run
    % "processAcquisition" for each of them.

    fprintf("There are %i folders to process. \n Starting ... \n", length(folders));

                options.message = false;

    for i=1:length(folders)/4
        currentFolder = [folderpath '\' folders(i).name ];
        fprintf("Currently processing : %s", currentFolder);

        % For each folder, open both L and R stack.
        L = loadtiff([currentFolder '\L.tiff']);
        %R = loadtiff([currentFolder '\R.tiff']);

        parfor j=1:N
            nL = randi([1 size(L,3)]);
            chosenL = L(:,:,nL);

           % nR = randi([1 size(R,3)]);
           % chosenR = R(:,:,nR);
            
            % Save images
            saveastiff((chosenL),[outputpath '\stack' num2str(i) 'frame' num2str(nL) 'L.tif'],options);
            %saveastiff(uint8(chosenR),[outputpath '\stack' num2str(i) 'frame' num2str(nR) 'R.tif'],options);
        end
    end
end

