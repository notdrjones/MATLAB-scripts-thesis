function [locCell3D] = reconstruct3DLocsCROPPED(datafolder,saveflag)
%RECONSTRUCT3DLOCS Summary of this function goes here
%   Detailed explanation goes here

% we use localizations from my code, instead of peakfit
filenameL = [datafolder 'L_cropped_localisations.mat'];
filenameR = [datafolder 'R_cropped_localisations.mat'];
locCellL = importdata(filenameL);
locCellR = importdata(filenameR);

% To avoid any errors from empty cells (frames with no localizations), put
% a [NaN NaN] in the empty cells.
index = find(cellfun(@(x) isempty(x), locCellL)==1);
for i=1:length(index)
    locCellL{index(i)} = [nan nan];
end

locCell3D = cell(size(locCellL));

for i=1:length(locCellL)
    currentLocs = locCellL{i};
    currentLocs3D = [];
    if ~isempty(currentLocs)
        for j=1:size(currentLocs,1)
            xL = currentLocs(j,1);
            yL = currentLocs(j,2);

            % Look for a matching localisation
            if ~isempty(locCellR{i})
                [xR, yR, matchingFlag] = autoMatchPoint([xL yL], locCellR{i},10);
            end

            if ~isnan(matchingFlag)
                % If a match has been found, get 3D Value
                x = (xL+xR)./2;
                y = (yL+yR)./2;

                z = 0.19*(xL-xR)-0.3;

                
                currentLocs3D(end+1,:) = [i x y z./0.12];
            end
        end
        locCell3D{i} =currentLocs3D;
    end 
end

index = find(cellfun(@(x) isempty(x), locCell3D)==1);
for i=1:length(index)
    locCell3D{index(i)} = [nan nan];
end

if saveflag
    % Make 3D Locs Figure
    locs = cell2mat(locCell3D);
    f = figure;
    scatter3(locs(:,2),locs(:,3),locs(:,4),10,locs(:,1),'filled');
    colormap jet
    grid on
    daspect([1 1 1]);

    % Now save both figure and data
    saveas(gcf,[datafolder 'localisations3D_CROPPED.fig']);
    save([datafolder 'localisations3D_CROPPED.mat'],'locCell3D');
    close(f);
end

end


