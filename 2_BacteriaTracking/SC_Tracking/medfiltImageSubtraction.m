function [adjustedImg] = medfiltImageSubtraction(img)
% figure;
%     subplot(2, 4, 1);
%     imshow(img);
%     subplot(2,4,5);
%     imhist(img);
%     title('Original Image');
% 
%     dilatedImg = medfilt2(img, [50,50]);
%     % Display the dilated image
%     subplot(2, 4, 2);
%     imshow(dilatedImg);
%     subplot(2,4,6);
%     imhist(dilatedImg);
%     title('Median Filtered Image');
% 
%     subtractedImg = imsubtract(dilatedImg, img);
%     adjustedImg = imadjust(subtractedImg);
%     % Display the dilated image
%     subplot(2, 4, 3);
%     imshow(adjustedImg);
%     subplot(2,4,7);
%     imhist(adjustedImg);
%     title('Subtracted Image');


   % just functions without display
   dilatedImg = medfilt2(img, [50,50]);
   subtractedImg = imsubtract(dilatedImg, img);
   adjustedImg = imadjust(subtractedImg);
end