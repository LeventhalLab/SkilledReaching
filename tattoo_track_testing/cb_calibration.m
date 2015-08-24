function cameraParams = cb_calibration(varargin)

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/calibration images';

for iarg = 1 : 2 : nargin
    switch lower(varargin{iarg})
        case 'cb_path',
            cb_path = varargin{iarg + 1};
    end
end

cb_files = dir('rubiks*');

fname = fullfile(cb_path, cb_files(1).name);
im_test = imread(fname);
im = uint8(zeros(size(im_test,1),size(im_test,2),size(im_test,3),length(cb_files)));
im(:,:,:,1) = im_test;
for ii = 1 : length(cb_files)
    fname = fullfile(cb_path, cb_files(ii).name);
    
    im(:,:,:,ii) = imread(fname);
end

%%
[impts,bs] = detectCheckerboardPoints(im);
worldPoints = generateCheckerboardPoints(bs,20);
%%
[cameraParams,imagesUsed,estimationErrors] = estimateCameraParameters(impts,worldPoints);