function splitChannelsToStacks(stackFolder)
%SPLITLARGESTACKTOTWOSTACKS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    options.Ltobftform = affinetform2d([0.988148351355423,0.001264165285185,25;-0.002541963954190,0.985176626540554,10;0,0,1]);
    options.RtoLtform = affinetform2d([1.001311851227213,-0.002810326575859,10;0.001735338019960,1.001521984555212,6;0,0,1]);
    options.cropvideo = 0;
end
    
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
stack1len = height(indexValues(indexValues==1));
tformLtobf = options.Ltobftform;
tformRtoL = options.RtoLtform;

% Split the stacks according to indexes
stack0 = combinedStacks(:,:, indexValues == 0);

stacklength = size(stack0,3)- options.cropvideo;
disp(stacklength);
    
if size(stack0,3) > stack1len
    stack0 = stack0(:,:, 1:(end-1-options.cropvideo));
end

stack01 = stack0(:,:,1:stacklength/2);
stack01 = transformStack(stack01,tformLtobf);
stack0(:,:,1:stacklength/2) = stack01;
clear stack01
stack02 = stack0(:,:,(stacklength/2 + 1):end);
stack02 = transformStack(stack02,tformLtobf);
stack0(:,:,(stacklength/2 + 1):end) = stack02;
clear stack02

saveastiff(stack0, [stackFolder 'brightfield.tif']);
clear stack0

stack1 = combinedStacks(:,:, indexValues == 1);
stack1 = stack1(:,:, 1:(end-options.cropvideo));
stack11 = stack1(:,:,1:stacklength/2);


stack11 = transformStack(stack11,tformRtoL);
stack11 = transformStack(stack11,tformLtobf);
stack1(:,:,1:stacklength/2) =  stack11;
clear stack11
stack12 = stack1(:,:,(stacklength/2 + 1):end);
stack12 = transformStack(stack12,tformRtoL);
stack12 = transformStack(stack12,tformLtobf);
stack1(:,:,(stacklength/2 + 1):end) = stack12;
clear stack12
saveastiff(stack1, [stackFolder 'L.tif']);
clear stack1


stack2 = combinedStacks(:,:, indexValues == 2);
if size(stack2,3) > stack1len
    stack2 = stack2(:,:, 1:(end-1-options.cropvideo));
end
saveastiff(stack2, [stackFolder 'R.tif']);
clear stack2

% 
% stack1 = combinedStacks(:,:, indexValues == 1);
% stack2 = combinedStacks(:,:, indexValues == 2);
% if size(stack0,3) > size(stack1,3)
%     stack0 = stack0(:,:, 1:(end-1));
%     stack2 = stack2(:,:, 1:(end-1));
% end






% assignin('base','stack1',stack1); 
% disp(height(stack0));
% disp(height(stack1));
% disp(height(stack2));
% Save and close.
% Here we use the L, R, Brightfield filenames to avoid having to edit
% further macros down the line.

%transform the L and R channels so they match the bf channel

% if stacktoolarge == 1
%     stack11 = stack1(:,:,1:stacklength/2);
%     stack12 = stack1(:,:,(stacklength/2 + 1):end);
%     stack01 = stack0(:,:,1:stacklength/2);
%     stack02 = stack0(:,:,(stacklength/2 + 1):end);
% 
%     stack11 = transformStack(stack11,tformRtoL);
%     stack11 = transformStack(stack11,tformLtobf);
%     stack12 = transformStack(stack12,tformRtoL);
%     stack12 = transformStack(stack12,tformLtobf);
%     stack01 = transformStack(stack01,tformLtobf);
%     stack02 = transformStack(stack02,tformLtobf);
% 
%     stack1(:,:,1:stacklength/2) =  stack11;
%     stack1(:,:,(stacklength/2 + 1):end) = stack12;
%     stack0(:,:,1:stacklength/2) = stack01;
%     stack0(:,:,(stacklength/2 + 1):end) = stack02;
% 
% 
% else

% stack1 = transformStack(stack1,tformRtoL);
% stack1 = transformStack(stack1,tformLtobf);
% stack0 = transformStack(stack0,tformLtobf);
% 
% 
% 
% saveastiff(stack0, [stackFolder 'L.tif']);
% saveastiff(stack1, [stackFolder 'R.tif']);
% saveastiff(stack2, [stackFolder 'brightfield.tif']);

% end

end