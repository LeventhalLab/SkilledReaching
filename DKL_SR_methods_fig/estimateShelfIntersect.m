function [leftShelfEdge, rightShelfEdge] = estimateShelfIntersect(session_mp)

if all(~isnan(session_mp.leftMirror.left_top_shelf_corner))
    % means the left top shelf corner was visible
    leftShelfEdge = session_mp.leftMirror.left_top_shelf_corner;
else
    leftMirror = session_mp.leftMirror;
    shelf_front = [leftMirror.right_top_shelf_corner;...
                   leftMirror.left_shelf_front_mirror_pts_a;...
                   leftMirror.left_shelf_front_mirror_pts_b;...
                   leftMirror.left_shelf_front_mirror_pts_c];
    shelf_side = [leftMirror.left_back_shelf_corner;...
                  leftMirror.left_shelf_side_mirror_pts_a;...
                  leftMirror.left_shelf_side_mirror_pts_b;...
                  leftMirror.left_shelf_side_mirror_pts_c];
              
	p_front = polyfit(shelf_front(:,1), shelf_front(:,2), 1);
    p_side = polyfit(shelf_side(:,1), shelf_side(:,2), 1);
    
    front_lineCoeff = slopeInt_toLineCoeff(p_front(1),p_front(2));
    side_lineCoeff = slopeInt_toLineCoeff(p_side(1),p_side(2));
    
% code to overlay points on the undistorted image
%     plot(shelf_front(:,1),shelf_front(:,2),'marker','*','linestyle','none')
%     plot(shelf_side(:,1),shelf_side(:,2),'marker','*','linestyle','none')
%     bpts = lineToBorderPoints(front_lineCoeff,[1086,2040]);
%     line([bpts(1),bpts(3)],[bpts(2),bpts(4)])
%     bpts = lineToBorderPoints(side_lineCoeff,[1086,2040]);
%     line([bpts(1),bpts(3)],[bpts(2),bpts(4)])
    
    leftShelfEdge = findIntersection(front_lineCoeff,side_lineCoeff);
    
end

if all(~isnan(session_mp.rightMirror.right_top_shelf_corner))
    % means the right top shelf corner was visible
    rightShelfEdge = session_mp.rightMirror.right_top_shelf_corner;
else
    rightMirror = session_mp.rightMirror;
    shelf_front = [rightMirror.left_top_shelf_corner;...
                   rightMirror.right_shelf_front_mirror_pts_a;...
                   rightMirror.right_shelf_front_mirror_pts_b;...
                   rightMirror.right_shelf_front_mirror_pts_c];
    shelf_side = [rightMirror.right_back_shelf_corner;...
                  rightMirror.right_shelf_side_mirror_pts_a;...
                  rightMirror.right_shelf_side_mirror_pts_b;...
                  rightMirror.right_shelf_side_mirror_pts_c];
              
	p_front = polyfit(shelf_front(:,1), shelf_front(:,2), 1);
    p_side = polyfit(shelf_side(:,1), shelf_side(:,2), 1);
    
    front_lineCoeff = slopeInt_toLineCoeff(p_front(1),p_front(2));
    side_lineCoeff = slopeInt_toLineCoeff(p_side(1),p_side(2));
    
% code to overlay points on the undistorted image
%     plot(shelf_front(:,1),shelf_front(:,2),'marker','*','linestyle','none')
%     plot(shelf_side(:,1),shelf_side(:,2),'marker','*','linestyle','none')
%     bpts = lineToBorderPoints(front_lineCoeff,[1086,2040]);
%     line([bpts(1),bpts(3)],[bpts(2),bpts(4)])
%     bpts = lineToBorderPoints(side_lineCoeff,[1086,2040]);
%     line([bpts(1),bpts(3)],[bpts(2),bpts(4)])
    
    rightShelfEdge = findIntersection(front_lineCoeff,side_lineCoeff);
end