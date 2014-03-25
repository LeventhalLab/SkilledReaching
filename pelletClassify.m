function [grasp] = pelletClassify(pelletCenters,pawHulls)
    % test: not enough frames, too many frames, last moment not in hull
    [rows,~,~] = find(~isnan(pelletCenters(:,1)));
    
    percentWithPellets = (size(rows,1)/size(pelletCenters,1))*100;
    if(percentWithPellets > 10 & percentWithPellets < 90)
        grasp = inhull(pelletCenters(max(rows),:),pawHulls{max(rows)});
    else
        grasp = 0; 
    end
end