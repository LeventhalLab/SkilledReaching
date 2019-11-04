v=VideoReader('/Users/AlexandraBova/Desktop/Krista/710_20181126_01_R24_labeled.mpg');
[bodyparts,parts_loc,p]=read_DLC_csv('/Users/AlexandraBova/Desktop/Krista/710_20181126_01_R24DeepCut_resnet50_rightPP_CenterFeb9shuffle1_1030000.csv');
% 
% dlcCropParacms=[732 1316 44 1062];

% 1:1019
% 1:1080
% 44:1062

startTime = 6; % seconds
endTime = 11; % seconds

% parts_loc(1,:,2)=abs(parts_loc(1,:,2)-v.Height);
% parts_loc(2,:,2)=abs(parts_loc(1,:,2)-v.Height);

% lowPLeftPaw=find(p(1,:)<0.75);
% lowPRightPaw=find(p(2,:)<0.75);
% parts_loc(1,lowPLeftPaw,2)=NaN;
% parts_loc(1,lowPLeftPaw,1)=NaN;
% parts_loc(2,lowPRightPaw,1)=NaN;
% parts_loc(2,lowPRightPaw,2)=NaN;




% yminLeftPaw=min(parts_loc(1,startFrameNum:endFrameNum,2));
% yminRightPaw=min(parts_loc(2,startFrameNum:endFrameNum,2));
% ymin=min(yminLeftPaw,yminRightPaw);
% 
% ymaxLeftPaw=max(parts_loc(1,:,2));
% ymaxRightPaw=max(parts_loc(2,:,2));
% ymax=max(ymaxLeftPaw,ymaxRightPaw);

% v.CurrentTime=0;

time=NaN(length(parts_loc));
% startTime=v.CurrentTime;
% v.CurrentTime=0;
xTime=[];
frameCnt=ceil(v.CurrentTime*v.FrameRate);
movieCnt=0;
firstEnter=0;
while hasFrame(v)
    % Get information for plot
    frameCnt=frameCnt+1;
    frame = readFrame(v);
    time=v.CurrentTime;
%     frameCnt=ceil(time*v.FrameRate);
    
    if time >= startTime && time <= endTime
        if firstEnter==0
            startFrameNum=frameCnt;
            firstEnter=1;
        end
        movieCnt=movieCnt+1;
        
        yLeftPaw=parts_loc(1,frameCnt,2);
        yRightPaw=parts_loc(2,frameCnt,2);
        xTime(frameCnt)=time;
        
        % Make figure
        f=figure('Visible','off','Units','Normalized','OuterPOsition',[0,0.04,1,0.96]);
%         frame = frame(dlcCropParams(3):dlcCropParams(4),dlcCropParams(1):dlcCropParams(2),:);
        
        % The figure consists of a column of two subplots
        % The first subplot contains the video frame
        imPlot=subplot(2,2,[1 3]);
        imPlot.XAxisLocation='top';
        hold on
        imshow(frame,'InitialMagnification',200)
        xlabel('Side to Side Position','FontSize',40)
        ylabel('Up and Down Position','FontSize',40)
        
%         scatter(parts_loc(1,frameCnt,1),parts_loc(1,frameCnt+1,2),'filled','r');
%         scatter(parts_loc(2,frameCnt,1),parts_loc(2,frameCnt+1,2),'filled','b');

        % The second subplot contains the plot with a line indicating location
        subplot(2,2,2);
        hold on;
        plot(xTime,parts_loc(1,1:frameCnt,1),'LineWidth',2,'Color','b')
        plot(xTime,parts_loc(2,1:frameCnt,1),'LineWidth',2,'Color',[0.3010 0.7450 0.9330])
        line([time time],[0,v.Height],'LineWidth',2,'DisplayName','Current Time','Color','r')
        axis([startTime endTime 175 600]);
        title('Side to Side','FontSize',60);
        ylabel({'Side-Side Position (pixels)';''},'FontSize',40);
        ax=gca;
        ax.FontSize=30;
        
        subplot2=subplot(2,2,4);
        hold on;
        plot(xTime,parts_loc(1,1:frameCnt,2),'LineWidth',2,'DisplayName','Non-Preferred Paw','Color','b')
        plot(xTime,parts_loc(2,1:frameCnt,2),'LineWidth',2,'DisplayName','Preferred Paw','Color',[0.3010 0.7450 0.9330])
        line([time time],[0,v.Height],'LineWidth',2,'DisplayName','Current Time','Color','r')
        axis([startTime endTime 475 1060]);
        title('Up and Down','FontSize',60);
        xlabel({'Time (s)';''},'FontSize',40);
        ylabel({'Up-Down Position (pixels)';''},'FontSize',40);
        ax=gca;
        ax.FontSize=30;
        
        legend1 = legend(subplot2,'show');
set(legend1,...
    'Position',[0.183408943616332 0.0727482678983833 0.222294232015554 0.121247113163972]);
        
        M(movieCnt)=getframe(gcf);
        close all;
        endFrameNum=frameCnt;
    elseif time >= endTime
        
        break
    end
end

% figure('Visible','on');
% axes('Position',[0 0 1 1])
% % movie(M,2)
finalVid=VideoWriter('finalVid.avi');
open(finalVid);
writeVideo(finalVid,M);
close(finalVid);
