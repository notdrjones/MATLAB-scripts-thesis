function [xNormalised] = createLocalisationPositionHistogram(datafolder,saveFlag)
%TESTFUNCTION Summary of this function goes here
%   Detailed explanation goes here
% Import bacteriaTrack
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
theta = bacteriaTrack(:,4);
[theta, ~] = fixThetaWrapping(theta);

% Load cell frame localisations
localisationsCELL = importdata([datafolder 'localisations3D.mat']);

% Import left denoised, and brightfield images
%-- Load the fluorescence and brightfield stack
brightfieldStack = imread([datafolder 'brightfield_cropped.tif'],1);

i=1;
brightfieldStack(:,:,i) = imgaussfilt(brightfieldStack(:,:,i),2);

if isnan(theta(i))
    theta(i) = theta(i-1);
end

[boundaryXY] = findBacteriaBoundary(brightfieldStack(:,:,i));
[xRot, yRot] = rotatePoints(boundaryXY(:,1),boundaryXY(:,2),deg2rad(theta(i)),101/2,101/2);

%-- Rotate stacks too to plot
%brightfieldStack(:,:,i) = imrotate(brightfieldStack(:,:,i),-theta(i),"nearest","crop");
% imshow(brightfieldStack(:,:,i));
% hold on
% plot(xRot,yRot,'r.');
% drawnow;
% hold off;

%--

% Consider the origin to be the centre of the image
L = 101;
xTranslated = xRot-L/2;
yTranslated = yRot-L/2;

locsTranslated = cell2mat(localisationsCELL);
locsTranslated(:,2:3) = locsTranslated(:,2:3)-L/2;

% What are the edges of the CELL?
cellEdges = [min(xTranslated) max(xTranslated)];
cellLength = max(xTranslated)-min(xTranslated);


% Normalise xLocalisations
xLocalisations = locsTranslated(:,2);
xNormalised = [];
xNormalised = [xNormalised; xLocalisations(xLocalisations<0)./abs(cellLength)];
xNormalised = [xNormalised; xLocalisations(xLocalisations>0)./abs(cellLength)];
xNormalised(xNormalised>0.5)=0.5;
xNormalised(xNormalised<-0.5)=-0.5;



%-- Make and plot the histogram
histoFigure = figure;
histoFigure.Position = [1 1 400 400];
histo = histogram(xNormalised,linspace(-0.5,0.5,10),'Normalization','probability');
histoAxes = gca;
histo.FaceColor = [0.30,0.75,0.93];
histo.EdgeColor = [0,0.45,0.74];
histo.FaceAlpha = 0.3;
histo.EdgeAlpha = 1;
histo.LineWidth = 1.5;

histoAxes.Box = "off";
histoAxes.FontName = 'Arial';
histoAxes.FontSize = 15;
histoAxes.LineWidth = 1.5;
histoAxes.TickDir = 'out';
histoAxes.XLim = [-0.5 0.5];
pbaspect([1 1 1]);
xlabel('x/l_{CELL}');
ylabel('Probability');
if saveFlag
    set(histoFigure,'Color','w');
    if ~exist([datafolder 'results\'],'dir')
        mkdir([datafolder 'results\']);
    end
    saveas(histoFigure,[datafolder 'results\sprBPositionHistogram.fig']);
    saveas(histoFigure,[datafolder 'results\sprBPositionHistogram.png']);
    save([datafolder 'results\sprBPositionData.mat'],'xNormalised');
    close(histoFigure);
end

end
