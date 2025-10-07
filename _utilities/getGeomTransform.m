function [tFormAffine] = getGeomTransform(points0, points1)

%gets an affine that will transform the channel that gave points1 so that
%it matches the channel that gave points0 

if nargin < 3 % Use default options
    options.validpoints = '5';

end
% 
% points0 = [1467	2014; 761	2896; 1520	4176; 1871	3367; 2657	2980];
% points1 = [1459	2010; 751	2888; 1505	4168; 1858	3361; 2646	2978];
% points2 = [1456	2043; 757	2913; 1502	4179; 1851	3381; 2628	3000];
tFormAffine = estgeotform2d(points1, points0, "affine");



end