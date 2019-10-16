function alternateKinematics = initializeAlternateKinematicsStructure(ratID,sessionDate)

alternateKinematics.ratID = ratID;
alternateKinematics.sessionDate = sessionDate;

alternateKinematics.pd_endPts = [];
alternateKinematics.dig2_endPts = [];
alternateKinematics.endAperture = [];
alternateKinematics.endOrientation = [];
alternateKinematics.max_pd_v = [];

alternateKinematics.trialNumbers = [];
alternateKinematics.slot_z_wrt_pellet = [];

alternateKinematics.first_success_rate = [];
alternateKinematics.any_success_rate = [];

alternateKinematics.on_pd_endPts = [];
alternateKinematics.off_pd_endPts = [];
alternateKinematics.mean_on_pd_endPts = [];
alternateKinematics.mean_off_pd_endPts = [];
alternateKinematics.std_on_pd_endPts = [];
alternateKinematics.std_off_pd_endPts = [];

alternateKinematics.on_dig2_endPts = [];
alternateKinematics.off_dig2_endPts = [];
alternateKinematics.mean_on_dig2_endPts = [];
alternateKinematics.mean_off_dig2_endPts = [];
alternateKinematics.std_on_dig2_endPts = [];
alternateKinematics.std_off_dig2_endPts = [];

alternateKinematics.on_endAperture = [];
alternateKinematics.off_endAperture = [];
alternateKinematics.mean_on_endAperture = [];
alternateKinematics.mean_off_endAperture = [];
alternateKinematics.std_on_endAperture = [];
alternateKinematics.std_off_endAperture = [];

alternateKinematics.on_endOrientation = [];
alternateKinematics.off_endOrientation = [];
alternateKinematics.mean_on_endOrientation = [];
alternateKinematics.mean_off_endOrientation = [];
alternateKinematics.std_on_endOrientation = [];
alternateKinematics.std_off_endOrientation = [];

alternateKinematics.on_max_pd_v = [];
alternateKinematics.off_max_pd_v = [];
alternateKinematics.mean_on_max_pd_v = [];
alternateKinematics.mean_off_max_pd_v = [];
alternateKinematics.std_on_max_pd_v = [];
alternateKinematics.std_off_max_pd_v = [];

alternateKinematics.thisRatInfo = [];