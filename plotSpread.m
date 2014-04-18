function allDist=plotSpread(pawCenters,pawHulls,color)
    allDist = zeros(size(pawCenters,1),1);
    for i=1:size(pawCenters,1)
        [maxIndexes,maxDist] = maxSpread(pawCenters(i,:),pawHulls{i});
        allDist(i,1) = maxDist;
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