function analyse_foci_trajectory(croppedfolder)
%RECONSTRUCTLABFRAME Summary of this function goes here
%   Detailed explanation goes here

% -- load brightfield
brightfieldIm = loadtiff([croppedfolder 'brightfield_cropped.tif']);
leftIm = loadtiff([croppedfolder 'L_cropped.tif']);

%-- bacteria track
track = importdata([croppedfolder 'bacteriaTrack.mat']);

x = track(:,2);
y = track(:,3);
theta = track(:,4); % so that rotation is correct

theta = fix_angles2(theta);

cols = parula(size(brightfieldIm,3));

kymo = zeros(201,size(brightfieldIm,3)/2);

clf
T = 1;
for t=1:2:size(brightfieldIm,3)
    rotIm=imrotate( imgaussfilt(leftIm(:,:,t),2) ,theta(t),'crop');
    imshow(rotIm,[]);
    set(gca, 'Visible','on')
    drawnow;
    kymoData = smooth(sum(rotIm(50:150,:),1));
    kymoData = kymoData./max(kymoData);
    %hold on
    %plot(kymoData,'Color',cols(t,:),'LineWidth',1);

    kymo(:,T) = kymoData;
    T = T+1;
end

figure
imagesc(kymo)
end

