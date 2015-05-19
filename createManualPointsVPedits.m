function [pellet_center_x, pellet_center_y,manual_paw_centers,mcp_hulls,mph_hulls,dph_hulls] = createManualPointsVPedits (filename,frameStart)

frameEnd =frameStart+40;
video = VideoReader(filename);

for i=frameStart:10:frameEnd;
    im = read(video,i);
    imshow(im);
    
    
    
% % Titus John, titusaj@umich.edu
% % Leventhal Lab, University of Michigan
% % ---release: beta --
% 
% %Select the points of the center video reach, return the center paw coordinate,
% % 1st digit coordinate, 2nd digit coordinate, 3rd digit coordinate, 4th digit coordinate
% 
% 
% function [ pellet_center_x, pellet_center_y,manual_paw_centers,mcp_hulls,mph_hulls,dph_hulls] = createManualPointsVPedits (filename,frameStart)
% %Arrays to hold the paw center and middle digit and tip information
% manual_paw_center = [];
% mcp_hulls = [];
% mph_hulls = [];
% dph_hulls = [];
% 
% pelletLocRec = 0; %Variable to show the pellet location has been recorded
% 
% video = VideoReader(filename);
% 
% %Assign the start and stop frames that will be processed
% %frameStart = 300;
% frameEnd =frameStart+40;
% 
% 
% %Counter j for hold incrementations of pawCenters/Hulls
% frameCount=1;
% 
% %Loop through the frames of the video and assign the points
% for i=frameStart:10:frameEnd
%     
%     %% Variable to hold the coordinates for the digits going through all the frames
%     c_x = []; %center x coordinates of paw
%     c_y = []; %center y coordinates of paw
%     
%     %% Metacarpal Knuckles
%     mcpx = [];
%     mcpy = [];
%     
%     %% Medial Phalanges knuckles
%     mphx = [];
%     mphy = [];
%     
%     %% Distal Phalanges knuckles
%     dphx = [];
%     dphy = [];
%     
%     %% Read each frame into
%     
%     im = read(video,i);
%     
%     
%     
%     if frameCount == 1 && pelletLocRec == 0
%         imshow(im)
%         % Construct a questdlg
%         options.Interpreter = 'tex';
%         options.Default = 'Okay';
%         pelletCheckButton = MFquestdlg([ 0.6 , 0.6 ] ,'Select the center of the pellet. If not visible, click below. If you make a mistake, press Backspace or Delete to re-do the marker. When finished, press Enter', ...
%             'PelletCheck', ...
%             'Okay','Not Visible',options);
%         
%         
%         
%         % Handle response
%         switch pelletCheckButton
%             case 'Okay'
%                 nextTrial = 1;
%                 pelletLocRec =1;             
%             case 'Not Visible'
%                 nextTrial = 0;
%         end
%             
%         [pellet_center_x,pellet_center_y] = getpts
%         pellet_fig = insertShape(im, 'FilledCircle', [pellet_center_x, pellet_center_y 8], 'Color', 'Blue');
%         imshow(pellet_fig)
%     end
%     
%     % Select the center of the paw
%     % Construct a questdlg
%     options.Interpreter = 'tex';
%     options.Default = 'Okay';
%     pawCheckButton = MFquestdlg([ 0.6 , 0.6 ] ,'Select the center of the paw', ...
%         'PawCheck', ...
%         'Okay','Not Visible',options);
%     
%     
%     
%     % Handle response
%     switch pawCheckButton
%         case 'Okay'
%             nextTrial = 1;
%             pelletLocRec =1;
%             close;
%         case 'Not Visible'
%             nextTrial = 0;
%             close;
%     end
%     
%     [center_x,center_y,all_x,all_y] = selectPointsCenterVP(im)
%     
%     c_x = center_x;
%     c_y = center_y;
%     
%     mcpx = all_x(:,1);
%     mphx = all_x(:,2);
%     dphx = all_x(:,3);
%     
%     mcpy = all_y(:,1);
%     mphy = all_y(:,2);
%     dphy = all_y(:,3);
%     
%     
%     
%     manual_paw_centers(frameCount,:) = [c_x, c_y];
%     mcp_hulls{frameCount} = cat(2,mcpx, mcpy);
%     mph_hulls{frameCount} = cat(2,mphx, mphy);
%     dph_hulls{frameCount} = cat(2,dphx, dphy);
%     
%     frameCount = frameCount+1;
%     
% end
% 
% 
% 
% end
% 
% 
% 
% 
