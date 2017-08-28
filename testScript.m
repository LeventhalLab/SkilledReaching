%%

start2Dpts = cell(1,2);
end2Dpts = cell(1,2);

numFrames_to_interpolate = abs(currentFrame - testFrame);
startLeft = zeros(1,2);
startRight = zeros(1,2);
startTop = zeros(1,2);
startBot = zeros(1,2);

endLeft = zeros(1,2);
endRight = zeros(1,2);
endTop = zeros(1,2);
endBot = zeros(1,2);
for iView = 1 : 2
    start2Dpts{iView} = new_2dpoints{iView,currentFrame - frameStep};
    end2Dpts{iView} = new_2dpoints{iView,testFrame};
    
    startLeft(iView) = min(start2Dpts{iView}(:,1));
    startRight(iView) = max(start2Dpts{iView}(:,1));
    startTop(iView) = min(start2Dpts{iView}(:,2));
    startBot(iView) = max(start2Dpts{iView}(:,2));
    
    endLeft(iView) = min(end2Dpts{iView}(:,1));
    endRight(iView) = max(end2Dpts{iView}(:,1));
    endTop(iView) = min(end2Dpts{iView}(:,2));
    endBot(iView) = max(end2Dpts{iView}(:,2));
end

%%
for iFrame = currentFrame : frameStep : testFrame - frameStep
    
    for iView = 1 : 2
        % is there already a mask in this view? If so, don't change it for
        % now
        if ~any(new_2dpoints{iView,iFrame})
            
            newLeft = round(startLeft(iView) + (endLeft(iView) - startLeft(iView)) / (numFrames_to_interpolate + 1));
            newRight = round(startRight(iView) + (endRight(iView) - startRight(iView)) / (numFrames_to_interpolate + 1));
            newTop = round(startTop(iView) + (endTop(iView) - startTop(iView)) / (numFrames_to_interpolate + 1));
            newBot = round(startBot(iView) + (endBot(iView) - startBot(iView)) / (numFrames_to_interpolate + 1));
            
            new_2dpoints{iView,iFrame} = [newLeft,newTop;
                                          newRight,newTop;
                                          newRight,newBot;
                                          newLeft,newBot];
        end
    end

end