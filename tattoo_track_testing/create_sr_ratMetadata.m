function rat_metadata = create_sr_ratMetadata(sr_summary, ratID)
%
% INPUTS:
%   sr_summary - structure containing a summary of all skilled reaching
%       rats for this analysis (paw preference, paw ID method - tattoo vs
%       nail polish, etc. - see function sr_ratList)
%
% OUTPUTS:
%   rat_metadata - structure with metadata for ratID in a structure that
%       has the same fields as sr_summary 

rat_idx = sr_summary.ratID == ratID;

sr_parameters  = fieldnames(sr_summary);
num_parameters = length(sr_parameters);

for ii = 1 : num_parameters
    
    rat_metadata.(sr_parameters{ii}) = sr_summary.(sr_parameters{ii})(rat_idx);
    if iscell(rat_metadata.(sr_parameters{ii}))
        rat_metadata.(sr_parameters{ii}) = rat_metadata.(sr_parameters{ii}){1};
    end
    
end