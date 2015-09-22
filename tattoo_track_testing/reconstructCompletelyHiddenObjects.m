function tracks = reconstructCompletelyHiddenObjects(tracks, bboxes, imSize, BG_mask, varargin)
%
% INPUTS:
%   tracks - 2-element cell array containing the masks of the object within
%       a bounding box in each view
%   bboxes - 2 x 4 array containing the bounding boxes of mask1 and mask2
%       within their larger images. (row 1--> mask 1, row 2 --> mask2)
%   imSize - 1 x 2 vector containing the height and width of the image
%   BG_mask - 1 x 3 cell array containing the background mask in the
%       center, dorsum mirror, and palm mirror, respectively. The mask only
%       contains the corresponding bounding boxes defined by bboxes
% VARARGs:
%
% OUTPUTS:
%   tracks - 


for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'maxdistfromepipolarline',
            maxDistFromEpipolarLine = varargin{iarg + 1};
    end
end

% first task is to compute the ray projecting back from the point that we
% do know
for iDigit = 1 : 4
    currentTrack = tracks(iDigit + 1);
    obscuredView = find(currentTrack.isvisible);
    
    if isempty(obscuredView); continue; end    % no obscured views for this digit
    
    if length(obscuredView) == 1    % one of the views is obscured
        visible_view = 3 - obscuredView;
        visible_bbox = bboxes(visible_view,:);
        visible_pts  = currentTrack.digitMarkers(:,:,visible_view)';
        for ii = 1 : 3
            visible_pts(ii,:) = visible_pts(ii,:) + visible_bbox(1:2);
        end
        
        
    end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
