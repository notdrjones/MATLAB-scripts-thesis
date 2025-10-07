function [adjusted_img] = rollingballBackgroundSubtraction(img)
    
    % Define the ball radius
    ball_radius = 50;
    
    % Create a structuring element (ball-shaped)
    se = strel('disk', ball_radius);
    
    % Perform morphological opening (erosion followed by dilation)
    background = imopen(img, se);
    
    % Subtract the background from the original image
    subtracted_img = imsubtract(img,background);
    adjusted_img = imadjust(subtracted_img);
    % Display the original image
    figure('Name', 'Rolling Ball Background Subtraction', 'NumberTitle', 'off', ...
           'Position', [100, 100, 1200, 600]);
    subplot(1, 3, 1);
    imshow(img);
    title('Original Image');
    
    % Display the estimated background
    subplot(1, 3, 2);
    imshow(background);
    title('Estimated Background');
    
    % Display the background subtracted image
    subplot(1, 3, 3);
    imshow(adjusted_img);
    title('Background Subtracted Image');
end