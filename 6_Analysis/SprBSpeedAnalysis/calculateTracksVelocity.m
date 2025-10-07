function [outputArg1,outputArg2] = calculateTracksVelocity(datafolder,saveFlag)
%CALCULATETRACKVELOCITY Summary of this function goes here
%   Detailed explanation goes here

% Load LAB Frame 3D Tracks
allTracks3DCELL = importdata([datafolder 'allTracks3D_CELL.mat']);
allTracks3DLAB = importdata([datafolder 'allTracks3D_LAB.mat']);

bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
for i=2:2:size(bacteriaTrack,1)-1
    bacteriaTrack(i,2:3) = (bacteriaTrack(i-1,2:3)+bacteriaTrack(i+1,2:3))./2;
end

% Convert bacteriaTrack to um from px
pxsize = 0.12;
dt = 0.05;
bacteriaTrack(:,2:3) = bacteriaTrack(:,2:3).*pxsize;
dx = diff(bacteriaTrack(:,2));
dy = diff(bacteriaTrack(:,3));
bacteriaVelocity = sqrt(dx.^2+dy.^2)./dt;
bacteriaVelocityArray = [bacteriaTrack(2:end,1) bacteriaVelocity];

%-- Smooth SprB tracks before working with them
allTracks3DLABSmooth = cellfun(@(x) smooth3DTrack(x,7), allTracks3DLAB, 'UniformOutput',false);
allTracks3DCELLSmooth = cellfun(@(x) smooth3DTrack(x,7), allTracks3DCELL, 'UniformOutput',false);

%-- Calculate velocities in LAB and CELL Frame
trackVelocitiesLAB = cellfun(@(x) calculateSingleTrack3DVelocities(x,0.05),allTracks3DLABSmooth,'UniformOutput',false);
trackVelocitiesCELL = cellfun(@(x) calculateSingleTrack3DVelocities(x,0.05),allTracks3DCELLSmooth,'UniformOutput',false);

% Velocity cells are outputted as follows [frame vx vy vz vxy vxyz]
allLABVelocities = cell2mat(trackVelocitiesLAB');
allCELLVelocities = cell2mat(trackVelocitiesCELL');

% Start making the histograms
normalisationStyle = 'Probability';
% vxCELL histogram
[~,vxHistoAxes,vxHistoFigure] = makeHistogram(allCELLVelocities(:,2),normalisationStyle,linspace(-3,3,30));
xlabel(vxHistoAxes,'V_x (um/s)')
% abs(vxCELL)
[~,vxAbsHistoAxes,vxAbsHistoFigure] = makeHistogram(abs(allCELLVelocities(:,2)),normalisationStyle,linspace(0,3,30));
xlabel(vxAbsHistoAxes,'|V_x| (um/s)')

% vxyCELL histogram
[~,vxyHistoAxes,vxyHistoFigure] = makeHistogram(allCELLVelocities(:,5).*sign(allCELLVelocities(:,2)),normalisationStyle,linspace(-3,3,30));
xlabel(vxyHistoAxes,'V_{CELL} (um/s)')
% abs(vCELL)
[~,vxyAbsHistoAxes,vxyAbsHistoFigure] = makeHistogram(abs(allCELLVelocities(:,5)),normalisationStyle,linspace(0,3,30));
xlabel(vxyAbsHistoAxes,'|V_{CELL}| (um/s)')

% vxyLAB histogram
[~,vxyLABAbsHistoAxes,vxyLABAbsHistoFigure] = makeHistogram(abs(allLABVelocities(:,5)),normalisationStyle,linspace(0,3,30));
xlabel(vxyLABAbsHistoAxes,'V_{LAB} (um/s)')

if saveFlag
    resultsfolder = [datafolder 'results\'];

    % Save the cells with the info for each track
    save([resultsfolder 'trackVelocitiesCELL.mat'],'trackVelocitiesCELL');
    save([resultsfolder 'trackVelocitiesLAB.mat'],'trackVelocitiesLAB');

    % Save the figures
    extensions = {'png','fig'};
    multiextensionfigsaving(vxHistoFigure,[resultsfolder 'vxHistoFigure'],extensions)
    multiextensionfigsaving(vxAbsHistoFigure,[resultsfolder 'vxAbsHistoFigure'],extensions)

    multiextensionfigsaving(vxyHistoFigure,[resultsfolder 'vxyHistoFigure'],extensions)
    multiextensionfigsaving(vxyAbsHistoFigure,[resultsfolder 'vxyAbsHistoFigure'],extensions)
    multiextensionfigsaving(vxyLABAbsHistoFigure,[resultsfolder 'vxyLABAbsHistoFigure'],extensions)

    close(vxHistoFigure,vxAbsHistoFigure,vxyHistoFigure,vxyAbsHistoFigure,vxyLABAbsHistoFigure);
end

end

