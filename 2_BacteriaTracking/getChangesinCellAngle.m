function [array] = getChangesinCellAngle(track_points)

array = zeros([size(track_points,1) 1]);

for i = 1:height(track_points)
    theta = track_points(i,4);
    if isnan(theta)
        plus = 1;
        while isnan(theta)
            theta = currBac(i + plus, 4);
            plus = plus +1;
        end
    end

    if i >1
        change = abs(prevtheta - theta);
    else
        change = 0;
    end
    prevtheta = theta;
    array(i) = change;
end

end