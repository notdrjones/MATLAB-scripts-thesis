function splitChannelsToStacks(stackFolder)
%SPLITLARGESTACKTOTWOSTACKS Summary of this function goes here
%   Detailed explanation goes here

% Get names of tif files
stackPaths = dir([stackFolder '*.ome.tif']);
disp(stackPaths);
% Count how many there are
nStacks = numel(stackPaths);
disp(nStacks);
% Here we load the first one as the combinedStacks
combinedStacks = loadtiff([stackFolder stackPaths(1).name]);

% Then loop through the rest, and append to the stack
for i=2:nStacks
    currentStack = loadtiff([stackFolder stackPaths(i).name]);
    
    combinedStacks = cat(3,combinedStacks,currentStack);
end

% Open metadata, get indexes
metadataPath = [stackFolder dir([stackFolder '*metadata.txt']).name];

indexValues = checkFrameId(metadataPath);
indexValues = indexValues(1:size(combinedStacks,3)); % This is to account for situations in which you don't combine all stacks, for whatever reason.

% Split the stacks according to indexes
stack0 = combinedStacks(:,:, indexValues == 0);
stack1 = combinedStacks(:,:, indexValues == 1);
stack2 = combinedStacks(:,:, indexValues == 2);

% Save and close.
% Here we use the L, R, Brightfield filenames to avoid having to edit
% further macros down the line.


saveastiff(stack0, [stackFolder 'L.tif']);
saveastiff(stack1, [stackFolder 'R.tif']);
saveastiff(stack2, [stackFolder 'brightfield.tif'])

end

