function matchIdx = matchCheckerboardPoints(directChecks, mirrorChecks, mirrorOrientation)




L_direct = bwlabel(directChecks);
L_mirror = bwlabel(mirrorChecks);

for i_directCheck = 1 : max(L_direct(:))
    curDirectBlob = (L_direct == i_directCheck);
    s_direct = regionprops(curDirectBlob,'centroid','extrema');
    
    for i_mirrorCheck = 1 : max(L_mirror(:))
        curMirrorBlob = (curDirectBlob == i_mirrorCheck);
        s_mirror = regionprops(curMirrorBlob,'centroid','extrema');
        
        
        switch mirrorOrientation

            case 'top'

            case {'left','right'}

        end
    
    
end

s_mirror = regionprops(L_mirror,'centroid','extrema');