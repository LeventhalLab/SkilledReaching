function plotHullsAreas(pawHulls)
    cmap = hsv(100);
    polyAreas=zeros(size(pawHulls,2),1);
    hold on;
    for i=1:size(polyAreas,1)
        polyAreas(i)=polyarea(pawHulls{i}(:,1),pawHulls{i}(:,2));
    end
    plot(1:size(polyAreas,1),smooth(polyAreas,25),'Color',cmap(round(rand*100),:));
end