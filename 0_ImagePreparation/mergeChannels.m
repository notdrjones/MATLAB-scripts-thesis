function mergeChannels(folderPath)

% % tformTable = readmatrix(tFormPath);
% % disp(tformTable);
% % points0 = tformTable(:,2:3);
% % points1 = tformTable(:,4:5);
% % points2 = tformTable(:,6:7);

% tformbfL = getGeomTransform(points0, points2);
tformLtobf = affinetform2d([0.988148351355423,0.001264165285185,25;-0.002541963954190,0.985176626540554,10;0,0,1]);



% tformbfR = getGeomTransform(points1, points2);
tformRtoL = affinetform2d([1.001311851227213,-0.002810326575859,10;0.001735338019960,1.001521984555212,6;0,0,1]);

    
% 
imgL = loadtiff([folderPath '_3_L.tif']);
imgR= loadtiff([folderPath '_3_R.tif']);
imgbf = loadtiff([folderPath '_3_bf.tif']);
% 
% disp([folderPath 'L.tif']);
% stack0 = loadtiff([folderPath 'L.tif']);
% stack1 = loadtiff([folderPath 'R.tif']);
% stack2 = loadtiff([folderPath 'brightfield.tif']);
% 
% imgL = stack0(:,:,1);
% imgR = stack1(:,:,1);
% imgbf = stack2(:,:,1);

sameAsInput = affineOutputView(size(imgR),tformRtoL,"BoundsStyle","SameAsInput");

imgR = imwarp(imgR, tformRtoL, "cubic", "OutputView",sameAsInput);

sameAsInput = affineOutputView(size(imgL),tformLtobf,"BoundsStyle","SameAsInput");

newimgL = imwarp(imgL, tformLtobf, "cubic", "OutputView",sameAsInput);

% sameAsInput = affineOutputView(size(imgL),tformbfL2,"BoundsStyle","SameAsInput");
% 
% newimgL2 = imwarp(imgL, tformbfL2, "cubic", "OutputView",sameAsInput);
% 
sameAsInput = affineOutputView(size(imgR),tformLtobf,"BoundsStyle","SameAsInput");

newimgR = imwarp(imgR, tformLtobf, "cubic", "OutputView",sameAsInput);

newimgbf = imadjust(imgbf);
newimgL = imadjust(newimgL);
newimgR = imadjust(newimgR);

D = cat(3,newimgL,newimgR,newimgbf);
figure;
imshow(D);

end

