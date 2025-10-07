function [fociData] = analyseFociAllCells2(fluorescenceStack, bacTracks, options)

%unlike previous function of the same name, this one saves the data for
%each frame as a single row, with the subsequent columns being total
%fluorescence intensity, pole 1 (as defined), middle, pole 2, with a
%leading/lagging flag saying whether pole1 is leading

if nargin<3

    options.cropField = [1536 426 2484 2556];
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.normalisefluorescence = false;
    options.distfromedge = 10;
    options.minFluorescence = 0;
end

%convert some options to variables corrected to pixels rather than um to
%make things easier later
poleLen = options.poleLen*1000/options.pixelsize;
segWid = options.segmentwidth*1000/options.pixelsize;
xCorrection = options.cropField(1);
yCorrection = options.cropField(2);
fociData = {};
[nr,~]=size(bacTracks);


for k=1:nr
    currBac = bacTracks{k,:};
    
    %add buffer to cell length and width to include all fluorescence info
    cell_len = nanmean(currBac(:,5)) + 1;
    cell_width = nanmean(currBac(:,6)) + 1;


    %don't go ahead if cell is too close to the edge of the frame at any
    %point
    check1 = any(currBac(:,2) < (cell_len/2 + options.distfromedge));
    check2 = any(currBac(:,3) < (cell_len/2 + options.distfromedge));
    check3 = any(currBac(:,2) > (options.cropField(3)-cell_len/2 - options.distfromedge));
    check4 = any(currBac(:,3) > (options.cropField(4)-cell_len/2 - options.distfromedge));
    checkarray = [check1, check2, check3, check4];

    % disp(checkarray);
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
            %test plot
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
            Lave = avgIntensity;

            %for the cell middle
            x_min = x_left + poleLen;
            x_max = x_right - poleLen;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
            
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
            midave = avgIntensity;

            
            %for the 'right' pole
            x_min = x_right - poleLen;
            x_max = x_right;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
    
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
            Rave = avgIntensity;

            
            %for the cell middle
            x_min = x_left + poleLen;
            x_max = x_right - poleLen;
            avgIntensity = mean2(rotCroppedFluorImg(round(x_min):round(x_max),round(y_min):round(y_max)));
            
            if options.normalisefluorescence == true
                avgIntensity = avgIntensity / totalMeanFluorIntensity;
            end
    
            % need to include bacteria number at start so it can be matched
            % with bactracks
            currFrame = [k t totalMeanFluorIntensity Lave midave Rave];
            
            currCell = [currCell; currFrame];
            
        
        end 
        
        startintensity = mean(currCell(1,3));
        
        if  startintensity > options.minFluorescence
        
            leadlaglist = getLeadingLaggingFlags(currBac, options);
    
            currCell = horzcat(currCell, leadlaglist);
            
            fociData = [fociData;currCell];
        else 
            disp("Cell too dim");
        end
    end
        
end
end