function [r,x,y] = Harris (f, sigma, k, thresh, radius, display)
% HARRIS computes the Harris Corner Detection.
% 
% Arguments:
%           f     - is an image.
%
%           sigma - is a standard deviation for Gaussian to smooth image to
%                   eliminate noise.
%                   By default, sigma = 0.5.
%
%           k     - is a sensitivity parameter.The value of ? has to be
%                   determined empirically, and in the literature values in 
%                   the range 0.04 - 0.15 have been reported as feasible.
%                   By default, k = 0.04.
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
%           r     - map cornerness measure of each pixel.
%           x     - row coordinates of the corners.
%           y     - column coordinates of the corners.
%
% Usage:
%           g=harris(f);
%           g=harris(f,1);
%           g=harris(f,1,0.15,1);
%           g=harris(f,1,0.15,1,1);
%           g=harris(f,1,0.15,1,1,1);
%
% References:
% @inproceedings{Harris88,
% 	author = {Harris, C.  and Stephens, M. },
% 	citeulike-article-id = {2717614},
% 	journal = {In Proceedings of the Alvey Vision Conference},
% 	keywords = {corner-detection, image-processing},
% 	month = {August},
% 	pages = {189--192},
% 	posted-at = {2008-04-25 13:30:10},
% 	priority = {2},
% 	title = {A combined corner and edge detector},
% 	year = {1988}
% }
%
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 03/06/2008
%----------------------------------------------------------

% Checks the arguments
args = nargin;
error(nargchk(1,6,args));
% Defaults values
switch args
    case 1
        sigma = 0.5;
        k = 0.04;
    case 2
        k = 0.04;
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
tr = a + b;
det = (a .* b) - (c .^ 2);


%Result
r = det - (k * (tr .^ 2));
%[min(r(:)) max(r(:))]
%r = (A .* B) - (C .^ 2) - k * (A + B) .^ 2;

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
    case 5
        display=1;        
end

% Implements a sze-by-sze maximum filter
% Size of dilation mask.
sze = 2*radius+1;
% Grey-scale dilate.
mx = ordfilt2(r,sze^2,ones(sze)); 
%imshow(mx)

% Make mask to exclude points within radius of the image boundary. 
bordermask = zeros(size(r));
bordermask(radius+1:end-radius, radius+1:end-radius) = 1;

% Find maxima, threshold, and apply bordermask.
rmx = (r==mx) & (r>thresh) & bordermask;

% Find row,col coordinates.
[x,y] = find(rmx);

% Shows the corners overlaped to the original image.
if (display)
    %figure, 
    imshow(f,[]), hold on
    plot(y,x,'g+'), title(strcat('Harris corner detector - k = ',num2str(k)));
    hold off;
end