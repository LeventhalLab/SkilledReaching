function dataMatrix = putAlternateEndpointIntoBlocks(alternateKinematicSummaryHisto)

% function divides kinematic data into blocks of laser on and laser off with
% NaN between to designate (based on
% alternateKinematicSummaryHisto.laserInfo (0 = laser off, 1 = laser on)

% if rat broke beam at the back of the box but did not reach, trial counted
% as 1 of the 5 but isn't in the kinematic data so need to identify those
% and add NaNs in

alternateKinematicSummaryHisto(6).laserInfo(40) = NaN; % remove mistakes
alternateKinematicSummaryHisto(7).laserInfo(47) = NaN;
alternateKinematicSummaryHisto(18).laserInfo(78) = NaN;
alternateKinematicSummaryHisto(23).laserInfo(27) = NaN;

numSess = size(alternateKinematicSummaryHisto,1);

dataMatrix = NaN(110,numSess,3);

% for i_sess = 1:numSess
for i_dim = 1:3 % x, y, z dimensions
    for i_sess = 1:numSess

        i_num = 1;
        for i_trial = 2:size(alternateKinematicSummaryHisto(i_sess).laserInfo,1)

            cur_trial = alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial); %determine type of trial for current, previous, next (on, off, no reach - NaN) 
            prev_trial = alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-1);
            if i_trial == size(alternateKinematicSummaryHisto(i_sess).laserInfo,1)
                next_trial = NaN;
            else 
                next_trial = alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+1); 
            end

            if isnan(cur_trial)

                if i_trial == 2 && alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5) == 0 %if rat starts session on trial 3
                    continue
                elseif i_trial + 5 > size(alternateKinematicSummaryHisto(i_sess).laserInfo,1)
                     dataMatrix(i_num,i_sess,i_dim) = NaN;                
                elseif prev_trial - next_trial == 0 || isnan(next_trial) &&...
                        alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+2) == prev_trial...
                        || isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+ 2)) && isnan(prev_trial) % NaN is in the middle of a block (i.e., 00NaN00)
                        if size(alternateKinematicSummaryHisto(i_sess).laserInfo,1) < i_trial + 3 || i_trial <= 4
                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                        elseif alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-1) == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+4)...
                               || alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-2) == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+3)...
                               || alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+1) == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-4)...
                               || alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+2) == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-3)
                            continue % skips trial if there are 5 other trial in the block (i.e., this would be 6th and not valid)
                            else
                                dataMatrix(i_num,i_sess,i_dim) = NaN;

                        end 

                else % NaN is between blocks (i.e., ...00NaN11...)
                    if i_trial + 5 > size(alternateKinematicSummaryHisto(i_sess).laserInfo,1)
                            dataMatrix(i_num,i_sess,i_dim) = NaN;
                    else
                        if i_trial <= 6
                            dataMatrix(i_num,i_sess,i_dim) = NaN;
                            i_num = i_num+1;
                            dataMatrix(i_num,i_sess,i_dim) = NaN;

                    else 
                        if next_trial == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5)
                            dataMatrix(i_num,i_sess,i_dim) = NaN;
                        else
                            if prev_trial == alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5)...
                                    || isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5)) && ~isnan(prev_trial) %edited
                            dataMatrix(i_num,i_sess,i_dim) = NaN;
                            i_num = i_num+1;
                            dataMatrix(i_num,i_sess,i_dim) = NaN;

                            else
                                if isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5))...
                                    && isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+6))
                                    dataMatrix(i_num,i_sess,i_dim) = NaN;
                                end 
                                if alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-5) ~= prev_trial...
                                    && ~isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-5)) && ~isnan(prev_trial)
                                    i_num = i_num+1;
                                    dataMatrix(i_num,i_sess,i_dim) = NaN;
                                end 
                            end 
                            end 
                        end 
                    end
                end 

            elseif cur_trial == 0 || cur_trial == 1
                edge = cur_trial-prev_trial; % determine if you are on the start of a new block (transition from off to on or vice versa)

                cur_row = find(alternateKinematicSummaryHisto(i_sess).trialNumbers == i_trial);

                if isempty(cur_row)
                    if edge == 0
                        dataMatrix(i_num,i_sess,i_dim) = NaN;
                    elseif isnan(edge)
                        dataMatrix(i_num,i_sess,i_dim) = NaN;
                    else 
                        dataMatrix(i_num,i_sess,i_dim) = NaN;
                        i_num = i_num+1;
                        dataMatrix(i_num,i_sess,i_dim) = NaN;
                    end  

                else       
                    kinemData = alternateKinematicSummaryHisto(i_sess).dig_endPoints(cur_row,i_dim); 

                     if size(cur_row,1) > 1 % if trial numbers restart during a session, selects the correct trial
                        if exist('repNums','var')
                            if ismember(i_trial,repNums)
                                cur_row = cur_row(2);
                                kinemData = alternateKinematicSummaryHisto(i_sess).dig_endPoints(cur_row); 

                            else
                                cur_row = cur_row(1);
                                repNums = [repNums i_trial];
                                kinemData = alternateKinematicSummaryHisto(i_sess).dig_endPoints(cur_row); 

                            end
                        else
                            repNums = i_trial;
                            cur_row = cur_row(1);
                            kinemData = alternateKinematicSummaryHisto(i_sess).dig_endPoints(cur_row); 

                        end
                     end
                end 

                    if edge == 0 || isnan(edge) % in the middle of a block or next to nan
                        dataMatrix(i_num,i_sess,i_dim) = kinemData;

                    else % start of new block
                        if size(alternateKinematicSummaryHisto(i_sess).laserInfo,1) < i_trial + 5
                            dataMatrix(i_num,i_sess,i_dim) = NaN;
                            i_num = i_num+1;
                            dataMatrix(i_num,i_sess,i_dim) = kinemData;
                        elseif isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5))...
                                || alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5) == cur_trial
                            numNan = sum(isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+1:i_trial+5)));

                            if numNan == 0 || isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+4)) &&...
                                    alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+5) ~= cur_trial

                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;
                                 dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;
                                dataMatrix(i_num,i_sess,i_dim) = kinemData;

                            else
                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;
                                dataMatrix(i_num,i_sess,i_dim) = kinemData;
                            end 

                        elseif isnan(alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+4)) ||...
                                alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial+4) == prev_trial %added this last
                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;
                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;

                            if alternateKinematicSummaryHisto(i_sess).laserInfo(i_trial-5) == cur_trial
                                i_num = i_num+1;
                                dataMatrix(i_num,i_sess,i_dim) = NaN;
                                i_num = i_num+1;
                                dataMatrix(i_num,i_sess,i_dim) = kinemData;
                            else
                                dataMatrix(i_num,i_sess,i_dim) = kinemData;
                            end                                                          

                        else                        
                        dataMatrix(i_num,i_sess,i_dim) = NaN;
                        i_num = i_num+1;
                        dataMatrix(i_num,i_sess,i_dim) = kinemData;
                        end 
                    end 

            end 
                i_num = i_num+1;        
        end 
    end
end 