function [north,south] = poles(A)

    % create the distance matrix
    dist = distmat(A);

    % find all candidate pairs of north and south poles
    [~, iMax] = max(dist(:));
    [iN, iS] = ind2sub(size(dist), iMax);
    
    north = A(iN, 1:2);
    south = A(iS, 1:2);

    % If there is only one, you are done, otherwise break the ties.
    if length(iMax) == 1
        return
    end

    %
    % break ties by the euclidean distance of the x-y coordinates
    % note that this may not result in a unique set of north and south poles,
    % but you can always break further ties.

    tieBreak = sum(abs(north-south).^2, 2);

    [~, iMax] = max(tieBreak);

    iN = iN(iMax);
    iS = iS(iMax);

    north = A(iN, 1:2);
    south = A(iS, 1:2);
end