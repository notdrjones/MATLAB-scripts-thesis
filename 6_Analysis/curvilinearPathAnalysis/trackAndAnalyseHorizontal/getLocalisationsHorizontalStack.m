function [locFitted, locEstimates] = getLocalisationsHorizontalStack(stackfilename,options)
%GETSTACKLOCALISATIONS 
% a function to run the findSpotsSC and findSpotGaussianFit algorithms for
% a whole stack


if isfield(options,'thresholdValue')
    thresholdValue = options.thresholdValue;
else
    thresholdValue = 0.8;
end

if ~isfield(options,'show')
    options.show = false;
end

if ~isfield(options,'save')
    options.save = true;
end
 

% first load the stack
stack = loadtiff(stackfilename);

nFrames = size(stack,3);


% for all frames of the stack, run findSpotsSC - this gives you the initial
% estimates for each frame
locEstimates = cell(nFrames,1);
locFitted = cell(nFrames,1);
for t=1:nFrames
%    [~, centroids] = findSpotsSC(stack(:,:,t),1,thresholdValue,0);
    [~, ~, centroids] = findSpotsSCv3(stack(:,:,t),options);


    locEstimates{t} = centroids;
    
    if ~isempty(centroids)
        for i=1:size(centroids,1) % one row per sample
            x_estimate = centroids(i,1);
            y_estimate = centroids(i,2);
%            [x_centre, y_centre, ~, ~, ~, ~,  ~, ~, ~] = findSpotGaussianFit(stack(:,:,t),x_estimate,y_estimate,subarray_halfwidth,inner_radius,sigma_gauss, error_set, clip_override, show_output);
             [x_centre, y_centre] = findSpotGaussianFitSC(stack(:,:,t),x_estimate,y_estimate);

            locFitted{t}(end+1,:) = [x_centre y_centre];
        end
    end


    if options.show
    imshow(imgaussfilt(stack(:,:,t),3),[]);
    if ~isempty(centroids)
    hold on
    plot(centroids(:,1),centroids(:,2),'r+');
    plot(locFitted{t}(:,1),locFitted{t}(:,2),'b+');
    hold off
    end
    drawnow;
    end
%     pause(0.1);
end

if options.save
    filename = strrep(stackfilename,'.tif','_localisations.mat');
    save(filename,'locFitted');
end


end

