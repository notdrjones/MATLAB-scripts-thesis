function [outputArg1,outputArg2] = compareLR_localisation(filenameImageL, filenameImageR,squareLength,bacteriaTrack)
%COMPARELR_LOCALISATION Summary of this function goes here
%   Detailed explanation goes here

% get localisation data by adding .results.xls to image names
filenameLocL = [filenameImageL '.results.xls'];
filenameLocR = [filenameImageR '.results.xls'];

[locCellL, ~] = extractPeakFitData(filenameLocL,200);
[locCellR, ~] = extractPeakFitData(filenameLocR,200);

[allTracksL] = make_trajectories(locCellL,'max_linking_distance', 10,'minTrackLength', 15, 'max_gap_closing', 6);
[allTracksR] = make_trajectories(locCellR,'max_linking_distance', 10,'minTrackLength', 15, 'max_gap_closing', 6);


subplot(1,2,1)
hold on
cellfun(@(x) plot(x(:,1),x(:,2),'*-'),allTracksL);
xlim([1 100])

subplot(1,2,2)
hold on
cellfun(@(x) plot(x(:,1),x(:,2),'o-'),allTracksR);
xlim([1 100])


figure
hold on
cellfun(@(x) plot(x(:,1),x(:,2),'*-'),allTracksL);
cellfun(@(x) plot(x(:,1),x(:,2),'o-'),allTracksR);
xlim([1 100])

%%
figure
hold on
cellfun(@(x) plot(x(:,1),x(:,3),'*-'),allTracksL);
cellfun(@(x) plot(x(:,1),x(:,3),'o-'),allTracksR);
xlim([1 100])
%%

% convert allTracksR into locCellR
locCellR_Filtered = cell(200,1);
allTracksR_array = cell2mat(allTracksR);

for t=1:200
    index = allTracksR_array(:,1) == t;
    locCellR_Filtered{t} = allTracksR_array(index,2:3); 
end

locCellR = locCellR_Filtered;

Nframes = size(bacteriaTrack,1);

L = loadtiff(filenameImageL);
R = loadtiff(filenameImageR);

for t=1:Nframes
    xL = locCellL{t}(:,1);
    yL = locCellL{t}(:,2);

    xM = xL.*NaN;
    yM = yL.*NaN;

    xR = locCellR{t}(:,1);
    yR = locCellR{t}(:,2);

    % colors based on number of xL
    cols = turbo(length(xL));

    for i=1:length(xL)
        [xM(i), yM(i), ~] = autoMatchPoint([xL(i) yL(i)], [xR yR],20);
    end
        
    titlename = ['Frame ' num2str(t)];

    subplot(1,2,1) % left channel
    imagesc(imgaussfilt(L(:,:,t),2));
    title(titlename);
    hold on;
    scatter(xL,yL,10,cols,'filled');
%    plot(locCellL{t}(:,1),locCellL{t}(:,2),'r+');
    hold off
    daspect([1 1 1])

    subplot(1,2,2) % left channel
    imagesc(imgaussfilt(R(:,:,t),2));
    hold on;
    %plot(locCellR{t}(:,1),locCellR{t}(:,2),'r+');
    scatter(xM,yM,10,cols,'filled');
    scatter(xM,yM,20,'red');
    hold off;
    daspect([1 1 1])

    drawnow
end



end

