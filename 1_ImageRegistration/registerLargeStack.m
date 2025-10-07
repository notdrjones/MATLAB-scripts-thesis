function registerLargeStack(stackpath, tform)
%REGISTERLARGESTACK Summary of this function goes here
%   Detailed explanation goes here

% Combine the stacks into one big stack
%stackfiles = dir([stackfolder '*.ome.tif']);
%stack = combinelargestacks(stackfiles);

if isstring(stackpath)
    stackpath = convertStringsToChars(stackpath);
end
disp(stackpath);
stack = loadtiff(stackpath);

registered = stack;
tic
parfor i=1:size(registered,3)
    registered(:,:,i) = imwarp(stack(:,:,i), tform,'OutputView',imref2d(size(stack(:,:,i))));
end
toc
saveastiff(registered, stackpath);

end

