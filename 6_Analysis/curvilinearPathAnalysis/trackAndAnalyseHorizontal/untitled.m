for i=1:length(folderlist)
    try
        % Load localisations
        locCell = importdata([datafolder folderlist{i} 'translatedAndRotated\fluorescenceRotatedAndTranslated_localisations.mat']);
        index = find(cellfun(@(x) isempty(x), locCell)==1);
        for j=1:length(index)
            locCell{index(j)} = [nan nan];
        end
        tracks = make_trajectories(locCell,'max_linking_distance',10,'max_gap_closing',10);
    catch
        tracks = {};
    end
    try
    save([datafolder folderlist{i} 'translatedAndRotated\SprBHorizontalTrack1.mat'], 'tracks');
    catch
    end
end
