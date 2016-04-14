function slotFrames = DKL_slotCrossFrames(z,varargin)

slot_z = 175;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'slot_z',
            slot_z = varargin{iarg + 1};
    end
end

slotFrames = NaN(1, size(z,2));
for i_traj = 1 : size(z,2)
    temp = find(z(:,i_traj) < slot_z, 1);
    if ~isempty(temp)
        slotFrames(i_traj) = temp;
    end
end