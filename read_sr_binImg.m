function img = read_sr_BinImg( fname, frame_num, varargin )
%
% INPUTS:
%   fname - name of a binary image file generated in the skilled reaching
%           task
%   frame_num - the frame number to extract
%
% VARARGS:
%   
% OUTPUTS:
%   img - the image in raw uint8 values

w = 2040;
h = 1024;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg + 1});
        
    end
end

fid = fopen(fname,'r');

% there is a 4-byte header before each frame
fseek(fid,4*frame_num + h*(w)*(frame_num-1),'bof');
img = uint8(fread(fid, [w,h], 'uint8', 0, 'l'))';

fclose(fid);

end