function outputPaths = cropBacteriaVideosParametersBased(dataFolder,thresholds,options)
%  An algorithm to check which trajectories are candidates for further
%  investigation. It checks what the reversal rate and speed of the bacteia
%  in the tracks is, and then crops the videos. Doesn't take into account
%  the fluorescence channel.

% TODO:
% - add option (or force) to save a reference image with the first
% brightfield image and the trajectory number.

if ~isfield(thresholds, "minV"), thresholds.minV=0; end
if ~isfield(thresholds, "minRevRate"), thresholds.maxRevRate=0; end

outputPaths = {};

output = false;
brightestThresh = 700;
boxLength = 100;


allTracks = importdata([dataFolder 'allBacteriaTracks.mat']);

%-- load the three stacks
brightfieldStack = loadtiff([dataFolder 'brightfield.tiff']);
L = loadtiff([dataFolder 'L.tiff']);
R = loadtiff([dataFolder 'R.tiff']);

firstBrightfieldImage = brightfieldStack(:,:,1);
outputFig = figure;
outputAx = gca;

imshow(imadjust(firstBrightfieldImage),[]);
hold on

%-- Before continuing, run the bacteria track analysis
options.save = false;
[averageVelocities, reversalRates] = analyseBacteriaTracks(dataFolder, options);

velocityCheck = averageVelocities>thresholds.minV;
revRateCheck = reversalRates<thresholds.maxRevRate;

% To pass check, both conditions must be respected.
indexPassCheck = velocityCheck == revRateCheck;

allTracks = allTracks(indexPassCheck); % Only keep tracks which passed both checks.

Ntracks = length(allTracks);

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

        savepath = [dataFolder 'cropped/cell_' num2str(track_id) '_cropped/'];
        
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

saveas(gcf, [dataFolder 'referenceFigure.png']);

end

