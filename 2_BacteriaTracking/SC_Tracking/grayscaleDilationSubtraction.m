function [adjustedImg] = grayscaleDilationSubtraction(img)

figure;
    subplot(2, 4, 1);
    imshow(img);
    subplot(2,4,5);
    imhist(img);
    title('Original Image');
    
    % Create the visionhdl.GrayscaleDilation System object
    dilation = visionhdl.GrayscaleErosion('Neighborhood', strel('disk', 15).Neighborhood);
    
    % Pad the image to avoid boundary issues during dilation
    padsize = [10, 10];  % Adjust based on the structuring element size
    paddedImg = padarray(img, padsize, 'replicate');
    
    % Preallocate the output image
    dilatedImg = zeros(size(img), 'uint8');
    
    % Perform grayscale dilation
    for row = 1:size(img, 1)
        for col = 1:size(img, 2)
            % Extract the neighborhood window
            r1 = max(row - 5, 1);
            r2 = min(row + 5, size(img, 1));
            c1 = max(col - 5, 1);
            c2 = min(col + 5, size(img, 2));
            
            window = img(r1:r2, c1:c2);
            
            % Apply grayscale dilation
            dilated_value = max(window(:));
            dilatedImg(row, col) = dilated_value;
        end
    end
    dilatedImg = imgaussfilt(dilatedImg,5); % Gaussian blur to make the image easier to work with
    % Display the dilated image
    subplot(2, 4, 2);
    imshow(dilatedImg);
    subplot(2,4,6);
    imhist(dilatedImg);
    title('Dilated Image');

    subtractedImg = imsubtract(dilatedImg, img);
    adjustedImg = imadjust(subtractedImg);
    % Display the dilated image
    subplot(2, 4, 3);
    imshow(adjustedImg);
    subplot(2,4,7);
    imhist(adjustedImg);
    title('Subtracted Image');

end