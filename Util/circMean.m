function y_mean = circMean(y,minVal,maxVal,varargin)

meanDim = 1;
if nargin == 4
    meanDim = varargin{1};
end
y_shifted = y - minVal;
y_scaled = (y_shifted / (maxVal-minVal)) * 2 * pi;

% t = exp(1i*y_scaled);
t = wrapTo2Pi(y_scaled);

y_mean = mean(t,meanDim);
y_mean = y_mean * (maxVal-minVal) / (2*pi);
y_mean = y_mean + minVal;