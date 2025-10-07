function [z_positions] = extractZpositions(filepath, varargin)
%METADATA_Z_EXTRACTION Extract position of piezo stage as it goes up and
%down. Using Micro-Manager. Particularly useful for calibration purposes.

defaultSaving = true;

p = inputParser;
addRequired(p, 'filepath', @(x) isstring(x) || ischar(x));
addOptional(p, 'savingFlag', defaultSaving, @islogical);

parse(p,filepath,varargin{:});

savingFlag = p.Results.savingFlag;

all_metadata = readlines(filepath); % This reads the full file

important_lines = strfind(all_metadata,"ZPositionUm");
important_lines_index = find(~cellfun(@isempty,important_lines));

n_steps = length(important_lines_index);
z_positions = zeros(n_steps,1); % initialise array where positions are stored

for i=1:n_steps
    current_line = all_metadata(important_lines_index(i));
    position_string = regexp(current_line,'\d*','match');
    position_string = strcat(position_string(1)+"."+position_string(2));

    z_positions(i) = str2double(position_string);
end

% FOR DEBUGGING - GENERALLY COMMENTED OUT
%plot(z_positions);
%scatter(1:n_steps, z_positions,10,turbo(n_steps),'filled');

if savingFlag
    fprintf("Saving... \n");
    save("z_positions.txt", 'z_positions', '-ascii');
end

end

