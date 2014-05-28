% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Easily converts a 0-255 RGB input to HSV
function combined=ez2hsv(r,g,b)
    [h,s,v]=rgb2hsv([r/255 g/255 b/255]);
    combined=[h,s,v];
end