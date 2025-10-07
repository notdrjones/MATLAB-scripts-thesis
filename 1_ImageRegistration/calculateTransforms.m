function [tformRtoL,tformBtoL] = calculateTransforms(parallaxPath,brightfieldPath,flipFlag,outputPath)
    %CALCULATETRANSFORMS Summary of this function goes here
    %   Detailed explanation goes here
    
    % Load parallax frame
    L = imread(parallaxPath);
    Rpath = [parallaxPath(1:end-5) 'R.tif'];
    R = imread(Rpath);
    
    % Load brightfield frame
    brightfield = imread(brightfieldPath);
    
    if flipFlag
        brightfield = flip(brightfield,2);
    end
    
    
    
    % Find transform to align brightfield to L channel
    fixed = L;
    moving = brightfield;
    
    [optimizer,metric] = imregconfig("multimodal");
    
    tformBtoL = imregtform(moving,fixed,"rigid",optimizer,metric);
    
    % Find transform to align R to L channel
    fixed = L;
    moving = R;
    
    [optimizer,metric] = imregconfig("multimodal");
    
    tformRtoL = imregtform(moving,fixed,"rigid",optimizer,metric);
    
    % Save to folder
    save([outputPath '\tformRtoL.mat'], 'tformRtoL');
    save([outputPath '\tformBtoL.mat'], 'tformBtoL');
end

