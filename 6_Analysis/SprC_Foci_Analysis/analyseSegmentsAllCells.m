function [fociData] = analyseSegmentsAllCells(fluorescenceStack, bacTracks, options)

if nargin<3

    options.poleLen=0.25; % in um
    options.segmentwidth = 0.5; % in um
    options.nSegments = 10; 
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels

end

%convert some options to variables corrected to pixels rather than um to
%make things easier later
poleLen = options.poleLen*1000/options.pixelsize;
segWid = options.segmentwidth*1000/options.pixelsize;

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
    currCell = [];
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
        %create rectangle to crop with small padding
        x = (x_cent-(cell_len+5)/2);
        y = (y_cent-(cell_len+5)/2);
        wh = (cell_len+5);
        
        croppedFluorImg = imcrop(fluorImg, [x y wh wh]);

        rotCroppedFluorImg = rotateimage(croppedFluorImg, -theta);
        
        %center of the cell is still center of the image
        %so need to work out bottom left of cell
        [imgHeight, imgWidth] = size(rotCroppedFluorImg);

        x_left = ((imgWidth-cell_len)/2);
        x_right = x_left + cell_len;
        y_min = ((imgHeight-cell_width)/2);
        y_max = y_min+cell_width;

        totalMeanFluorIntensity = mean2(rotCroppedFluorImg(x_left:x_right,y_min:y_max));
        %if we want to record this direct to the dataframe
        
        segmentData = [t 0 totalMeanFluorIntensity];
        currFrame = [currFrame;segmentData];
        % %test plot
        % figure;
        % imshow(rotCroppedFluorImg);
        % axis on
        % hold on
        % rectangle('Position',[x_left y_min cell_len cell_width]);   
        
        
        for i=1:nSegments
            x_min = x_left + (i-1)*segWidAdj;
            x_max = x_left + i*segWidAdj;
            avgIntensity = mean2(rotCroppedFluorImg(x_min:x_max,y_min:y_max));
            %if you want to normalise by total fluorescence intensity of
            %the cell
            %avgIntensity = avgIntensity / totalMeanFluorIntensity;
            segmentData = [t i avgIntensity];
            currFrame = [currFrame;segmentData];
        
            
        end
        
        currCell = [currCell; currFrame];
        

    end    
    
    fociData = [fociData;currCell];
    
        
end
end