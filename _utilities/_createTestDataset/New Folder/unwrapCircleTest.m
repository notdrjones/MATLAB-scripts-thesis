close all
clear all

%-- Generate a circle in the YZ plane
angles = linspace(-pi,pi,2000);
x = zeros(size(angles))+2.5;
y = cos(angles);
z = sin(angles);

%-- Plot the circle
%plot3(x,y,z)

%-- Now find angles in YZ plane
theta = atan2(y,z);

%-- Plot the points again, but add colour for angle
%scatter3(x,y,z,10,theta,'filled');
%colorbar

%-- Split angles in bins of 10 degrees 
nBins = 360/40;
binEdges = linspace(-pi,pi,nBins);

[~,~,bin] = histcounts(theta,binEdges);

binCentres = (binEdges(1:end-1)+binEdges(2:end))./2;

%-- Plot points with colour related to bin placement
%scatter3(x,y,z,10,bin,'filled')

%-- Find points in bin centred at zero, which determine your start point
centralBin = find(binCentres==0);
maxBin = max(bin);

% Points to the right of central segment are given by bin>centralBin,
% viceversa for left of central segment

% Loop through segments on the right of central segment

figureSegments = figure;
cols = jet(maxBin);

normalVectors = zeros(maxBin,2);
rotationCentres = zeros(maxBin,2);
rotatedSegments = cell(maxBin,1);
rotationAngles = zeros(maxBin,1);
translationVectors = zeros(maxBin,2);

prevy = 0 ;
prevz = 0;
for i=1:maxBin
    
    xSeg = x(bin==i);
    ySeg = y(bin==i);
    zSeg = z(bin==i);

    % Find centre of segment
    xMSeg = xSeg(1);
    yMSeg = mean(ySeg);
    zMSeg = mean(zSeg);

    subplot(2,1,1)
    plot(ySeg,zSeg,'Color',cols(i,:));
    hold on
    plot(ySeg(1),zSeg(1),'ko')
    plot(yMSeg,zMSeg,'r*');
    daspect([1 1 1])

    % Find vector parallel to segment
    dyAll = diff(ySeg);
    dzAll = diff(zSeg);
    dy = mean(dyAll);
    dz = mean(dzAll);

    normFactor = sqrt(dy.^2 + dz.^2);

    % Get unit vector
    dyNorm = dy./normFactor;
    dzNorm = dz./normFactor;
        
    drawnow;
    quiver(yMSeg,zMSeg,dzNorm,-dyNorm,'k')

    normalVectors(i,:) = [dzNorm -dyNorm];

    rotationAngles(i) = pi/2-atan2(-dyNorm,dzNorm);
    rotationCentres(i,:) = [yMSeg zMSeg];

    [yR, zR] = rotatePoints(ySeg,zSeg,rotationAngles(i),yMSeg,zMSeg);

    hold on

    plot(yR, zR,'-','Color',cols(i,:),'LineWidth',2)
    plot(yR(1),zR(1),'ko')


    rotatedSegments{i} = [yR zR];

    subplot(2,1,2);

    DY =-yR(end)+prevy;
    DZ = -zR(end)+prevz;

    translationVectors(i,:) = [DY DZ];

    yT = yR+DY;
    zT = zR+DZ;
    plot(yT, zT,'Color',cols(i,:));
   

    hold on
    plot(yT(1),zT(1),'ko')
    daspect([1 1 1])

    prevy =  yT(1);
    prevz =  zT(1);



end

%%
%-- Now do take the circle, and apply rotation and translation to segments
angles = linspace(-pi,pi,2000);
x = zeros(size(angles))+rand(size(angles));
y = cos(angles);
z = sin(angles);




[~,~,bin] = histcounts(theta,binEdges);

binCentres = (binEdges(1:end-1)+binEdges(2:end))./2;


%-- Find points in bin centred at zero, which determine your start point
maxBin = max(bin);
figure
for i=1:maxBin
    xSeg = x(bin==i);
    ySeg = y(bin==i);
    zSeg = z(bin==i);

    [yR, zR] = rotatePoints(ySeg,zSeg,rotationAngles(i),rotationCentres(i,1),rotationCentres(i,2));

    yT = yR+translationVectors(i,1);
    zT = zR+translationVectors(i,2);

    subplot(2,1,1)
    hold on
    plot3(xSeg,ySeg,zSeg,'-','Color',cols(i,:));

    subplot(2,1,2)
    hold on
    plot3(xSeg,yT, zT, '-','Color',cols(i,:));
    daspect([1 1 1])
end

    