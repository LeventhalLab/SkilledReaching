function panelPoints = getPanelPoints(session_mp)

panelPoints = zeros(8,2);

panelPoints(1,:) = session_mp.leftMirror.front_panel_top_front;
panelPoints(2,:) = session_mp.leftMirror.front_panel_top_back;
panelPoints(3,:) = session_mp.leftMirror.front_panel_bot_back;
panelPoints(4,:) = session_mp.leftMirror.front_panel_bot_front;

panelPoints(5,:) = session_mp.rightMirror.front_panel_top_front;
panelPoints(6,:) = session_mp.rightMirror.front_panel_top_back;
panelPoints(7,:) = session_mp.rightMirror.front_panel_bot_back;
panelPoints(8,:) = session_mp.rightMirror.front_panel_bot_front;