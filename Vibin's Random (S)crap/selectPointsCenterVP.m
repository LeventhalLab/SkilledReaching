%Titus John, titusaj@umich.edu
%Levethal Lab, University of Michigan
%release----------beta----------------------

%Select the points of the center video reach, return the center paw coordinate, 
%1st digit coordinate, 2nd digit coordinate, 3rd digit coordinate, 4th digit coordinate i.e. thumb --> pinky, metacarpal joints --> distal phalanges joints  

function [center_x, center_y, all_joints_x,all_joints_y] = selectPointsCenterVP(im)
        
%% Array to hold all the user x, and y slected coordinate
    all_joints_x = [];
    all_joints_y = [];


    nextImage = 0;
    
   
    
    while(nextImage == 0)
         imshow(im)
        
   %% Select the center of the paw
        [center_x, center_y] = getpts
        fig1 = insertShape(im, 'FilledCircle', [center_x, center_y 4], 'Color', 'White');
        imshow(fig1)
        hold on;
  %% Select the three joints of the digit
  
    currentFig = [];    
    prevFig = [];
  
     for i=1:4 %loop through the four digits of the paw
               for j=1:3 %loop through the three joints of the paw

                   %pull of the digit name (number) and the point marked on
                   %the digit
                   digitNum = num2str(i);
                   digitSectionNum = num2str(j);
                   message  = strcat('Digit - ',digitNum,'Section - ', digitSectionNum);
                   
                   
                    options.Interpreter = 'tex';
                    options.Default = 'Yes';
                    pointExsistButton = questdlg (message,'Point Exsist','Yes','No', options);
                    
                    
                    nextPoint = 1;
                    
                    switch pointExsistButton
                        case 'Yes'
                           nextPoint = 1;
                        case 'No'
                           nextPoint = 0;
                    end
                    
                     if i==1 && j==1 %% For the first itteration set the current figure to fig 1
                        prevFig = fig1;
                     end

                    if nextPoint == 1
                        [x, y] = getpts
                        all_joints_x{i,j} = x;
                        all_joints_y{i,j} = y;


                    currentFig = insertShape(prevFig, 'FilledCircle', [x, y 4], 'Color', 'Red');
                        
                    imshow(currentFig)
                    prevFig = currentFig;
                    hold on
                    
                    elseif nextPoint == 0 
                        all_joints_x{i,j} = 0;
                        all_joints_y{i,j} = 0;
                
                    end
                    
                    
                    hold on;      
           end
      end
    
      

       % Construct a questdlg   
       options.Interpreter = 'tex';
       options.Default = 'Yes';
       acceptPointsButton = MFquestdlg([ 0.6 , 0.1 ] ,'Accept Points Placed?', ...
            'Point Check', ...
            'Yes','No',options);
        
        
        % Handle response
        switch acceptPointsButton
            case 'Yes'
               nextImage = 1;
            case 'No'
               nextImage = 0;
        end

        close

    end
    
end


