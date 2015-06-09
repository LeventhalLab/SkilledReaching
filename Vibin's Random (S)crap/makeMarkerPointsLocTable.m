m = 1;
Table = cell(TotMarkNum,5);
for i = 1:length(Frames);
    for j = 1:length(FrameRegionInFocus);
        for k = 1:length(MarkerPoints);
            Table{m,1} = str2double(Frames(i));
            Table{m,2} = FrameRegionInFocus(j);
            Table{m,3} = MarkerPoints(k);
            m = m+1;
        end
    end
end
