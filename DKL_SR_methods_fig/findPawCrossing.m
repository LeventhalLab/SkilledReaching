function barrierBreaks= findPawCrossing(z_new)



    for i =1:length(z_new(:,1)) %number of trials
       current_z = z_new(i,:);
%        counterBarrierBreaks  =1 ; %Counter to see how many times the paw cross the front of the box
       
       
       checkFrameFound = 0; %Check from checks if start frame is found  
       
     
           for j = 1:length(current_z) %frame length of current reach
                if checkFrameFound == 0 
                    if current_z(j) < 170
                        barrierBreaks(i) = j ;
                        checkFrameFound = 1; %This check becomes 1 when the start frame is found
                    end
               end
           end
       
    end
end