function outputPaths = cropCellVideosAutomatically(datafolder,brightestThresh, boxLength)
%DETECTFLUOROPHORESFIRSTFRAME Summary of this function goes here
%  An algorithm to check which trajectories are candidates for further
%  investigation. It open both the brightfield and fluorescence images,
%  then crops a square in the vicinity of the bacteria of interest and
%  check if there is likely to be one or more bright spots in there. 

% TODO:
% - parameters such as "output", "brightestThresh", "S" should be
% parameters the users sets with the function, not hard-coded in.
%
% - add option (or force) to save a reference image with the first
% brightfield image and the trajectory number.

outputPaths = {};

output = false;
%brightestThresh = 12;
if nargin<2
    brightestThresh = 700;
    boxLength = 100;
end


allTracks = importdata([datafolder 'allBacteriaTracks.mat']);
Ntracks = length(allTracks);

%-- load the three stacks
brightfieldStack = loadtiff([datafolder 'brightfield.tiff']);
L = loadtiff([datafolder 'L.tiff']);
R = loadtiff([datafolder 'R.tiff']);

firstBrightfieldImage = brightfieldStack(:,:,1);
outputFig = figure;
outputAx = gca;

imshow(imadjust(firstBrightfieldImage),[]);
hold on

for i=1:Ntracks
    % load track
    track = allTracks{i};

    index = track(1,1); % this gives first frame in which track appears
    xStart = track(1,2); % centroid of bacteria in first frame of the track
    yStart = track(1,3);

    %-- get brightfield frame and L channel frame, crop them
    brightfieldIm = brightfieldStack(:,:,index);
    fluorescenceIm = L(:,:,index);

    brightfieldCrop = imcrop(brightfieldIm,[xStart-boxLength/2,yStart-boxLength/2,boxLength,boxLength]);
    fluorescenceCrop = imcrop(fluorescenceIm,[xStart-boxLength/2,yStart-boxLength/2,boxLength,boxLength]);

    % apply gauss blur to the cropped images for ease of view in output
    % mode

    brightfieldCrop = imgaussfilt(brightfieldCrop,2);
    fluorescenceCrop = imtophat(imgaussfilt(fluorescenceCrop,2),strel('disk',15));

    brightestPoint = max(fluorescenceCrop,[],'all');

    if brightestPoint>brightestThresh
        keepPoint = true;
        fprintf("Max spot %i . This track would be kept. \n", max(fluorescenceCrop,[],'all'));
    else
        keepPoint = false;
        fprintf("Max spot %i . This track would NOT be kept. \n", max(fluorescenceCrop,[],'all'));
    end

    if output
        subplot(1,2,1)
        imshow(brightfieldCrop,[])
        subplot(1,2,2)
        imshow(fluorescenceCrop,[])
        drawnow;
    end

    if keepPoint
        track_id = i;

        plot(track(1,2),track(1,3),'ro','LineWidth',2);
        text(track(1,2)+20,track(1,3)+20,num2str(track_id))

        savepath = [datafolder 'cropped/cell_' num2str(track_id) '_cropped/'];
        
        if ~exist(savepath, 'dir')
            mkdir(savepath);
        end

        Bcropped = cropFramesAlongTrack(brightfieldStack,track,boxLength);
        Lcropped = cropFramesAlongTrack(L,track,boxLength);
        Rcropped = cropFramesAlongTrack(R,track,boxLength);

        fprintf("Saving images and trajectory... \n")
        options.overwrite = true;
        options.message = true;

        % save stuff
        saveastiff(uint16(Bcropped), [savepath 'brightfield_cropped.tif'],options);
        saveastiff(uint16(Lcropped), [savepath 'L_cropped.tif'],options);
        saveastiff(uint16(Rcropped), [savepath 'R_cropped.tif'],options);
    
        % save bacteria trajectory as well
        tracktosave = track;
        % time needs to be aligned to the cropped ones
        T = tracktosave(:,1)-(tracktosave(1,1)-1);
        tracktosave(:,end+1) = tracktosave(:,1); % add a column with the times relative to the original image.
        tracktosave(:,1) = T;

        save([savepath 'bacteriaTrack.mat'], 'tracktosave');
        
        fprintf("Saving complete.\n")
        outputPaths{end+1} = savepath;
    end
end

saveas(gcf, [datafolder 'referenceFigure.png']);


end

