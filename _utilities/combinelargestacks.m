function [fullstack] = combinelargestacks(filenames)
folder = [filenames(1).folder '\'];

% Load up first image
fullstack = loadtiff([folder filenames(1).name]);

if length(filenames)>1
    for i=2:length(filenames)
        tempstack = loadtiff([folder filenames(i).name]);
        fullstack = cat(3,fullstack,tempstack);
    end
end
end

