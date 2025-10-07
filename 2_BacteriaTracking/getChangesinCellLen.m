function [array] = getChangesinCellLen(track_points)

medianCellLen = median(track_points(:,5));
array = zeros([size(track_points,1) 1]);

for i = 1:height(track_points)
    cell_len = track_points(i,5);
    changefactor = cell_len/medianCellLen;
    array(i) = changefactor;
end
end