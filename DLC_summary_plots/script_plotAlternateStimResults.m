% script_plotAlternateStimResults

alternatingStimFolder = '/Volumes/LL EXHD #2/alternating stim analysis';
alternateKinematicsName = 'alternating_stim_kinematics_summary.mat';
alternateKinematicsName = fullfile(alternatingStimFolder,alternateKinematicsName);
load(alternateKinematicsName);

numSessions = length(alternateKinematics);

full_traj_z_lim = [-5 50];
reachEnd_zlim = [-15 30];

x_lim = [-30 10];
y_lim = [-20 10];

figProps.m = 5;
figProps.n = 5;

figProps.panelWidth = ones(figProps.n,1) * 10;
figProps.panelHeight = ones(figProps.m,1) * 4;

figProps.colSpacing = ones(figProps.n-1,1) * 1;
figProps.rowSpacing = ones(figProps.m-1,1) * 1.5;

figProps.leftMargin = 2.54;
figProps.topMargin = 5;

figProps.width = sum(figProps.colSpacing) + sum(figProps.panelWidth) + figProps.leftMargin + 2.54;
figProps.height = sum(figProps.rowSpacing) + sum(figProps.panelHeight) + figProps.topMargin + 2.54;


for iSession = 1 : numSessions
    
    curKinematics = alternateKinematics(iSession);
    if isempty(curKinematics.ratID)
        continue;
    end
    sessionDateString = datestr(curKinematics.sessionDate,'yyyymmdd');
    pawPref = curKinematics.thisRatInfo.pawPref;
    
    ratID = curKinematics.ratID;
    
    pdfName = sprintf('R%04d_%s_alternating_stim.pdf',ratID,sessionDateString);
    figName = sprintf('R%04d_%s_alternating_stim.fig',ratID,sessionDateString);
    pdfName = fullfile(alternatingStimFolder, pdfName);
    figName = fullfile(alternatingStimFolder, figName);
