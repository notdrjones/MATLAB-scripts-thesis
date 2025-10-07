function calculateVelocity(datafolder,dt,pxsize,saveFlag,batchFlag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
dx = diff(bacteriaTrack(:,2));
dy = diff(bacteriaTrack(:,3));

idx = dx == 0;
dx = dx(~idx);
dy = dy(~idx);

v = pxsize.*sqrt(dx.^2+dy.^2)./dt;

histoFigure = figure;
histoFigure.Position = [1 1 400 400];
histo = histogram(v,'Normalization','probability');
histo.FaceColor = [0.30,0.75,0.93];
histo.EdgeColor = [0,0.45,0.74];
histo.FaceAlpha = 0.3;
histo.EdgeAlpha = 1;
histo.LineWidth = 1.5;

histoAxes = gca;
histoAxes.Box = "off";
histoAxes.FontName = 'Arial';
histoAxes.FontSize = 15;
histoAxes.LineWidth = 1.5;
histoAxes.TickDir = 'out';
pbaspect([1 1 1]);
xlabel('V (um/s)')
ylabel('Probability');
if saveFlag
    set(histoFigure,'Color','w');
    if ~exist([datafolder 'results\'],'dir')
        mkdir([datafolder 'results\']);
    end
    saveas(histoFigure,[datafolder 'results\velocityHistogram.fig']);
    saveas(histoFigure,[datafolder 'results\velocityHistogram.png']);
    save([datafolder 'results\velocityData.mat'],'v');
    close(histoFigure);
end

end

