function matchedPoints = read_xl_matchedPoints( varargin )

% function to read in matching box points from excel files

kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
xl_directory = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';

sr_ratInfo = get_sr_RatList();

cd(xl_directory);

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    
    xlName = [ratID '_matched_points.xlsx'];
    
    [status,sheets] = xlsfinfo(xlName);

    numSheets = length(sheets);
    
    for iSheet = 1 : numSheets
        fprintf('rat %d, sheet %d\n', i_rat,iSheet)
        [xldata,xlstrings,~] = xlsread(xlName, sheets{iSheet});
        sessionDate = sheets{iSheet}(7:14);
        sessionName = [ratID '_' sessionDate];
        
%         numFields = 0;
        for ii = 2 : size(xlstrings,1)    % skip the "DIRECT VIEW" header
            
            if ~isempty(xlstrings{ii,1})
%                 numFields = numFields + 1;
                if ii > size(xldata,1)+1
                    matchedPoints(i_rat).(sessionName).direct.(xlstrings{ii,1}) = nan(1,2);
                    matchedPoints(i_rat).(sessionName).leftMirror.(xlstrings{ii,1}) = nan(1,2);
                    matchedPoints(i_rat).(sessionName).rightMirror.(xlstrings{ii,1}) = nan(1,2);
                else
                    matchedPoints(i_rat).(sessionName).direct.(xlstrings{ii,1}) = ...
                        xldata(ii-1,1:2);
                    matchedPoints(i_rat).(sessionName).leftMirror.(xlstrings{ii,1}) = ...
                        xldata(ii-1,3:4);
                    matchedPoints(i_rat).(sessionName).rightMirror.(xlstrings{ii,1}) = ...
                        xldata(ii-1,5:6);
                end
            end
            
        end
        
    end
end