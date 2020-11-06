function dt_out = convertToDateTime(dateString,dateFormat)
% 
% convert dateStrings into datetime objects
%
% INPUTS
%   dateString - character array of dates (each row is a string containing
%       a date)
%   dateFormat - format string for converting a string to a datetime object
%
% OUTPUTS
%   dt_out - array of datetime objects

if isdatetime(dateString)
    dt_out = dateString;
    return
end
    
if isnan(dateString)
    dt_out = NaT(size(dateString,1),1);
    return;
end

if isempty(dateFormat)
    dt_out = datetime(dateString);
else
    dt_out = datetime(dateString,'inputformat',dateFormat);
end

% strings loaded in from .csv or excel tables often only account for the
% last 2 digits of the year
dt_out.Year(dt_out.Year < 100) = dt_out.Year(dt_out.Year < 100) + 2000;

end