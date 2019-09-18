function [outcomeRates, numOmitted] = calculateSessionOutcomes(trialOutcomes)
%
% INPUTS
%   trialOutcomes - vector containing assigned trial outcome for each trial
%       in the session (see table below for codes)
%
% OUTPUTS
%   outcomeRates - vector of percentage of trials with a specific outcome
%   numOmitted - trials omitted from the final trial count (ones where the
%       paw started out through the slot, there was no forelimb advance, or
%       the rat used its tongue)
%
% REACHING SCORES:
%
% 0 ? No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue
% 11 - paw started out through the slot

% ignore any reaches where the paw started on the wrong slide of the slot,
% or no reach was performed (11's,  6's, 5's)

totalTrials = length(trialOutcomes);

trialOutcomes = trialOutcomes(trialOutcomes ~= 11);
trialOutcomes = trialOutcomes(trialOutcomes ~= 6);
trialOutcomes = trialOutcomes(trialOutcomes ~= 5);

numTrials = length(trialOutcomes);
numOmitted = totalTrials - numTrials;

% outcomeRates(1) is the first reach success rate
% outcomeRates(2) is the any reach success rate
% outcomeRates(3) is the number of trials in which the pellet was grabbed
%   but dropped in the box
% outcomeRates(4) is the number of trials in which the pellet was knocked
%   off the shelf
% outcomeRates(5) is the number of trials in which the rat reached but the
%   pellet didn't move
outcomeRates = zeros(1,5);
firstReachSuccessTrials = (trialOutcomes == 1);
outcomeRates(1) = sum(firstReachSuccessTrials)/numTrials;

anyReachSuccessTrials = (trialOutcomes == 1) | (trialOutcomes == 2);
outcomeRates(2) = sum(anyReachSuccessTrials)/numTrials;

droppedInBoxTrials = (trialOutcomes == 3);
outcomeRates(3) = sum(droppedInBoxTrials)/numTrials;

knockedOffTrials = (trialOutcomes == 4);
outcomeRates(4) = sum(knockedOffTrials)/numTrials;

pelletStillTrials = (trialOutcomes == 7);
outcomeRates(4) = sum(pelletStillTrials)/numTrials;