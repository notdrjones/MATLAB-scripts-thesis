function makeBrightfieldTrackVideo(outputfolder)
%-- video data
videoname = [outputfolder 'brightfieldVideo.avi'];
v = VideoWriter(videoname);
open(v);


stackfilename = [outputfolder 'brightfield.tiff'];
stack = loadtiff(stackfilename);

% Load trajectories stack
allTracks = importdata([outputfolder 'allBacteriaTracks.mat']);
ids = cell(size(allTracks));

for i=1:length(allTracks)
    N = length(allTracks{i});
    ids{i} = zeros(N,1)+i;
end

trackIDs = [cell2mat(allTracks) cell2mat(ids)];


cols = jet(length(allTracks));


%-- Here is where plotting starts
for t=1:size(stack,3)
    imshow(stack(:,:,t),[100,255]);
    hold on

    idx = trackIDs(:,1)==t;

    scatter(trackIDs(idx,2),trackIDs(idx,3),10,cols(trackIDs(idx,end),:));
    drawnow;
    hold off

    frame = getframe(gcf);
    writeVideo(v,(frame));
end


close(v);
end

