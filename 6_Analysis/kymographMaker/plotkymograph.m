function [f] = plotkymograph(currBac, fluorescenceStack, i, options)
%% old function, deprecated, use other specific kymograph plot functions


if nargin<3

    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.cellIDlist = [60,61];
    options.saveflag = true;
end

xCorrection = options.cropField(1);
yCorrection = options.cropField(2);

currBac(:,2) = currBac(:,2) + xCorrection;
currBac(:,3) = currBac(:,3) + yCorrection;

cell_len = currBac(1,4) + 1;
cell_width = currBac(1,5) + 1;


kymograph = zeros(size(fluorescenceStack,3),cell_len+1);

for T=1:height(currBac)
    %get actual frame rather than index
    t = currBac(T,1);
    %get specific frame of fluorescence
    fluorImg = fluorescenceStack(:,:,t);
    
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
    
    if T ==1
        if theta <0 
            flipflag  = 1;
        else 
            flipflag = 0;
        end
    else
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
        
    %create rectangle to crop with small padding
    x = (x_cent-(cell_len+5)/2);
    y = (y_cent-(cell_len+5)/2);
    wh = (cell_len+5);
    
    croppedFluorImg = imcrop(fluorImg, [x y wh wh]);
    
    if flipflag ==1
        theta = theta + 180;
    end
    
    rotCroppedFluorImg = rotateimage(croppedFluorImg, theta);
    %now crop again so that it is closely fitted to the cell outline
    [nr, nc] = size(rotCroppedFluorImg);
    x = nr/2 - cell_len/2;
    y = nc/2 - cell_width/2;
    w = cell_len;
    h = cell_width;

    imgforkymo = imcrop(rotCroppedFluorImg, [x y w h]);
    
    
    kymograph(T,:) = max(imgforkymo,[],1);
end

% f = figure('Units','inches','Position',[1 1 2.5 4]);
figname = num2str(i);
f = figure('Name',figname);
colormap("gray");
imagesc(imgaussfilt(kymograph,2));



end