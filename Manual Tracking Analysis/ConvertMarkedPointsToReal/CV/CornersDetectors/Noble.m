function [r,x,y] = Noble (f, sigma, thresh, radius, display)
% Noble computes a variation of Harris Corner Detection.
% 
% Arguments:
%           f     - is an image.
%
%           sigma - is a standard deviation for Gaussian to smooth image to
%                   eliminate noise.
%                   By default, sigma = 0.5.
%
%           radius - 
%                    By default, radius = 0.
%
%           thresh - is a threshold. 
%                    By default, thresh = graythresh(R);
%
%           display - shows the corners overlaped on the original image.
%                     By default, display = 0.
%
% Output:
%           r     - cornered filter image.
%           x     - row coordinates of the corners.
%           y     - column coordinates of the corners.
%
% Usage:
%           g=noble(f);
%           g=noble(f,1);
%           g=noble(f,1,0.15,1);
%           g=noble(f,1,0.15,1,1);
%           g=noble(f,1,0.15,1,1,1);
%
% References:
%
%@article{DBLP:journals/ivc/Noble88,
%  author    = {J. Alison Noble},
%  title     = {Finding corners},
%  journal   = {Image Vision Comput.},
%  volume    = {6},
%  number    = {2},
%  year      = {1988},
%  pages     = {121-128},
%  ee        = {http://dx.doi.org/10.1016/0262-8856(88)90007-8},
%  bibsource = {DBLP, http://dblp.uni-trier.de}
%}
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 03/06/2008
%----------------------------------------------------------

% Checks the arguments
args = nargin;
error(nargchk(1,5,args));
% Defaults values
if (args == 1)
    sigma = 0.5;
end

% Image is double type ?
if ~isa(f,'double')
    f = double(f);
end


% Gradients - partial derivatives
% h = (fspecial('prewitt')*(-1))';
h = [-1 0 1;-1 0 1;-1 0 1];
x = conv2(f, h, 'same');
y = conv2(f, h', 'same');

% Smooth image with a Gaussian to eliminate noise.
% Gaussian window
% w = exp -(u^2+v^2)/sigma^2;
w = fspecial('gaussian', max(1,fix(6*sigma)), sigma);

% Corner detector E = Ax^2 + 2Cxy + By^2
a = conv2(x .^ 2, w,'same');
b = conv2(y .^ 2, w,'same');
c = conv2((x .* y), w,'same');


%Corner/edge response function
% R = Det(M) - k Tr^2
% where 
%       M      = [A C; C B]
%       Tr(M)  = A + B
%       Det(M) = AB - C^2
tr = a + b + eps;
det = (a .* b) - (c .^ 2);

%Result
r = det ./ tr;


%Find local maxima

%[r,c] = nonmaxsuppts(cim, radius, thresh, im);		
% Extract local maxima by performing a grey scale morphological
% dilation and then finding points in the corner strength image that
% match the dilated image and are also greater than the threshold.



% Default values
switch args
    case {1,2,3}
        radius=1;
        thresh=graythresh(r);
        display=1;
    case 4
        thresh=graythresh(r);        
        display=1;
end

% Implements a sze-by-sze maximum filter
% Size of dilation mask.
sze = 2*radius+1;
% Grey-scale dilate.
mx = ordfilt2(r,sze^2,ones(sze)); 

% Make mask to exclude points within radius of the image boundary. 
bordermask = zeros(size(r));
bordermask(radius+1:end-radius, radius+1:end-radius) = 1;

% Find maxima, threshold, and apply bordermask.
rmx = (r==mx) & (r>thresh) & bordermask;

% Find row,col coordinates.
[x,y] = find(rmx);

% Shows the corners overlaped to the original image.
if (display)
    figure, imshow(f,[]), hold on
    plot(y,x,'g+'), title('Noble corner detector');
end