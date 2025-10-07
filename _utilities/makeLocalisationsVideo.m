function makeLocalisationsVideo(filepath, locpath, videopath)
%MAKE_LOCALISATION_VIDEO Summary of this function goes here
%   Detailed explanation goes here
v = VideoWriter(videopath);
open(v);


stack = loadtiff(filepath);
loc = importdata(locpath);

figure
for i=1:150
    imshow(imgaussfilt(stack(:,:,i),2),[]);

    locs = loc{i};
    hold on
    plot(locs(:,1),locs(:,2),'r+','LineWidth',1.5);
    hold off

    frame = getframe(gcf);
    writeVideo(v,(frame));
end

close(v)

end

