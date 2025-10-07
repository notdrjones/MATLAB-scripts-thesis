function [leadlaglist] = getLeadLagSpeeds(currBac, options)
%this is set up so that poles are assigned as 1 and 2 at the beginning of the script
% such that pole 1 is always the pole that starts higher up (i.e. lower
%value of y)
if nargin<3

    options.cellspeedsmoothing = 5;

end

%convert some options to variables corrected to pixels rather than um to
%make things easier later
n = options.cellspeedsmoothing;
leadlaglist = zeros(height(currBac),2);

%establish flipflag with the same convention as the non-smoothed data
if currBac(1+n,4) < 0
    flipflag = 1;
else 
    flipflag = 0;
end

for T=(1+n):(height(currBac)-n)
    %add buffer to cell length and width to include all fluorescence info
    cell_len = nanmean(currBac(:,5)) + 1;
    cell_width = nanmean(currBac(:,6)) + 1;

    %nSegments = options.nSegments;
    currFrame = [];
    %get actual frame rather than index
    t = currBac(T,1);


    x_cent = currBac(T,2);
    y_cent = currBac(T,3);
    theta = currBac(T,4);
    
    if isnan(theta)
        plus = 1;
        while isnan(theta)
            theta = currBac(T + plus, 4);
            plus = plus +1;
        end
    end
    
    %added in flipflag to stop the poles from 'flipping' - this way the
    %pole considered 'left' remains the same throughout, with large
    %changes in theta causing flipflag to be activated
    
    if T >(1+n)
        prevtheta = currBac(T-1,4);
        if isnan(prevtheta)
            plus = 1;
            while isnan(prevtheta)
                prevtheta = currBac(T-1 - plus, 4);
                plus = plus +1;
            end
        end
        if abs(prevtheta - theta) > 90
            if flipflag == 0
                flipflag = 1;
            else
                flipflag = 0;
            end
        end
    end
    
    %calculate angle of movement vector (between n frames earlier and n frames later)
    %put it as between 0 and 360 degrees anticlockwise from the
    %positive x axis 
    

    x1 = currBac(T-n,2);
    x2 = currBac(T+n,2);
    y1 = currBac(T-n,3);
    y2 = currBac(T+n,3);
    vectorangle = get360angleofvector(x1, x2, y1, y2);
    speed = sqrt((x2-x1)^2 + (y2-y1)^2);

    %need to add 90 or 270 to theta depending on flipflag so that the
    %cell can essentially rotate 
    if flipflag == 0
        theta = theta + 90;
    else 
        theta = theta + 270;
    end

    %now if we subtract the angles, if close to zero then pole 1 is
    %leading, if close to 180 then it is lagging

    %keep a record of previous to log reversals
    % oldleading = leading;

    if (270 > abs(vectorangle - theta)) && (90 < abs(vectorangle - theta))
        leading = 1;
    else 
        leading = 2;
        speed = -speed;
    end
    
    leadlaglist(T,:) = [leading speed];


end

for i = 1:n
    leadlaglist(i,:) = leadlaglist(n+1,:);
    leadlaglist(height(currBac)+1-i, :) = leadlaglist(height(currBac)-n,:);
end
end
