function calculateWobble(datafolder,dt,saveFlag,batchFlag)
%CALCULATEWOBBLE Summary of this function goes here
%   Detailed explanation goes here
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
x = smooth(bacteriaTrack(1:2:end,2));
y = smooth(bacteriaTrack(1:2:end,3));

theta = smooth(bacteriaTrack(1:2:end,4));
[thetaNew,thetaNewUnwrapped] = fixThetaWrapping(theta);

theta = thetaNew; % Use the correct theta.
theta = deg2rad(theta);

alpha = [cos(theta) sin(theta)];
alpha = alpha(2:end,:);

v = [diff(x) diff(y)];
v_unit = v./sqrt(v(:,1).^2+v(:,2).^2);

nPoints = size(alpha,1);
timePoints = dt.*(1:nPoints)';
wobble = zeros(nPoints,1);
for i=1:nPoints
    wobble(i) = dot(alpha(i),v_unit(i)); 
end

wobble = smooth(wobble);

%-- NOW PLOT
wobbleFigure = figure;
wobbleFigure.Position = [1 1 400 400];
plt = plot(timePoints,wobble);
plt.LineWidth = 1;
plt.Color = [0,0.45,0.74];

wobbleAxes = gca;
wobbleAxes.Box = "off";
wobbleAxes.YLim = [-1 1];
wobbleAxes.FontName = 'Arial';
wobbleAxes.FontSize = 15;
wobbleAxes.LineWidth = 1.5;
wobbleAxes.TickDir = 'out';
pbaspect([1 1 1]);

ylabel('Wobble');
xlabel('Time (s)');

%-- SAVE AND CLOSE IF BATCHED
if saveFlag
    set(wobbleFigure,'Color','w');
    resultsFolder = [datafolder 'results\'];
    if ~exist(resultsFolder,'dir')
        mkdir(resultsFolder);
    end
    saveas(wobbleFigure,[resultsFolder 'wobblePlot.fig']);
    saveas(wobbleFigure,[resultsFolder 'wobblePlot.png']);

    wobbleData = [timePoints wobble];
    save([datafolder 'wobbleData.mat'],'wobbleData');

    if batchFlag
        close(wobbleFigure);
    end
end
end

