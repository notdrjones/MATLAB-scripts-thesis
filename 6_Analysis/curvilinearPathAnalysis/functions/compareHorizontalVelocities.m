function compareHorizontalVelocities(datafolder,saveflag)
%COMPAREHORIZONTALVELOCITIES Summary of this function goes here

if nargin<2
    saveflag = false;
end

datafolder = [datafolder 'translatedAndRotated\'];
dt = 0.05;
pxsize = 0.11;

bacteriaTrack = importdata([datafolder 'bacteriaTrackHorizontal.mat']);
sprBTracks = importdata([datafolder 'SprBHorizontalTrack.mat']);

%-- smooth tracks using

bacteriaTrack = smoothTrackX(bacteriaTrack);
if ~isempty(sprBTracks)
    sprBTracks = cellfun(@(x) smoothTrackX(x), sprBTracks,'UniformOutput',false);
end

xBacteria = bacteriaTrack(:,2).*pxsize;
vxBacteria = [bacteriaTrack(2:end,1).*dt diff(xBacteria)./dt];
vxSprBs = cellfun(@(x) findVxSprBTracks(x,dt,pxsize),sprBTracks,'UniformOutput',false);

f = figure('Units','inches', 'Position', [1 1 5 5]);
%-- Plot lines
hold on
bacteriaLine = plot(vxBacteria(:,1),smooth(vxBacteria(:,2)),'k-','LineWidth',1.5);
%bacteriaLine.Color(4) = 0.5;
if ~isempty(vxSprBs)
    sprBLines = cellfun(@(x,y) plot(x(:,1),smooth(x(:,2)),'LineWidth',1.5),vxSprBs);
end
%-- NEED TO ADD LINE WITH DIFFERENCE BETWEEN VELOCITIES

velDifferences = cellfun(@(x) findVelocityDifference(vxBacteria,x), vxSprBs,'UniformOutput',false);
figure
hold on
cellfun(@(x) plot(x(:,1),movmean(x(:,2),7)),velDifferences)
end

function [vx] = findVxSprBTracks(track,dt,pxsize)
    x = track(:,2).*pxsize;
    vx = diff(x)./dt;

    vx = [track(2:end,1).*dt vx];
end

function [vDifference] = findVelocityDifference(bacteriaTrack,sprBTrack)
    % Both tracks have an array [T Vx]
    nPoints = size(sprBTrack,1);
    vDifference = zeros(nPoints,2);
    for i=1:nPoints
        idx = bacteriaTrack(:,1) == sprBTrack(i,1);
        if any(idx)
            vDifference(i,:) = [bacteriaTrack(idx,1) bacteriaTrack(idx,2)-sprBTrack(i,2)];
        else
            vDifference(i,:) = [nan nan];
        end
    end
end

function [trackSmoothed] = smoothTrackX(track)
    x = track(:,2);
    sgf = sgolayfilt(x,1,25);
    trackSmoothed = track;
    trackSmoothed(:,2) = sgf;
end