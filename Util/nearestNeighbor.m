function [nn, meansep] = nearestNeighbor(x)
%
% usage: 
%

diffMatrix = zeros(size(x,1)-1,size(x,2));
nn = zeros(size(x,1),1);
meansep = zeros(size(x,1),1);
for ii = 1 : size(x,1)
    curPoint = x(ii,:);
    switch ii
        case 1,
            otherPoints = x(ii+1:end,:);
        case size(x,1),
            otherPoints = x(1:end-1,:);
        otherwise,
            otherPoints = [x(1:ii-1,:);x(ii+1:end,:)];   
    end
    
    for jj = 1 : size(x,2)
        diffMatrix(:,jj) = curPoint(jj) - otherPoints(:,jj);
    end
    distances = sqrt(sum(diffMatrix.^2, 2));
    
    nn(ii) = min(distances);
    meansep(ii) = mean(distances);
end