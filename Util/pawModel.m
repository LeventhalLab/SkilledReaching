function pawPositions = pawModel(pawOrigin, wristRot, digitAngles) 

% jointAngles is a 2 x 4 matrix. First row is MCP joint, second row is PIP
% joints. each row starts with the index finger and ends with the pinky

pawWidth = 1;
digitWidth = 0.25 * pawWidth;
digitCenters = digitWidth/2 : digitWidth
pawLength = 1;
pawDepth = digitWidth;

palm = zeros(5,3,2);
palm(:,:,1) = [0        0         0
               pawWidth 0         0
               pawWidth pawLength 0
               0        pawLength 0
               0        0         0];
palm(:,:,2) = [0        0         pawDepth
               pawWidth 0         pawDepth
               pawWidth pawLength pawDepth
               0        pawLength pawDepth
               0        0         pawDepth];
    
digits = zeros(2,2,4);    % 2 points define each digit segment, 2 segments per digit, 4 digits
digits(1,1,:) = linspace(0,1,4);