function y_mean = NaNcircMean(y,minVal,maxVal,varargin)
%
% INPUTS:
%   y - array containing values to average
%   minVal - minimum possible value of y
%   maxVal - maximum possible value of y
%
% VARARGS:
%   mean_dim (optional 4th input argument) - array dimension along which to
%       take the average
%
% OUTPUTS:
%   y_mean - array containing the circular mean of y along either the first
%       non-singleton dimension or the dimension specified by mean_dim

if numel(y) == 1
    y_mean = y;
    return
end

if nargin == 4
    meanDim = varargin{1};
else
    % find the first non-singleton dimension
    for i_dim = 1 : ndims(y)
        if size(y,i_dim) > 1
            meanDim = i_dim;
            break;
        end
    end
end

y_shifted = y - minVal;
y_scaled = (y_shifted / (maxVal-minVal)) * 2 * pi;

% t = exp(1i*y_scaled);
t = wrapTo2Pi(y_scaled);

y_mean = nanmean(t,meanDim);
y_mean = y_mean * (maxVal-minVal) / (2*pi);
y_mean = y_mean + minVal;