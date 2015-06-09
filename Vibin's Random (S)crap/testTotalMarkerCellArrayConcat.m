x = {'car','truck','van'}; 
y = {'person','dog','cat'}; 
z = {'red','yellow','blue'};

m = 1;
for i = 1:length(x);
    for j = 1:length(y);
        for k = 1:length(z);
            TotList{m} = strcat(x(i),y(j),z(k));
            m = m + 1;
        end
    end
end

