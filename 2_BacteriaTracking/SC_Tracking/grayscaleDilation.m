function [dilatedImg] = grayscaleDilation(img)

figure;
    subplot(1, 2, 1);
    imshow(img);
    title('Original Image');
    
    % Create the visionhdl.GrayscaleDilation System object
    dilation = visionhdl.GrayscaleDilation('Neighborhood', strel('disk', 15).Neighborhood);
    
    % Pad the image to avoid boundary issues during dilation
    padsize = [15, 15];  % Adjust based on the structuring element size
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
    % Display the dilated image
    subplot(1, 2, 2);
    imshow(dilatedImg);
    title('Dilated Image');
end