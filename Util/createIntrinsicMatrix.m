function K = createIntrinsicMatrix(varargin)
%
% function creates intrinsic matrix from our standard camera (Basler ace, 8
% mm lens) configuration, or focal length, pixel size, and principal point
% can be input to the function

f = 8;    % focal length in mm
pixSize = 5.5e-3;    % pixel size in mm
princ_point = [1020,512];

for iarg = 1 : 2 : nargin
    switch lower(varargin{iarg})
        case 'f',
            f = varargin{iarg + 1};
        case 'pixsize',
            pixSize = varargin{iarg + 1};
        case 'princ_point',
            princ_point = varargin{iarg + 1};
    end
end

K = [f/pixSize  000        princ_point(1)
     000        f/pixSize  princ_point(2)
     000        000        01];