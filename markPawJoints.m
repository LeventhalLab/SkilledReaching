function [ Table ] = markPawJoints( video,iFrame,iFrameRegion,iMarker,CurrentMarker )
% Within the context of GUIcreateManualPoints, markPawJoints is used to
% manually mark the joints of the rats paw. X,Y coordinates are the output.
for iFrame = 1:2 %length(Frames);
    % the function displays the frame image on the left side of the screen...
    im = read(video,str2double(Frames{iFrame}));
    figure;
    imshow(im);
    set(gcf,'Position',[34 141 1530 815]);
    % creates the Frame Data substructure (with further substructures Left,
    % Center, and Right; corresponds to regions of frame under analysis)...
%     FrameData = struct('Left',[],'Center',[],'Right',[]);
    for iFrameRegion = 1:3;
%         n = 1; 
%         o = 1; 
%         p = 1;
        % displays in the GUI which region of the frame the user should be
        % marking...
        set(handles.frame_reg_in_focus_txtbox,'String',FrameRegionInFocus{iFrameRegion})       
        % proceeds through all the relevant markers...
        for iMarker = 1:3 %length(MarkerPoints);
            % first displaying the marker's name and anatomical name in the
            % GUI...
            set(handles.marker_indicator_txtbox,'String',MarkerPoints{iMarker});
            set(handles.marker_indicator2_txtbox,'String',MarkerPoints2{iMarker});
            
% Figure out how to change highlight/font color of completed markers in listbox            
%             for s = 1:CurrentMarker
%                 set(handles.redo_marker_listbox,'String','Color','red')
%             end

            % then recording where the user clicks on the frame image to
            % indicate the marker (detailed instructions in GUI)...
            [x,y] = getpts;
            % for the pellet center marker...
            if iMarker == 1;
                % if the user does not click and presses Enter (indicating
                % the marker is not visible), the function inserts a NaN
                % into the relevant table
                if isempty(x)||isempty(y);
%                     MarkerLocData.PelletCenter(1,1) = {NaN};
%                     MarkerLocData.PelletCenter(1,2) = {NaN};
                    Table(CurrentMarker,6) = {NaN};
                    Table(CurrentMarker,7) = {NaN};
                    CurrentMarker = CurrentMarker+1;
                % otherwise, function records position data and displays a
                % BLUE circle temporarily where the user indicated the
                % pellet center is
                else
%                     MarkerLocData.PelletCenter(1,1) = num2cell(x);
%                     MarkerLocData.PelletCenter(1,2) = num2cell(y);
                    Table(CurrentMarker,6) = num2cell(x);
                    Table(CurrentMarker,7) = num2cell(y);
                    CurrentMarker = CurrentMarker+1;
                    PelletMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Blue');
                    imshow(PelletMarkerCircle);
                end
            % for the paw center marker...    
            elseif iMarker == 2;
                % if the user does not click and presses Enter (indicating
                % the marker is not visible), the function inserts a NaN
                % into the relevant table
                if isempty(x)||isempty(y);
%                     MarkerLocData.PawCenter(1,1) = {NaN};
%                     MarkerLocData.PawCenter(1,2) = {NaN};
                    Table(CurrentMarker,6) = {NaN};
                    Table(CurrentMarker,7) = {NaN};
                    CurrentMarker = CurrentMarker+1;
                % otherwise, function records position data and displays a
                % RED circle temporarily where the user indicated the
                % paw center is
                else
%                     MarkerLocData.PawCenter(1,1) = num2cell(x);
%                     MarkerLocData.PawCenter(1,2) = num2cell(y);
                    Table(CurrentMarker,6) = num2cell(x);
                    Table(CurrentMarker,7) = num2cell(y);
                    CurrentMarker = CurrentMarker+1;
                    PawCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Red');
                    imshow(PawCenterMarkerCircle);
                end
            % for the metacarpal phalanges-proximal phalanges (McPh-pPh) joints...    
            elseif iMarker == 3 || iMarker == 6 || iMarker == 9 || iMarker == 12;
                % if the user does not click and presses Enter (indicating
                % the marker is not visible), the function inserts a NaN
                % into the relevant table. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky).
                if isempty(x)||isempty(y);
%                     MarkerLocData.MetacarpalPhalanges_ProximalPhalangesHulls(n,1) = {NaN};
%                     MarkerLocData.MetacarpalPhalanges_ProximalPhalangesHulls(n,2) = {NaN};
                    Table(CurrentMarker,6) = {NaN};
                    Table(CurrentMarker,7) = {NaN};
                    CurrentMarker = CurrentMarker+1;
%                     n = n+1;
                % otherwise, function records position data and displays a
                % GREEN circle temporarily where the user indicated the
                % McPh-pPh joint center is. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky). 
                else
%                     MarkerLocData.MetacarpalPhalanges_ProximalPhalangesHulls(n,1) = num2cell(x);
%                     MarkerLocData.MetacarpalPhalanges_ProximalPhalangesHulls(n,2) = num2cell(y);
                    Table(CurrentMarker,6) = num2cell(x);
                    Table(CurrentMarker,7) = num2cell(y);
                    CurrentMarker = CurrentMarker+1;
                    McPh_pPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Green');
                    imshow(McPh_pPhCenterMarkerCircle);
