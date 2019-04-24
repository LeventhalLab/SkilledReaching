%This script will take in the plots for Day 3, 7 10 for rats and spit out 
%pdfs of the comparisons. 

%R27

%Score Counters
count1=1;
count2=1;
count3=1;
count4=1;
count5=1;
count6=1;
count7=1;
count0=1;

for i=1:length(R27scores(:,1))
    
    Day3Scores(i) = R27scores(i,1);
    
    if Day3Scores(i) == 1 
      Day3_1scores(count1) = i;
      count1 = count1 +1;
    end
    
    if Day3Scores (i) == 2
       Day3_2scores(count2) = i;
       count2 = count2 +1;
    end
    
    if Day3Scores (i) == 3
        Day3_3scores(count3) = i;
        count3= count3+1;
    end
    
    if Day3Scores (i) == 4
        Day3_4scores(count4) = i;
        count4= count4+1;
    end
    
    if Day3Scores (i) == 5
        Day3_5scores(count5) = i;
        count5= count5+1;
    end
    
    if Day3Scores (i) == 6
        Day3_6scores(count6) = i;
        count6= count6+1;
    end
    
       
    if Day3Scores (i) == 7
        Day3_7scores(count7) = i;
        count7= count7+1;
    end
    
       
    if Day3Scores (i) == 0
        Day3_0scores(count0) = i;
        count0= count0 +1;
    end
    
end

totalNumReaches = count1+count2+count3+count4+count7-5;
sectionSize = ceil(totalNumReaches/3);

sectionIndex1 = sectionSize;
sectionIndex2 = 2*sectionSize;
sectionIndex3 = 3*sectionSize;

%Plot histogram of data broken into three diffrent blocks for a given day

for i=1:sectionIndex1
    hist
end

for i=sectionIndex1:sectionIndex2

end

for i=sectionIndex2:sectionIndex3
    
end