function findCellEdges(datafolder,saveflag)
%FINDCELLEDGES Summary of this function goes here
%   Detailed explanation goes here
output = false;
datafolder = [datafolder 'translatedAndRotated\'];
bacteriaTrack = importdata([datafolder 'bacteriaTrackHorizontal.mat']);
bacteriaEdgesTrack = zeros(size(bacteriaTrack,1),3);

brightfieldStack = loadtiff([datafolder 'brightfieldRotatedAndTranslated.tif']);
nImages = size(brightfieldStack,3);

for i=1:nImages
    currentImage = brightfieldStack(:,:,i);
    try
    threshEstimate = currentImage(ceil(bacteriaTrack(i,3)),ceil(bacteriaTrack(i,2)));


    %--
    thresholdedImage = currentImage < threshEstimate+20;
    
    stats = regionprops("table",thresholdedImage,"Centroid","PixelList");
    
    centroids = stats.Centroid;

    % Find closest to position
    xDistances = abs(bacteriaTrack(i,2)-centroids(:,1));
    [~,minIdx]=min(xDistances);

    % 
    pixelsChosenObject = stats.PixelList{minIdx};

    xL = min(pixelsChosenObject(:,1))-2;
    xR = max(pixelsChosenObject(:,1))+2;
    catch
        xL = nan;
        xR = nan;
    end

    %-- Plot to confirm
    if output
        imshow(currentImage)
        hold on
        plot(bacteriaTrack(i,2),bacteriaTrack(i,3),'bo')
        plot(centroids(minIdx,1),centroids(minIdx,2),'r+');
        plot(xL,centroids(minIdx,2),'r.');
        plot(xR,centroids(minIdx,2),'g.');
        drawnow;
    end
  
bacteriaEdgesTrack(i,:) = [i xL xR];
end

if saveflag
    save([datafolder 'bacteriaEdgesTrack.mat'],'bacteriaEdgesTrack');
end
end

