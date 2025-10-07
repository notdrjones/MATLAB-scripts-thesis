function [vectorlist] = getVectorsSmoothed(currBac, options)
%this is set up so that poles are assigned as 1 and 2 at the beginning of the script
% such that pole 1 is always the pole that starts higher up (i.e. lower
%value of y)
if nargin<3

    options.cellspeedsmoothing = 5;

end

%convert some options to variables corrected to pixels rather than um to
%make things easier later
n = options.cellspeedsmoothing;
vectorlist = zeros(height(currBac),2);

%establish flipflag with the same convention as the non-smoothed data
if currBac(1+n,4) < 0
    flipflag = 1;
else 
    flipflag = 0;
end

for T=(1+n):(height(currBac)-n)

    %get actual frame rather than index
    t = currBac(T,1);
    

    x1 = currBac(T-n,2);
    x2 = currBac(T+n,2);
    y1 = currBac(T-n,3);
    y2 = currBac(T+n,3);

    xcomp = x2 - x1;
    ycomp = y2 - y1;
    

    vectorlist(T,:) = [xcomp ycomp];


end

for i = 1:n
    vectorlist(i,:) = vectorlist(n+1,:);
    vectorlist(height(currBac)+1-i, :) = vectorlist(height(currBac)-n,:);
end
end
