function alternateKinematics = analyzeAlternatingKinematics(alternateKinematics)

numSessions = length(alternateKinematics);

for iSession = 1 : numSessions
    
    alternateKinematics(iSession).mean_on_pd_endPts = ...
        squeeze(nanmean(alternateKinematics(iSession).on_pd_endPts,1));
    alternateKinematics(iSession).mean_off_pd_endPts = ...
        squeeze(nanmean(alternateKinematics(iSession).off_pd_endPts,1));
    alternateKinematics(iSession).std_on_pd_endPts = ...
        squeeze(nanstd(alternateKinematics(iSession).on_pd_endPts,0,1));
    alternateKinematics(iSession).std_off_pd_endPts = ...
        squeeze(nanstd(alternateKinematics(iSession).off_pd_endPts,0,1));    
    
    alternateKinematics(iSession).mean_on_dig2_endPts = ...
        squeeze(nanmean(alternateKinematics(iSession).on_dig2_endPts,1));
    alternateKinematics(iSession).mean_off_dig2_endPts = ...
        squeeze(nanmean(alternateKinematics(iSession).off_dig2_endPts,1));
    alternateKinematics(iSession).std_on_dig2_endPts = ...
        squeeze(nanstd(alternateKinematics(iSession).on_dig2_endPts,0,1));
    alternateKinematics(iSession).std_off_dig2_endPts = ...
        squeeze(nanstd(alternateKinematics(iSession).off_dig2_endPts,0,1));

    alternateKinematics(iSession).mean_on_endAperture = ...
        nanmean(alternateKinematics(iSession).on_endAperture,1);
    alternateKinematics(iSession).mean_off_endAperture = ...
        nanmean(alternateKinematics(iSession).off_endAperture,1);
    alternateKinematics(iSession).std_on_endAperture = ...
        nanstd(alternateKinematics(iSession).on_endAperture,0,1);
    alternateKinematics(iSession).std_off_endAperture = ...
        nanstd(alternateKinematics(iSession).off_endAperture,0,1);

    alternateKinematics(iSession).mean_on_endOrientation = ...
        nanmean(alternateKinematics(iSession).on_endOrientation,1);
    alternateKinematics(iSession).mean_off_endOrientation = ...
        nanmean(alternateKinematics(iSession).off_endOrientation,1);
    alternateKinematics(iSession).std_on_endOrientation = ...
        nanstd(alternateKinematics(iSession).on_endOrientation,0,1);
    alternateKinematics(iSession).std_off_endOrientation = ...
        nanstd(alternateKinematics(iSession).off_endOrientation,0,1);
    
    alternateKinematics(iSession).mean_on_max_pd_v = ...
        nanmean(alternateKinematics(iSession).on_max_pd_v,1);
    alternateKinematics(iSession).mean_off_max_pd_v = ...
        nanmean(alternateKinematics(iSession).off_max_pd_v,1);
    alternateKinematics(iSession).std_on_max_pd_v = ...
        nanstd(alternateKinematics(iSession).on_max_pd_v,0,1);
    alternateKinematics(iSession).std_off_max_pd_v = ...
        nanstd(alternateKinematics(iSession).off_max_pd_v,0,1);
    
end