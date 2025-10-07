function wrapper_plotkymographs(folderPath, options)

if nargin<2
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.cellIDlist = [60,61];
    options.saveflag = true;
    options.useLandR = false;
    options.distfromedge = 10;
end

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];
datafolder = [mainDataFolderPath dirName folderName];
bacTracks = importdata([resultsfolder 'allBacteriaTracks.mat']);

if options.useLandR == true
    LStack = loadtiff([datafolder 'L.tif']);
    RStack = loadtiff([datafolder 'R.tif']);
    fluorescenceStack = LStack(:,:,end-1)/2 + RStack/2;
else
    fluorescenceStack = loadtiff([datafolder 'L.tif']);
end

if options.saveflag == true
    if ~exist([resultsfolder '/kymographs2'], 'dir')
        mkdir([resultsfolder '/kymographs2']);
    end
end

for k =1:height(bacTracks)
% for i =1:length(options.cellIDlist)
%     k = options.cellIDlist(i);
    currBac = bacTracks{k,:};
    cell_len = ceil(nanmean(currBac(:,5)));

    check1 = any(currBac(:,2) < (cell_len/2 + options.distfromedge));
    check2 = any(currBac(:,3) < (cell_len/2 + options.distfromedge));
    check3 = any(currBac(:,2) > (options.cropField(3)-cell_len/2 - options.distfromedge));
    check4 = any(currBac(:,3) > (options.cropField(4)-cell_len/2 - options.distfromedge));
    checkarray = [check1, check2, check3, check4];
    disp(checkarray);
    if any(checkarray)
        disp('excluding cell');
    else
    % f = plotkymograph(currBac, fluorescenceStack, k, options);
        f = plotkymographWithLeadLag(currBac, fluorescenceStack, k, options);
        
        if options.saveflag == true
            saveas(f,[resultsfolder '/kymographs2/' num2str(k) 'kymograph.png']);
            % saveas(f,[resultsfolder 'kymograph.fig']);
            % save([resultsfolder 'kymographdata.mat'], 'kymograph');
            close(f);
        end
    end
end

end