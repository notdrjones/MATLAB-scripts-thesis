function [outputArg1,outputArg2] = cropStacks(datafolder,track_id)
%CROPSTACKS Summary of this function goes here
%   Detailed explanation goes here

fprintf("Saving in process...\n")
% start by creating the directory where to save files
track_id = app.TrackSpinner.Value;
savepath = [datafolder 'cropped/cell_' num2str(track_id) '_cropped/'];

if ~exist(savepath, 'dir')
    mkdir(savepath);
end

fprintf("Loading and cropping L/R frames... \n")
% crop L and R without gauss blurring them, using cropFrames
L = loadtiff([datafolder 'L.tiff']);
Lcropped = uint8(cropFrames(app, L, app.currentTrack));

R = loadtiff([app.folderPath 'R.tiff']);
Rcropped = uint8(cropFrames(app, R, app.currentTrack));
            

fprintf("Saving images and trajectory... \n")
options.overwrite = true;
options.message = true;

            % save stuff
            saveastiff(uint8(app.cropped_brightfieldStack), [savepath 'brightfield_cropped.tif'],options);
            saveastiff(Lcropped, [savepath 'L_cropped.tif'],options);
            saveastiff(Rcropped, [savepath 'R_cropped.tif'],options);
        
            % save bacteria trajectory as well
            tracktosave = app.currentTrack;
            % time needs to be aligned to the cropped ones
            T = tracktosave(:,1)-(tracktosave(1,1)-1);
            tracktosave(:,end+1) = tracktosave(:,1); % add a column with the times relative to the original image.
            tracktosave(:,1) = T;
            save([savepath 'bacteriaTrack.mat'], 'tracktosave');


            fprintf("Saving complete.\n")

end

% when the button gets pushed, the cropped videos get cropped
            lamps(app,'saving');
            fprintf("Saving process...\n")
            % start by creating the directory where to save files
            track_id = app.TrackSpinner.Value;
            savepath = [app.folderPath 'cropped/cell_' num2str(track_id) '_cropped/'];

            if ~exist(savepath, 'dir')
                mkdir(savepath);
            end

            fprintf("Loading and cropping L/R frames... \n")
            % crop L and R without gauss blurring them, using cropFrames
            L = loadtiff([app.folderPath 'L.tiff']);
            Lcropped = uint8(cropFrames(app, L, app.currentTrack));

            R = loadtiff([app.folderPath 'R.tiff']);
            Rcropped = uint8(cropFrames(app, R, app.currentTrack));
            

            fprintf("Saving images and trajectory... \n")
            options.overwrite = true;
            options.message = true;

            % save stuff
            saveastiff(uint8(app.cropped_brightfieldStack), [savepath 'brightfield_cropped.tif'],options);
            saveastiff(Lcropped, [savepath 'L_cropped.tif'],options);
            saveastiff(Rcropped, [savepath 'R_cropped.tif'],options);
        
            % save bacteria trajectory as well
            tracktosave = app.currentTrack;
            % time needs to be aligned to the cropped ones
            T = tracktosave(:,1)-(tracktosave(1,1)-1);
            tracktosave(:,end+1) = tracktosave(:,1); % add a column with the times relative to the original image.
            tracktosave(:,1) = T;
            save([savepath 'bacteriaTrack.mat'], 'tracktosave');


            fprintf("Saving complete.\n")
            lamps(app,'ready');