function make3DTrackVideo(datafolder,videoFlag)
%MAKECELLFRAMEVIDEO Summary of this function goes here

if videoFlag
    v = VideoWriter([datafolder 'videoTracks.avi']);
    open(v);
end

% Import tracks
tracksCELL = importdata([datafolder 'allTracks3D_CELL.mat']);
tracksLAB = importdata([datafolder 'allTracks3D_LAB.mat']);

pointsCELL = cell2mat(tracksCELL');
pointsLAB = cell2mat(tracksLAB');



%-- Set up the 3 subplots
s1 = subplot(3,1,1);
s2 = subplot(3,1,2);
set(gcf,'Color','white');

%-- With titles
title(s1,'LAB Frame of Reference');
title(s2,'CELL Frame of Reference');

% Plot first points
idx = pointsLAB(:,1) == 1;

labPlot = plot3(s1,pointsLAB(idx,2),pointsLAB(idx,3),pointsLAB(idx,4));
hold(s1,"on");
daspect([1 1 1])
view(-54,14)

cellPlot = plot3(s1,pointsCELL(idx,2),pointsCELL(idx,3),pointsCELL(idx,4));
hold(s2,"on");
daspect([1 1 1]);
view(-54,14)


% First frame of the video
if videoFlag
    frame = getframe(gcf);
    writeVideo(v,frame);
end

for i=2:max(pointsLAB(:,1))
   idx = pointsLAB(:,1) == i;
    
    scatter3(s1,pointsLAB(idx,2),pointsLAB(idx,3),pointsLAB(idx,4),3,pointsLAB(idx,1));
    hold(s1,"on");
    
    scatter3(s2,pointsCELL(idx,2),pointsCELL(idx,3),pointsCELL(idx,4),3,pointsLAB(idx,1));
    hold(s2,"on");
    if videoFlag
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
   % drawnow;
end
%
if videoFlag
    close(v);
end


end

