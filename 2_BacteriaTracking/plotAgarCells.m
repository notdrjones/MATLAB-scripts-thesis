function plotAgarCells(folderPath)


[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];
bacLoc = importdata([resultsfolder 'refinedBacLoc.mat']);
brightfieldPath = fullfile(folderPath, 'brightfield.tif');
stack = loadtiff(brightfieldPath);
img = im2gray(stack(:,:,1));
% imgforplot = imadjust(img);
imgforplot = img;
[w,h] = size(img);


figure;

%actual plotting
% subplot('Position',posImg);
subplot(1,2,1);
imagesc(imgforplot);
axis equal

% subplot('Position',posGraph);
subplot(1,2,2);
hold on 
% cellfun(@(x) plotrectanglecell(x),bacLoc);
xlim([0 w]);
ylim([0 h]);
set(gca, 'YDir','reverse');
axis equal
for i= 1:height(bacLoc)
    plotrectanglecell(bacLoc{i}, i);
    % pause(10);
end


end