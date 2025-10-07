function [f] = plotkymographStaticCell(currBac, fluorescenceStack, i, options)

if nargin<3

    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.cellIDlist = [60,61];
    options.saveflag = true;
    options.lengthpadforkymo = 10;
    options.widthpadforkymo = 5;
end

xCorrection = options.cropField(1);
yCorrection = options.cropField(2);

currBac(:,2) = currBac(:,2) + xCorrection;
currBac(:,3) = currBac(:,3) + yCorrection;

cell_len = ceil(currBac(1,4)) + options.lengthpadforkymo;
cell_width = ceil(currBac(1,5)) + options.widthpadforkymo;
    
x_cent = currBac(1,1);
y_cent = currBac(1,2);
theta = currBac(1,3);

kymograph = zeros(size(fluorescenceStack,3),cell_len+1);

for T=1:size(fluorescenceStack,3)
    %get actual frame rather than index
    %get specific frame of fluorescence
    fluorImg = fluorescenceStack(:,:,T);
    
   
    %create rectangle to crop with small padding
    x = (x_cent-(cell_len+5)/2);
    y = (y_cent-(cell_len+5)/2);
    wh = (cell_len+5);
    
    croppedFluorImg = imcrop(fluorImg, [x y wh wh]);
    
    rotCroppedFluorImg = rotateimage(croppedFluorImg, theta);
    %now crop again so that it is closely fitted to the cell outline
    [nr, nc] = size(rotCroppedFluorImg);
    x = nr/2 - cell_len/2;
    y = nc/2 - cell_width/2;
    w = cell_len;
    h = cell_width;

    imgforkymo = imcrop(rotCroppedFluorImg, [x y w h]);
    
    
    % kymograph(T,:) = max(imgforkymo,[],1);
    kymograph(T,:) = mean(imgforkymo,1);
end

% f = figure('Units','inches','Position',[1 1 2.5 4]);
figname = num2str(i);
f = figure('Name',figname);
colormap("gray");
imagesc(imgaussfilt(kymograph,2));



end