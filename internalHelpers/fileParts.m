function [pathstr, name, num, ext] = fileParts(fileString)
%%FILEPARTS gives back file path, name, number and extension
% Split up like normal:
    [pathstr, name, ext] = fileparts(fileString);
    %start at the end of the filename
    Nend = length(name);      
    N = Nend;
    s = str2num(name(N));
    if isempty(s) error(['Unable to parse file index from filename: ' fileString]); end

    % go back a digit until we run into a non-number
    while ~isempty(s) & N>3
        N=N-1;
        s = str2num(name(N));
    end

    % return the file index
    num = name(N+1:Nend);
    % return the filename
    name = name(1:N);
end