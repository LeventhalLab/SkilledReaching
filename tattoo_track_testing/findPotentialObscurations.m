function possObscuredMatrix = findPotentialObscurations(allDigitMasks, fundmat, bbox, imSize, isDirectView)
%
%
% INPUTS:
%
% OUTPUTS:
%   possObscuredMatrix - 

numDigits = size(allDigitMasks, 3);
possObscuredMatrix = false(numDigits);
masks = false(size(allDigitMasks,1),size(allDigitMasks,2),2);

for ii = 1 : numDigits - 1
    masks(:,:,1) = allDigitMasks(:,:,ii);
    for jj = ii + 1 : numDigits
        masks(:,:,2) = allDigitMasks(:,:,jj);
    
        possObscured = couldObjectsBeObscured(masks, fundmat, bbox, imSize, isDirectView);
        
        possObscuredMatrix(ii,jj) = possObscured(1);
        possObscuredMatrix(jj,ii) = possObscured(2);
        
    end    % jj
end    % ii