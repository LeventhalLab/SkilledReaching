function pelletTouches = findPelletTouch (x_new, y_new,z_new,pellet3d,barrierBreaks)

 for i =1:length(barrierBreaks) %This loops through the invidual trials for a given rat
     current_x = x_new(i,:);
     current_y = y_new(i,:);
     current_z = z_new(i,:);
     
     current_barrier_break = barrierBreaks(i);
     
    
     for j = 1:length(current_x)
        distancesPelletToCenterofPaw(j) = sqrt((pellet3d(1)-current_x(j))^2+(pellet3d(2)-current_y(j)^2+(pellet3d(3) - current_z(j))^2));
     end
     
    if current_barrier_break > 10
     startIndex = current_barrier_break-10;
     endIndex = current_barrier_break+10;
     filteredDistancesPelletToCenterofPaw = distancesPelletToCenterofPaw(startIndex:endIndex);
     
     
     [MinDistancePelletToCenterofPaw,IndexMinDistaance] = min(filteredDistancesPelletToCenterofPaw);
     distanceMinIndex(i) = (IndexMinDistaance-10)+current_barrier_break;
     
    else
        distanceMinIndex(i) = 0;
    end
    
 end

    pelletTouches = distanceMinIndex; %This should be the length of the scores array (ie. it correspond to the amount of reaches ins agiven session);


end