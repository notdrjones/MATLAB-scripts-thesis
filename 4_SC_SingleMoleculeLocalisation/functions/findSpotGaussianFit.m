function [x_centre, y_centre, Ibg_avg, Isp, Idata, bg_noise_std,  mask_pixels, clipping_flag, noConvergenceFlag] = findSpotGaussianFit(image_data,x_estimate,y_estimate,subarray_halfwidth,inner_radius,sigma_gauss, error_set, clip_override, show_output)
%FINDSPOTGAUSSIANFIT is a function heavily based on "findSpotCentre2" by
%Adam Wollman and Helen Miller. I haven't really changed any functionality,
%just made it a bit more legible for my purposes and mind.
%
% Function to iteratively find the centre of a fluorescence spot on an image.
% 
% 
% Inputs:  
% image_data is a matrix containing the image data for a single frame. 
% image_data is a matrix with original values.
% image_data is later made of class double.
%
% x_estimate, y_estimate are the initial estimated centre positions for the
% iterative method.
%
% subarray_halfsize: the algorithm selects this number of pixels above and below and to
% left and right of estimated centroid pixel to form the selected image
% subarray (I). (The default value is 8 pixels).
%
% inner_radius: radius of inner circular mask in pixels (default is 5 pixels). This mask moves
% around inside the subarray to find the bright spot.
%
% sigma_gauss: sigma of gaussian mask in pixels (default is 2 pixels).
%
% error_set: the criterion for convergence (default is 0.05 pixels). Stops
% iteration if criterion is met.
%
% clip_override=1 if you want to return initial data if clipping flag=1
% i.e. if spot goes outside the "subarray_halfsize" specified.
%
% show_output: =1 if you want things to be outputted. Useful for debugging.
%
% Outputs: x_centre, y_centre, clipping_flag, Ibg_avg, Isp, Idata,
% bg_noise_std,  mask_pixels, noConvergenceFlag.
% NEED TO WRITE WHAT EACH IS

% make image_data a double
image_data = double(image_data);

% important check, inner_radius must be larger than subarray_halfwidth
if subarray_halfwidth < inner_radius
    error('Inner radius must be larger than subarray halfwidth.');
end

% HERE INCLUDE DEALING WITH EDGE SPOTS
d = subarray_halfwidth;
if (round(y_estimate)-d)<1
    y_estimate = d+1;
end
if (round(y_estimate)+d)>size(image_data,1)
    y_estimate = size(image_data,1)-d;
end
if (round(x_estimate)-d)<1
    x_estimate = d+1;
end
if (round(x_estimate)+d)>size(image_data,2)
    x_estimate = size(image_data,2)-d;
end    

% create image subarray (I) of size (2*d+1)x(2*d+1)
I = image_data(round(y_estimate)-d:round(y_estimate)+d,round(x_estimate)-d:round(x_estimate)+d);
Idata=I;
if show_output==1
    imshow(I, [],'InitialMagnification',1000)
    title('image subarray (I) of size (2*d+1)x(2*d+1) (default size 17x17) centred on thecentroid estimate pixel (x_estimate,y_estimate).')
end

% Create matrices containing the x and y positions corresponding to the
% subarray I. Xs is a matrix of the same size as I, containing x values for
% all pixels and similarly for Ys.
[Xs,Ys] = meshgrid(round(x_estimate)-d:round(x_estimate)+d,round(y_estimate)-d:round(y_estimate)+d);

% Initialise values and arrays to start iterative process
k = 1; % loop index
clipping_flag = 0; % set to allow loop to start.
loc_error = 1;
x_centre = x_estimate;
y_centre = y_estimate;

% The follow lists keep a record of the various iterative attempts
list_Xcentre = x_estimate;
list_Ycentre = y_estimate;
list_deltaX = nan;
list_deltaY = nan;
list_error = nan;
list_iteration = nan;
list_clip_flag = nan;
list_Ibg = nan; % Average background intensity in image subarray.
list_Isp = nan; % Total intensity within the spot (inner circle) mask in subarray, background corrected.

