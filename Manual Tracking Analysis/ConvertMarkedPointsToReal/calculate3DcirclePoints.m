

function [x,y,z] = calculate3DcirclePoints (cx, cy, cz,rx,ry,rz,A,B)
    A = cell2mat(A);
    B = cell2mat(B);
    
    a1 = A(:,1);
    a2 = A(:,2);
    a3 = A(:,3);

    b1 = B(:,1);
    b2 = B(:,2);
    b3 = B(:,3);


    theta=0:0.01:2*pi;
    for i =1:length(theta)
        x(i) = cx + rx*cos(theta(i))*a1 + rx*sin(theta(i))*b1;
        y(i) = cy + ry*cos(theta(i))*a2 + ry*sin(theta(i))*b2;
        z(i) = cz + rz*cos(theta(i))*a3 + rz*sin(theta(i))*b3;
    end
end