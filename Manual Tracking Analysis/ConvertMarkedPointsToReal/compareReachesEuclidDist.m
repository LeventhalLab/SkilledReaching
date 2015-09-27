function [averagedEuclidDistSuccess,averagedEuclidDistFail,averagedEuclidDistSuccessStd,averagedEuclidDistFailStd] = compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatId,day,fignum)
    for i = 1:5
        currentFrameSuccessMean = euclidianDistDiffMeanSuccess(:,i)
        currentFrameFailMean = euclidianDistDiffMeanFail(:,i)
       
        currentFrameSuccessStd = euclidianDistDiffStdSuccess(:,i)
        currentFrameFailStd = euclidianDistDiffStdFail(:,i)
        
         
         
        averagedEuclidDistFail(i) = currentFrameFailMean(1) + currentFrameFailMean(2) + currentFrameFailMean(3);
        averagedEuclidDistSuccess(i) = currentFrameSuccessMean(1) + currentFrameSuccessMean(2) + currentFrameSuccessMean(3);
        
        averagedEuclidDistSuccessStd(i) = currentFrameSuccessStd(1) + currentFrameSuccessStd(2) + currentFrameSuccessStd(3);
        averagedEuclidDistFailStd(i) = currentFrameFailStd(1) + currentFrameFailStd(2) + currentFrameFailStd(3);
        
        
    end
    
    figure(fignum)
    hold on
    
    frames = 1:5;
    
    errorbar(frames,averagedEuclidDistFail,averagedEuclidDistFailStd,'b')
    errorbar(frames,averagedEuclidDistSuccess,averagedEuclidDistSuccessStd,'r')
    legend('Failure', 'Success')
    xlabel('Frames')
    ylabel('mm')
    titleCat = strcat('Averaged Euclidian Distance Difference Between all reaches to avearage reach trajectory in single session' , ' Rat: ',RatId, ' Day: ', num2str(day)) ;
    title(titleCat) 

    
end