function sessionDates = sessionDatesFromDirectories(sessionDirectories)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sessionDates = NaT(1, length(sessionDirectories));

for i_folder = 1 : length(sessionDirectories)
    
    C = textscan(sessionDirectories{i_folder}, 'R%04d_%8c');
    
    date_string = C{2};
    
    sessionDates(i_folder) = datetime(date_string, 'InputFormat', 'yyyyMMdd');

end

