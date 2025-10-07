function newImg = bkgrdSubtractSingleFrame(image, radius, padding)



[rows columns] = size(image);   % size of the image
% Pad the image.
imageP  = padarray(image, [(radius+1)/2 (radius+1)/2], padding, 'pre');
imagePP = padarray(imageP, [(radius-1)/2 (radius-1)/2], padding, 'post');
% Always use double because uint8 would be too small.
imageD = double(imagePP);
% Matrix 't' is the sum of numbers on the left and above the current cell.
t = cumsum(cumsum(imageD),2);
% Calculate the mean values from the look up table 't'.
imageI = t(1+radius:rows+radius, 1+radius:columns+radius) + t(1:rows, 1:columns)...
    - t(1+radius:rows+radius, 1:columns) - t(1:rows, 1+radius:columns+radius);
% Now each pixel contains sum of the window. But we want the average value.
imageI = imageI/(radius*radius);
% Return matrix in the original type class.
bkgrdImg = cast(imageI, class(image));

% figure;
% imshow(image)
% % se = offsetstrel("ball",radius,20);
% % bkgrdImg = imerode(img,se);
% figure;
% imshow(bkgrdImg)
newImg = imsubtract(imadjust(image), bkgrdImg/2);

newImg = imadjust(newImg);
% figure;
% imshow(newImg)
end