% LOOP FOR ITERATIVE SEARCH
while (loc_error>error_set || k<11) && clipping_flag==0 % at least 10 iterations. Method convergence criterion loc_error<error_set. Stop iterations if clipping flag goes on.
    % Create a "inner circle mask". A circle of radius "inner_radius"
    % centred at the current estimate of x_centre, y_centre

    % Start by making a distance matrix, just a matrix with distances from
    % centre.
    distance_matrix = sqrt((Xs-x_centre).^2+(Ys-y_centre).^2);

    % Binary mask. Every point closer than inner_radius is 1. Otherwise 0.
    inner_mask = distance_matrix<=inner_radius;

    % Gaussian mask. Use distance to calculate gaussian. We normalise it
    % after calculating it.
    gauss_mask = exp(-(distance_matrix.^2)./(2*sigma_gauss^2));
    gauss_mask = gauss_mask./sum(gauss_mask, 'all');

    if show_output==1
        imshow(gauss_mask, [],'InitialMagnification',1000)
        title('Gaussian Mask')
    end

    % mask_pixels is the sum of all pixels in the binary mask.
    mask_pixels = sum(inner_mask, 'all');

%     if show_output==1
%         imshow(mask_gauss, [],'InitialMagnification',1000)
%         title('Gaussian Mask')
%     end

    % Now calculate the bg mask, which is just the inverse of the
    % inner_mask.
    bg_mask = double(~inner_mask); % We choose double to help with next steps
    pos_bg = find(bg_mask==1); % List of positions of bg.

    Ibg = I.*bg_mask; % Image with only bg.
    if show_output==1
        imshow(Ibg, [],'InitialMagnification',1000)
        title('bgnd region.')
        
    end

    %------------------------------
    % Calculate total bg intensity
    Ibg_tot = sum(Ibg,'all');
    Ibg_avg = mean2(Ibg(pos_bg));

    % Calculate background-corrected subarray image:
    I2 = I-Ibg_avg;
    if show_output==1
        imshow(I2, [],'InitialMagnification',1000)
        title('background-corrected subarray image:')
        
    end

    % standard deviation of remaining background noise.
    bg_noise_std = std(I2(pos_bg)); % standard deviation of matrix elements in bgnd region.
    % Total spot intensity (within the inner circle mask), background corrected:
    Isp = sum(sum(I2.*inner_mask));     

    I3 = I2.*gauss_mask;
    if show_output==1
        imshow(I3, [],'InitialMagnification',1000)
        title('product of background-corrected image and Gaussian mask')
        
    end

    % Calculate revised estimates of x and y centre positions by multiplying I2 by
    % a Gaussian mask (result is I3) and weighing positions by the intensity value in that result:
    x_centre_new = sum(sum(I3.*Xs))/sum(sum(I3));
    y_centre_new = sum(sum(I3.*Ys))/sum(sum(I3));
    
    delta_x = x_centre_new - x_centre; % rounded to integer pixels
    delta_y = y_centre_new - y_centre;
    
    % loc_error is the error deviation used to decide if the method has converged or not:
    loc_error = sqrt(delta_x^2 + delta_y^2); % error 1 is the distance in pix between old and new centroid estimates.
   
    % -----------------------------------------------------
    % Clipping flag: 
    % If the inner circle mask moves too far away from the fixed centre of
    % the image subarray, i.e., if the inner-circle mask clips the edge of
    % the square subarray, the "Clipping flag" goes on and takes a value of
    % 1. Otherwise, it is zero. A clipping flag value of 1 indicates the
    % found spot is not very reliable.
    d_found_centre_x = abs(x_centre_new - x_estimate); 
    d_found_centre_y = abs(y_centre_new - y_estimate); 
    
    if d_found_centre_x >(subarray_halfwidth-inner_radius+1) || d_found_centre_y >(subarray_halfwidth-inner_radius+1) % inner mask clips edge of subarray.
        clipping_flag = 1;
    else
        clipping_flag = 0;
    end

    % ---------------------------------------------------- 
    % update lists:
    list_Xcentre(k+1) = x_centre_new;
    list_Ycentre(k+1) = y_centre_new;
    list_deltaX(k) = delta_x;
    list_deltaY(k) = delta_y;
    list_error(k) = loc_error;
    list_clip_flag(k) = clipping_flag;
    list_iteration(k+1) = k;
 
    list_Ibg(k) = Ibg_avg; % Average background intensity in image subarray.
    list_Isp(k) = Isp; % Total intensity within the spot (inner circle) mask in subarray, background corrected.
    
    % re-asign values for next iteration:
    x_centre = x_centre_new;
    y_centre = y_centre_new;
    k = k+1;
        
    % prevent infinite loop:
    if k>300
        % disp('The method did not reach convergence after 300 iterations.')
        noConvergenceFlag = 1;
        % Note that in this case the following break gets us out of the
        % loop.
        break
    else
        noConvergenceFlag = 0;
    end   
end % end of while loop.

% If didn't converge or clipped, just return the original estimate.
if noConvergenceFlag == 1 || clipping_flag == 1
    x_centre=x_estimate;
    y_centre=y_estimate;
end

end % Function end.

