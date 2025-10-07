function [fociData] = analyseFociAllCells(fluorescenceStack, bacTracks, options)

if nargin<3

    options.cropField = [0 0 5496 3672];
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.normalisefluorescence = false;
    options.distfromedge = 10;

end

%convert some options to variables corrected to pixels rather than um to
%make things easier later
poleLen = options.poleLen*1000/options.pixelsize;
segWid = options.segmentwidth*1000/options.pixelsize;
xCorrection = options.cropField(1);
yCorrection = options.cropField(2);
disp(xCorrection);
disp(yCorrection);
fociData = {};
[nr,~]=size(bacTracks);


for k=1:nr
    currBac = bacTracks{k,:};
    
    %add buffer to cell length and width to include all fluorescence info
    cell_len = nanmean(currBac(:,5)) + 1;
    cell_width = nanmean(currBac(:,6)) + 1;
    nSegments = floor(cell_len/segWid);
    segWidAdj = cell_len/nSegments;
    %nSegments = options.nSegments;
    %don't go ahead if cell is too close to the edge of the frame at any
    %point
    check1 = any(currBac(:,2) < (cell_len/2 + options.distfromedge));
    check2 = any(currBac(:,3) < (cell_len/2 + options.distfromedge));
    check3 = any(currBac(:,2) > (options.cropField(3)-cell_len/2 - options.distfromedge));
    check4 = any(currBac(:,3) > (options.cropField(4)-cell_len/2 - options.distfromedge));
    checkarray = [check1, check2, check3, check4];
    disp(checkarray);
    if any(checkarray)
        disp('excluding cell');
    else
    
        %need to correct for cropping if it has happened, so make all values
        %higher to match the values in the raw fluorescence image
        currBac(:,2) = currBac(:,2) + xCorrection;
        currBac(:,3) = currBac(:,3) + yCorrection;
    
        currCell = [];
        %establish flipflag so that pole 1 is always the one that started
        %lower (higher y value)
        if currBac(1:4) < 0
            flipflag = 1;
        else 
            flipflag = 0;
        end
        for T=1:height(currBac)
            currFrame = [];
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
            
            if T ~=1
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
            else
                if theta <0 
                    flipflag  = 1;
                end
            end
                
            %create rectangle to crop with small padding
            x = (x_cent-(cell_len+5)/2);
            y = (y_cent-(cell_len+5)/2);
            wh = (cell_len+5);
                
                        
            croppedFluorImg = imcrop(fluorImg, [x y wh wh]);
            
            rotCroppedFluorImg = rotateimage(croppedFluorImg, -theta);
            
            
            %center of the cell is still center of the image
            %so need to work out bottom left of cell
            [imgHeight, imgWidth] = size(rotCroppedFluorImg);
            % disp(size(rotCroppedFluorImg));
    
            x_left = ((imgWidth-cell_len)/2);
            x_right = x_left + cell_len;
            y_min = ((imgHeight-cell_width)/2);
            y_max = y_min+cell_width;
            % disp(x_left);
            % disp(x_right);
            % disp(y_min);
            % disp(y_max);
    
            totalMeanFluorIntensity = mean2(rotCroppedFluorImg(round(x_left):round(x_right),round(y_min):round(y_max)));
    
            %if we want to record this direct to the dataframe
            
            segmentData = [t 0 totalMeanFluorIntensity];
            currFrame = [currFrame;segmentData];
            % %test plot
            % figure;
            % adj_img = imadjust(rotCroppedFluorImg);
            % imshow(adj_img);
            % axis on
            % hold on
            % rectangle('Position',[x_left y_min cell_len cell_width], EdgeColor=[1,0,0]);   
            
            %for the 'left' pole
            x_min = x_left;
            x_max = x_left + poleLen;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
           
            %if you want to normalise by total fluorescence intensity of
            %the cell
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
    
            if flipflag ==1
                segmentData = [t 3 avgIntensity];
            else
                segmentData = [t 1 avgIntensity];
            end
            currFrame = [currFrame;segmentData];
            
            %for the 'right' pole
            x_min = x_right - poleLen;
            x_max = x_right;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
    
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
    
            if flipflag ==1
                segmentData = [t 1 avgIntensity];
            else
                segmentData = [t 3 avgIntensity];
            end
            currFrame = [currFrame;segmentData];
            
            %for the cell middle
            x_min = x_left + poleLen;
            x_max = x_right - poleLen;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
            
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
    
            segmentData = [t 2 avgIntensity];
    
            currFrame = [currFrame;segmentData];
            
            currCell = [currCell; currFrame];
            
        
        end    
        
        fociData = [fociData;currCell];
    end
        
end
end