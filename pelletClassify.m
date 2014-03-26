function [graspIndexes,success] = pelletClassify(pelletBboxes,pawHulls)
    rows = size(pelletBboxes,1);
    graspIndexes = zeros(rows,1);
    success = 0;
    
    for i=1:rows
        % if there is a pellet and a paw
        if(~isnan(pelletBboxes(i,1)) && ~isnan(pawHulls{i}(1)))
            corners = bboxCorners(pelletBboxes(i,:));
            for j=1:size(corners,1)
                % just keep OR'ing these to catch any pellet-in-hull events
                graspIndexes(i) = graspIndexes(i)|inhull(corners(j,:),pawHulls{i});
            end
        end
    end
    % trim to only indexes
    graspIndexes = find(graspIndexes==1);
    maxGraspIndex = max(graspIndexes);
    if(maxGraspIndex < rows)
        % does pellet disappear within grasp?
        % opposite of this is a deflection
        if(isnan(pelletBboxes(max(graspIndexes)+1,1)))
            success = 1;
        end
    else
        % pellet in grasp of last frame
        success = 1;
    end
end

function [corners] = bboxCorners(bbox)
    corners = [bbox(1,1:2);bbox(1)+bbox(3) bbox(2);bbox(1) bbox(2)+bbox(4);...
        bbox(1)+bbox(3) bbox(2)+bbox(4)];
end