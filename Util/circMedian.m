function y_median = circMedian(y,minVal,maxVal,varargin)

medianDim = 1;
if nargin == 4
    medianDim = varargin{1};
end
y_shifted = y - minVal;
y_scaled = (y_shifted / (maxVal-minVal)) * 2 * pi;

% t = exp(1i*y_scaled);
t = wrapTo2Pi(y_scaled);

y_median = median(t,medianDim);
y_median = y_median * (maxVal-minVal) / (2*pi);
y_median = y_median + minVal;