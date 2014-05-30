% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% deprecated
function allDist=plotPawSpread(pawCenters,pawHulls,color)
    allDist = zeros(size(pawCenters,1),1);
    for i=1:size(pawCenters,1)
        [maxIndexes,maxDist] = maxSpread(pawCenters(i,:),pawHulls{i});
        if(isempty(maxDist))
            allDist(i,1) = NaN;
        else
            allDist(i,1) = maxDist;
        end
    end
    hold on;

    [rows,~,~] = find(~isnan(allDist));
    minIndex = min(rows);
    maxIndex = max(rows);
    allDistCropped = allDist(minIndex:maxIndex,1);
    %allDistCropped = inpaint_nans(allDistCropped);
    allDistCropped = smooth(allDistCropped,10);
    allDist(minIndex:maxIndex,:) = allDistCropped;
    
    % scale, 1px = .1368mm
    allDist = allDist.*.1368;
    
    %align peaks
    alignFrame = 200;
    [~,maxIndex] = max(allDist);
    
    plot(1,allDist(1),'*','Color',color);
    allDist = [zeros(alignFrame-maxIndex,1);allDist];

    plot(1:size(allDist,1),allDist,'Color',color);
end