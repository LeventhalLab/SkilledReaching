% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Generates a unique color between shades of blue and yellow based on the ratio (iCurrent/iTotal).
function color=getColor(iCurrent,iTotal)
    hue = (100/360):((200/360)/(iTotal-1)):(300/360);
    saturation = .4:(.50/(iTotal-1)):.9;
    value = fliplr(saturation);
    color = [hue(iCurrent),saturation(iCurrent),value(iCurrent)];
end