%                     n = n+1;
                end
            % for the proximal phalanges-middle phalanges (pPh-mPh) joints...                   
            elseif iMarker == 4 || iMarker == 7 || iMarker == 10 || iMarker == 13;
                % if the user does not click and presses Enter (indicating
                % the marker is not visible), the function inserts a NaN
                % into the relevant table. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky).
                if isempty(x)||isempty(y);
%                     MarkerLocData.ProximalPhalanges_MiddlePhalangesHulls(o,1) = {NaN};
%                     MarkerLocData.ProximalPhalanges_MiddlePhalangesHulls(o,2) = {NaN};
                    Table(CurrentMarker,6) = {NaN};
                    Table(CurrentMarker,7) = {NaN};
                    CurrentMarker = CurrentMarker+1;
%                     o = o+1;
                % otherwise, function records position data and displays a
                % cyan circle temporarily where the user indicated the
                % pPh-mPh joint center is. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky). 
                else
%                     MarkerLocData.ProximalPhalanges_MiddlePhalangesHulls(o,1) = num2cell(x);
%                     MarkerLocData.ProximalPhalanges_MiddlePhalangesHulls(o,2) = num2cell(y);
                    Table(CurrentMarker,6) = num2cell(x);
                    Table(CurrentMarker,7) = num2cell(y);
                    CurrentMarker = CurrentMarker+1;
                    pPh_mPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Cyan');
                    imshow(pPh_mPhCenterMarkerCircle);
%                     o = o+1;
                end
            % for the middle phalanges-distal phalanges (mPh-dPh) joints...    
            elseif iMarker == 5 || iMarker == 8 || iMarker == 11 || iMarker == 14;
                % if the user does not click and presses Enter (indicating
                % the marker is not visible), the function inserts a NaN
                % into the relevant table. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky).
                if isempty(x)||isempty(y);
%                     MarkerLocData.MiddlePhalanges_DistalPhalangesHulls(p,1) = {NaN};
%                     MarkerLocData.MiddlePhalanges_DistalPhalangesHulls(p,2) = {NaN};
                    Table(CurrentMarker,6) = {NaN};
                    Table(CurrentMarker,7) = {NaN};
                    CurrentMarker = CurrentMarker+1;
%                     p = p+1;
                % otherwise, function records position data and displays a
                % magenta circle temporarily where the user indicated the
                % mPh-dPh joint center is. It then increments so on the next iteration it proceeds to
                % the joint for the next finger (in the order Index,
                % Middle, Ring, Pinky).
                else
%                     MarkerLocData.MiddlePhalanges_DistalPhalangesHulls(p,1) = num2cell(x);
%                     MarkerLocData.MiddlePhalanges_DistalPhalangesHulls(p,2) = num2cell(y);
                    Table(CurrentMarker,6) = num2cell(x);
                    Table(CurrentMarker,7) = num2cell(y);
                    CurrentMarker = CurrentMarker+1;
                    mPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Magenta');
                    imshow(mPh_dPhCenterMarkerCircle);
%                     p = p+1;
                end                
            end
            % the last marked marker position data is exported to the base
            % workspace in the structure LastMarkedMarkerData, which builds
            % until it is filled for a given frame region, then resets
            assignin('base','CumMarkedMarkersLocations', Table);
            handles.CumMarkedMarkersLocations = Table;
            guidata(hObject, handles);
        end
        CurrentMarker = length(MarkerPoints)+(length(MarkerPoints)*(iFrameRegion-1))+((length(MarkerPoints)*3)*(iFrame-1))+1;
        % the frame region marker data is put in the appropriate structure 
%         if iFrameRegion == 1;
%             FrameData.Left = MarkerLocData;
%         elseif iFrameRegion == 2;
%             FrameData.Center = MarkerLocData;
%         elseif iFrameRegion == 3;
%             FrameData.Right = MarkerLocData;
%         end
        % All the markers for a given frame region for a given frame are exported to the base
        % workspace in the structure LastMarkedFrameData, which resets when
        % a frame is completed. 
%         assignin('base','LastMarkedFrameData', FrameData);
    end    
    % the total frame data for all regions is put into the output structure
    % AllFramesMarkerLocData
%     AllFramesMarkerLocData{r} = FrameData;
    % After a frame is done, all of its data is exported to the base
    % workspace in the structure CumFrameData, which builds until all
    % frames are completed. So, ideally, when the program is completed,
    % CumFrameData should look exactly like the output
    % AllFramesMarkerLocData. If it is ended prematurely, it saves up to
    % the last completed frame. 
%     assignin('base','CumFrameData',AllFramesMarkerLocData);
%     r = r+1;
%     handles.k = iFrame;
    % output (AllFramesMarkerLocData) updated in handles structure with
    % every frame completion
%     handles.CumFrameData = AllFramesMarkerLocData;
%     guidata(hObject, handles);
close;    
end

end

