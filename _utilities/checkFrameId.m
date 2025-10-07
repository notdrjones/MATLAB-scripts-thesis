function index=checkFrameId(filepath)
    all_metadata = readlines(filepath); % This reads the full file
    
    important_lines = strfind(all_metadata,"FrameKey");
    important_lines_index = find(~cellfun(@isempty,important_lines));

    important_lines2 = all_metadata(important_lines_index);
    
    index = zeros(numel(important_lines2),1);

    for i=1:numel(important_lines2)
        current_line = important_lines2(i);
        position_string = regexp(current_line,'\d*','match');

        index(i) = str2double(position_string(2));
    end
end