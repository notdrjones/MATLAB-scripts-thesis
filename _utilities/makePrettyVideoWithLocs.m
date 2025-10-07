function [outputArg1,outputArg2] = makePrettyVideoWithLocs(datafolder)
%MAKEPRETTYVIDEOWITHLOCS Summary of this function goes here
%   Detailed explanation goes here
% C:\Users\Simone Coppola\Dropbox\Oxford\+Results\CroppedCells\2023_06_29_SprB_0.3nM_Tunnel\acquisition_5_cell_5_cropped
% C:\Users\coppola\Dropbox\Oxford\+Results\CroppedCells\2023_06_29_SprB_0.3nM_Tunnel\acquisition_5_cell_5_cropped

if datafolder(end) == '\'
else
    datafolder(end+1) = '\';
end

% Open L/R stacks
stackL = loadtiff([datafolder 'L_cropped.tif']);
stackR = loadtiff([datafolder 'R_cropped.tif']);

nFrames = size(stackL,3);

parfor i=1:nFrames
    stackL(:,:,i) = imgaussfilt(stackL(:,:,i),2);
    stackR(:,:,i) = imgaussfilt(stackR(:,:,i),2);
end

% Now open localisations...
try
    locsFolder = [datafolder 'for video\'];
    locsL = cell2mat(importdata([locsFolder 'L_cropped_localisations.mat']));
    locsR = cell2mat(importdata([locsFolder 'R_cropped_localisations.mat']));
    
    locsCELL = cell2mat(importdata([locsFolder 'locsCELL.mat']));
    locsLAB = cell2mat(importdata([locsFolder 'locsLAB.mat']));

    locsCELL(:,4) = locsCELL(:,4) + 15;
    locsLAB(:,4) = locsLAB(:,4) + 15;
    
     locsCELL(:,2:4) = locsCELL(:,2:4).*0.1;
     locsLAB(:,2:4) = locsLAB(:,2:4).*0.1;
catch
end

%-- Set up plots, open videos etc
videopath = [datafolder 'video3DTracking.avi'];

v = VideoWriter(videopath,'Motion JPEG AVI');
v.Quality = 95;
open(v)

N = 20;
colsPoint = jet(N+1);
tileLayout = tiledlayout(2,3,"TileSpacing","tight","Padding","tight");


nexttile
axL = gca;
LImage = imshow(stackL(:,:,1),[]);
hold("on");
LPoint = plot(locsL(1,1),locsL(1,2),'r+');
title(axL,'L');

nexttile
axCell2D = gca;
cell2DTrack = scatter(locsCELL(1,2),locsCELL(1,3),10,colsPoint(N+1,:),'filled');
xlim([min(locsCELL(:,2)) max(locsCELL(:,2))]);
ylim([min(locsCELL(:,3)) max(locsCELL(:,3))]);
daspect([1 1 1])
title(axCell2D, 'CELL FRAME (2D)')


nexttile
axCell3D = gca;
cell3DTrack = scatter3(locsCELL(1,2),locsCELL(1,3),locsCELL(1,4),10,colsPoint(N+1,:),'filled');

xlim([min(locsCELL(:,2)) max(locsCELL(:,2))]);
ylim([min(locsCELL(:,3)) max(locsCELL(:,3))]);
zlim([min(locsCELL(:,4)) max(locsCELL(:,4))]);
daspect([1 1 1])
title(axCell3D, 'CELL FRAME (3D)')


nexttile
axR = gca;
title(axR,'R');
RImage = imshow(stackR(:,:,1),[]);
hold("on");
RPoint = plot(locsR(1,1),locsR(1,2),'r+');
title(axR,'R');

nexttile
axLab2D = gca;
lab2DTrack = scatter(locsLAB(1,2),locsLAB(1,3),10,colsPoint(N+1,:),'filled');
xlim([min(locsLAB(:,2)) max(locsLAB(:,2))]);
ylim([min(locsLAB(:,3)) max(locsLAB(:,3))]);
daspect([1 1 1])
title(axLab2D, 'LAB FRAME (2D)')


nexttile
axLab3D = gca;
lab3DTrack = scatter3(locsLAB(1,2),locsLAB(1,3),locsLAB(1,4),10,colsPoint(N+1,:),'filled');
xlim([min(locsLAB(:,2)) max(locsLAB(:,2))]);
ylim([min(locsLAB(:,3)) max(locsLAB(:,3))]);
zlim([min(locsLAB(:,4)) max(locsLAB(:,4))]);
daspect([1 1 1])
title(axLab3D, 'LAB FRAME (3D)')

frame = getframe(gcf);
writeVideo(v,frame);

for j=2:nFrames-50
    minVal = j-N;
    if minVal(1)<1
        minVal(1) = 1;
    end

    I = minVal:j;

    % Update all plots and figures
    try
    LImage.CData = stackL(:,:,j);
    set(LPoint,'XData',locsL(j,1),'YData',locsL(j,2));

    RImage.CData = stackR(:,:,j);
    set(RPoint,'XData',locsR(j,1),'YData',locsR(j,2));

    set(cell2DTrack,'XData',locsCELL(I,2),'YData',locsCELL(I,3),'CData',colsPoint(end-length(I)+1:end,:));
    
    set(lab2DTrack,'XData',locsLAB(I,2),'YData',locsLAB(I,3),'CData',colsPoint(end-length(I)+1:end,:));

    set(lab3DTrack,'XData',locsLAB(I,2),'YData',locsLAB(I,3),'ZData',locsLAB(I,4),'CData',colsPoint(end-length(I)+1:end,:));
    
    set(cell3DTrack,'XData',locsCELL(I,2),'YData',locsCELL(I,3),'ZData',locsCELL(I,4),'CData',colsPoint(end-length(I)+1:end,:));
    

    drawnow;
    frame = getframe(gcf);
    writeVideo(v,frame);
    catch
        A=1;
    end
end

close(v);


end

