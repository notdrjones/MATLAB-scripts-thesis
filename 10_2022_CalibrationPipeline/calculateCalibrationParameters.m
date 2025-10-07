function [calibrationValues, varargout] = calculateCalibrationParameters(tracksL,tracksR,z_positions,output)
%GETCALIBRATIONPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

% REMOVE AFTER
z_positions = z_positions - 50;
z_positions = z_positions.*1000;

% get track centres
[track_centresL] = calculateTrackCentre(tracksL);
[track_centresR] = calculateTrackCentre(tracksR);

matchingIndex = autoMatchTraj(track_centresL, track_centresR,2000);
successfulMatches = ~isnan(matchingIndex);

matchedtracksL = tracksL(successfulMatches);
matchedtracksR = tracksR(matchingIndex(successfulMatches));

% Display and ask user if it's ok, or if manual registration is prefferd
% (TO BE WRITTEN)

% Create an array of N colours
N = length(matchedtracksL);

cols = jet(N);

if output
    matchedtracksfigure = figure;
    hold on;
    for i=1:N
        ith_L = matchedtracksL{i};
        ith_R = matchedtracksR{i};
        plot(ith_L(40,2),ith_L(40,3),'+','Color',cols(N,:))
        plot(ith_R(40,2),ith_R(40,3),'o','Color',cols(N,:))
    end
    daspect([1 1 1])
    
    varargout{1} = matchedtracksfigure;
end

% FIX TRAJECTORIES
N = 402;
[matchedtracksL] = fixTrajLengths(matchedtracksL,N);
[matchedtracksR] = fixTrajLengths(matchedtracksR,N);

% Now it's time to use the displacement from the chosen position to get
% what the factor dy/dz is.
fprintf("Calculating calibration info... \n")

trackDifference = cellfun(@(x,y) x-y, matchedtracksL, matchedtracksR, 'UniformOutput',false);

%--
trackDifference_matrix = cell2mat(trackDifference);
deltaX = trackDifference_matrix(:,2);
deltaX = reshape(deltaX, [N length(matchedtracksR)]);

mean_deltaX = mean(deltaX,2,'omitnan');
std_deltaX = std(deltaX,0,2,'omitnan');


deltaY = trackDifference_matrix(:,3);
deltaY = reshape(deltaY, [N length(matchedtracksR)]);

mean_deltaY = mean(deltaY,2,'omitnan');
std_deltaY = std(deltaY,0,2,'omitnan');

idxNan = isnan(mean_deltaX);
mean_deltaX(idxNan) = [];
std_deltaX(idxNan) = [];
z_positions(idxNan) = [];

% The calibration parameters are given by the XZ curve. In principle YZ
% curve should just be =0 for all z-positions

% We perform the fitting on the average curve, which is given by
% [z_positions mean_deltaX]

% NEED TO FIX THIS - the fit should actually be
% fit(mean_deltaX,z_positions) for use to reconstruct trajectories later
[fitobject, gof] = fit(mean_deltaX,z_positions,'poly1');

% fitobject(x) = p1*x + p2, i.e. z=p1*x+p2
calibrationValues = struct;
calibrationValues.p1 = fitobject.p1;
calibrationValues.p2 = fitobject.p2;
calibrationValues.rsquare = gof.rsquare;
calibrationValues.calibrationtime = datetime;
calibrationValues.info = "The values p1 and p2 belong to the linear fit: z=p1*x+p2";

if output
    differenceFigure = figure;
    subplot(2,1,1)
    shadedErrorBar(z_positions,mean_deltaX,std_deltaX); 
    hold on;
    plot((fitobject.p1.*mean_deltaX+fitobject.p2),mean_deltaX, 'r--');
    xlabel('z (um)')
    ylabel('DeltaX')
    xlim([z_positions(1) z_positions(end)])
    %xlim([z_positions(1) 50.5])
    %pbaspect([1 1 1])
    set(gca, 'box', 'on')

    subplot(2,1,2)
    shadedErrorBar(z_positions,mean_deltaY,std_deltaY);
    xlabel('z (um)')
    ylabel('DeltaY')
    xlim([z_positions(1) z_positions(end)])
    %xlim([z_positions(1) 50.5])
    %pbaspect([1 1 1])
    set(gca, 'box', 'on')

    varargout{2} = differenceFigure;
end
end