%     if exist(pdfName,'file')
%         continue;
%     end

    trials_per_block = size(curKinematics.on_endAperture,2);
    
    mean_slot_z_wrt_pellet = nanmean(curKinematics.slot_z_wrt_pellet);
    
    [h_fig,h_axes] = createFigPanels5(figProps);
    
    % final point z vs trial number
    axes(h_axes(1,1));
    scatter(curKinematics.trialNumbers,curKinematics.pd_endPts(:,3),'markeredgecolor','k','markerfacecolor','k',...
        'markerfacealpha',0.5,'markeredgealpha',0.5)
    hold on
    scatter(curKinematics.trialNumbers,curKinematics.dig2_endPts(:,3),'markeredgecolor','k','markerfacecolor','k');
    line([curKinematics.trialNumbers(1),curKinematics.trialNumbers(end)],...
         [mean_slot_z_wrt_pellet,mean_slot_z_wrt_pellet],'color','k');
    title('paw/digit end points')
    xlabel('trial number')
    ylabel('z');
    set(gca,'ylim',reachEnd_zlim);
    
    % final mean z-coordinate on vs off
    axes(h_axes(1,2));
    scatter(1:trials_per_block,curKinematics.mean_off_pd_endPts(:,3),'markeredgecolor','r','markerfacecolor','r',...
        'markerfacealpha',0.5,'markeredgealpha',0.5)
    hold on
    scatter(trials_per_block*2+1:3*trials_per_block,curKinematics.mean_off_pd_endPts(:,3),'markeredgecolor','r','markerfacecolor','r',...
        'markerfacealpha',0.5,'markeredgealpha',0.5)
    scatter(trials_per_block+1:2*trials_per_block,curKinematics.mean_on_pd_endPts(:,3),'b','markeredgecolor','b','markerfacecolor','b',...
        'markerfacealpha',0.5,'markeredgealpha',0.5)
    scatter(trials_per_block*3+1:4*trials_per_block,curKinematics.mean_on_pd_endPts(:,3),'b','markeredgecolor','b','markerfacecolor','b',...
        'markerfacealpha',0.5,'markeredgealpha',0.5)
    
    scatter(1:trials_per_block,curKinematics.mean_off_dig2_endPts(:,3),'markeredgecolor','r','markerfacecolor','r')
    scatter(trials_per_block*2+1:3*trials_per_block,curKinematics.mean_off_dig2_endPts(:,3),'markeredgecolor','r','markerfacecolor','r')
    scatter(trials_per_block+1:2*trials_per_block,curKinematics.mean_on_dig2_endPts(:,3),'markeredgecolor','b','markerfacecolor','b')
    scatter(trials_per_block*3+1:4*trials_per_block,curKinematics.mean_on_dig2_endPts(:,3),'markeredgecolor','b','markerfacecolor','b')
    
    line([1,4*trials_per_block],...
         [mean_slot_z_wrt_pellet,mean_slot_z_wrt_pellet]);
    title('mean paw/digit end points')
    xlabel('trial number')
    set(gca,'ylim',reachEnd_zlim);
    
    % final mean paw endpoint on vs off
    axes(h_axes(1,3));
    switch pawPref
        case 'left'
            x_off = -curKinematics.mean_off_pd_endPts(:,1);
            x_on = -curKinematics.mean_on_pd_endPts(:,1);
        case 'right'
            x_off = curKinematics.mean_off_pd_endPts(:,1);
            x_on = curKinematics.mean_on_pd_endPts(:,1);
    end
    scatter3(x_off,curKinematics.mean_off_pd_endPts(:,3),curKinematics.mean_off_pd_endPts(:,2),'markeredgecolor','r','markerfacecolor','r')
    hold on
    scatter3(x_on,curKinematics.mean_on_pd_endPts(:,3),curKinematics.mean_on_pd_endPts(:,2),'markeredgecolor','b','markerfacecolor','b')
    
    scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
    set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
        'view',[-70,30])
    xlabel('x');ylabel('z');zlabel('y');
    title('pd endpoints,r=off,b=on')
    
    % final mean digit2 endpoint on vs off
    axes(h_axes(1,4));
    switch pawPref
        case 'left'
            x_off = -curKinematics.mean_off_dig2_endPts(:,1);
            x_on = -curKinematics.mean_on_dig2_endPts(:,1);
        case 'right'
            x_off = curKinematics.mean_off_dig2_endPts(:,1);
            x_on = curKinematics.mean_on_dig2_endPts(:,1);
    end
    scatter3(x_off,curKinematics.mean_off_dig2_endPts(:,3),curKinematics.mean_off_dig2_endPts(:,2),'markeredgecolor','r','markerfacecolor','r')
    hold on
    scatter3(x_on,curKinematics.mean_on_dig2_endPts(:,3),curKinematics.mean_on_dig2_endPts(:,2),'markeredgecolor','b','markerfacecolor','b')
    
    scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
    set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
        'view',[-70,30])
    xlabel('x');ylabel('z');zlabel('y');
    title('digit 2 endpoints,r=off,b=on')
    
    % final aperture all trials
    axes(h_axes(2,1));
    scatter(curKinematics.trialNumbers,curKinematics.endAperture)
    xlabel('trial number')
    ylabel('aperture (mm)');
    set(gca,'ylim',[5,25])
    
    % final aperture on vs off
    axes(h_axes(2,2));
    scatter(1:trials_per_block,curKinematics.mean_off_endAperture,'markeredgecolor','r','markerfacecolor','r')
    hold on
    scatter(trials_per_block*2+1:3*trials_per_block,curKinematics.mean_off_endAperture,'markeredgecolor','r','markerfacecolor','r')
    scatter(trials_per_block+1:2*trials_per_block,curKinematics.mean_on_endAperture,'markeredgecolor','b','markerfacecolor','b')
    scatter(trials_per_block*3+1:4*trials_per_block,curKinematics.mean_on_endAperture,'markeredgecolor','b','markerfacecolor','b')

    title('mean aperture')
    xlabel('trial number')
    set(gca,'ylim',[5,25])
    
    % final orientation all trials
    axes(h_axes(3,1));
    scatter(curKinematics.trialNumbers,curKinematics.endOrientation)
    xlabel('trial number')
    ylabel('orientation (rad)');
    set(gca,'ylim',[0,pi])
    
    % final orientation on vs off
    axes(h_axes(3,2));
    scatter(1:trials_per_block,curKinematics.mean_off_endOrientation,'markeredgecolor','r','markerfacecolor','r')
    hold on
    scatter(trials_per_block*2+1:3*trials_per_block,curKinematics.mean_off_endOrientation,'markeredgecolor','r','markerfacecolor','r')
    scatter(trials_per_block+1:2*trials_per_block,curKinematics.mean_on_endOrientation,'markeredgecolor','b','markerfacecolor','b')
    scatter(trials_per_block*3+1:4*trials_per_block,curKinematics.mean_on_endOrientation,'markeredgecolor','b','markerfacecolor','b')
    set(gca,'ylim',[0,pi])
    
    % max v, all trials
    axes(h_axes(4,1));
    scatter(curKinematics.trialNumbers,curKinematics.max_pd_v)
    xlabel('trial number')
    ylabel('max paw v (mm/s)');
    set(gca,'ylim',[0 1100]);
    
    % max v on vs off
    axes(h_axes(4,2));
    scatter(1:trials_per_block,curKinematics.mean_off_max_pd_v,'markeredgecolor','r','markerfacecolor','r')
    hold on
    scatter(trials_per_block*2+1:3*trials_per_block,curKinematics.mean_off_max_pd_v,'markeredgecolor','r','markerfacecolor','r')
    scatter(trials_per_block+1:2*trials_per_block,curKinematics.mean_on_max_pd_v,'markeredgecolor','b','markerfacecolor','b')
    scatter(trials_per_block*3+1:4*trials_per_block,curKinematics.mean_on_max_pd_v,'markeredgecolor','b','markerfacecolor','b')
    set(gca,'ylim',[0 1100]);
    
    h_figAxis = createFigAxes(h_fig);
    
    laserOnString = alternateSessions(iSession,:).laserOnTiming;
    laserOffString = alternateSessions(iSession,:).laserOffTiming;
    textString{1} = sprintf('5 off(red), 5 on (blue); R%04d, %s', ...
        curKinematics.ratID, sessionDateString);
    textString{2} = sprintf('laser on at %s, laser off at %s', ...
        laserOnString, laserOffString);
    
    axes(h_figAxis);
    text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');
    
    savefig(h_fig,figName);
    print(h_fig,pdfName,'-dpdf');
    close(h_fig);
end