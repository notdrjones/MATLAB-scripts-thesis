function multiextensionfigsaving(f,filename,extensions)
%MULTIEXTENSIONFIGSAVING Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(extensions)
    saveas(f,[filename '.' extensions{i}]);
end
end

