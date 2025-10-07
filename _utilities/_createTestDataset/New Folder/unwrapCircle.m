function [xyzPointsUnrolled] = unwrapCircle(xyzPoints, xyzRef,T)
%UNWRAPCIRCLE Summary of this function goes here
%   Detailed explanation goes here

% Divide points on reference ellipse
xRef = xyzRef(:,1);
yRef = xyzRef(:,2);
zRef = xyzRef(:,3);

% Find centre of shape
xCentre = mean(xRef);
yCentre = mean(yRef);
zCentre = mean(zRef);

% Points are shifted so that they are in a frame of reference whose centre
% is the centre of the reference circle
xRef = xRef - xCentre;
yRef = yRef - yCentre;
zRef = zRef - zCentre;

yStartPoint = min(yRef);

xyzPoints1 = xyzPoints;
xyzPoints = xyzPoints - [xCentre yCentre zCentre];


% Get angles in cylindrical coords
%thetaRef = atan2(yRef,zRef);
thetaRef = (linspace(-pi,pi,2000))';
if isequal(thetaRef(1),pi)
    thetaRef(1) = [];
    xRef(1) = [];
    yRef(1) = [];
    zRef(1) = [];
end
% thetaRef = unwrap(thetaRef);

%-- Split angles in bins of X degrees 
nBins = 360/45;
%binEdges = linspace(-pi,pi,nBins);

binEdges = linspace(min(thetaRef),max(thetaRef),nBins);

[~,~,bin] = histcounts(thetaRef,binEdges);

binCentres = (binEdges(1:end-1)+binEdges(2:end))./2;
maxBin = max(bin);

normalVectors = zeros(maxBin,2);
rotationCentres = zeros(maxBin,2);
rotatedSegments = cell(maxBin,1);
rotationAngles = zeros(maxBin,1);
translationVectors = zeros(maxBin,2);

prevy = 0 ;
prevz = 0;

cols = jet(maxBin);
for i=1:maxBin
    xSeg = xRef(bin==i);
    ySeg = yRef(bin==i);
    zSeg = zRef(bin==i);

  
    % Find centre of segment
    xMSeg = xRef(1);
    yMSeg = mean(ySeg);
    zMSeg = mean(zSeg);

   
    % Find vector parallel to segment
    dyAll = diff(ySeg);
    dzAll = diff(zSeg);
    dy = mean(dyAll);
    dz = mean(dzAll);

    normFactor = sqrt(dy.^2 + dz.^2);

    % Get unit vector
    dyNorm = dy./normFactor;
    dzNorm = dz./normFactor;
    
    % % DEBUGGING - PLOT SEGMENT AND UNIT VECTOR
    % subplot(2,1,1)
    % hold on;
    % plot(ySeg,zSeg,'Color', cols(i,:))
    % plot(ySeg(1),zSeg(1),'o','Color',cols(i,:))
    % quiver(yMSeg,zMSeg,-dzNorm,dyNorm,'k')
    % daspect([1 1 1]);
    
    normalVectors(i,:) = [dzNorm -dyNorm];

    rotationAngles(i) = pi/2-atan2(dyNorm,-dzNorm); % pi/2-atan2(dyNorm,-dzNorm)
    rotationCentres(i,:) = [yMSeg zMSeg];

    [yR, zR] = rotatePoints(ySeg,zSeg,rotationAngles(i),yMSeg,zMSeg);

    rotatedSegments{i} = [yR zR];

    DY =-yR(1)+prevy; % end
    DZ = -zR(1)+prevz;

    translationVectors(i,:) = [DY DZ];

    yT = yR+DY;
    zT = zR+DZ;
 
%     prevy =  yT(1);
%     prevz =  zT(1);

    prevy = yT(end);
    prevz = zT(end);

        % DEBUGGING - PLOT SEGMENT AND UNIT VECTOR
% 
    % subplot(2,1,2)
    % plot3(yT.*0,yT,zT,'Color',cols(i,:))
    % daspect([1 1 1])
    % hold on
    % plot3(0,yT(1),zT(1),'o','Color',cols(i,:))

end

% Now apply rotations to localisations
x = xyzPoints(:,1);
y = xyzPoints(:,2);
z = xyzPoints(:,3);


% Get angles in cylindrical coords
theta = atan2(y,z);
%theta = unwrap(theta);


% % Check if there's any theta smaller than -3*pi/2
% idx = find(theta<-3*pi/2);
% % clf
% % plot(theta)
% % hold on
% while isempty(idx) == 0
%     theta(theta<-3*pi/2) = theta(theta<-3*pi/2)+2*pi;
%     %plot(theta)
%     idx = find(theta<-3*pi/2);
% end


[~,~,bin] = histcounts(theta,binEdges);

if ~isempty(find(bin==0))
    a=1;
end

maxBin = max(bin);

% Pre-allocate space for unrolled x,y,z
xyzPointsUnrolled = cell(maxBin,1);

cols = jet(maxBin);
    % DEBUGGING - PLOT SEGMENT AND UNIT VECTOR
%figure
for i=1:maxBin
    %xSeg = x(bin==i)+yStartPoint+xCentre;
    xSeg = xyzPoints1(bin==i);
    ySeg = y(bin==i);
    zSeg = z(bin==i);
    tSeg = T(bin==i);

    [yR, zR] = rotatePoints(ySeg,zSeg,rotationAngles(i),rotationCentres(i,1),rotationCentres(i,2));

    yT = yR+translationVectors(i,1);
    zT = zR+translationVectors(i,2);
% 
%      % DEBUGGING - PLOT SEGMENT AND UNIT VECTOR
%    subplot(2,1,1)
%    hold on
%    plot3(xSeg,yT,zT,'-','Color',cols(i,:));
% 
%     subplot(2,1,2)
%     hold on
%     plot3(xSeg,yT, zT, '-','Color',cols(i,:));
% %plot(smooth(xSeg),smooth(yT), '-','Color',cols(i,:));
%     daspect([1 1 1])
%     
    xyzPointsUnrolled{i} = [xSeg yT tSeg];
end

xyzPointsUnrolled = cell2mat(xyzPointsUnrolled);
end

