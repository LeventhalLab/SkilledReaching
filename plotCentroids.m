function plotCentroids(colorData, savePath, saveName)
    fields = fieldnames(colorData);
    maxY = 350; % an estimate, could use a min function if needed
    h = figure;
    for i=1:size(fields,1)
       %clean = cleanCentroids(colorData.(fields{i}).centroids);
       clean = colorData.(fields{i}).centroids;
       plot(clean(:,1),maxY-clean(:,2),'--','Color',fields{i});
       hold on;
       plot(clean(1,1),maxY-clean(1,2),'*','Color',fields{i});
       set(gca,'Color',[0 0 0]);
       set(gcf, 'InvertHardCopy', 'off');
    end
    print(h,'-djpeg',fullfile(savePath,strcat('plot_',saveName,'.jpg')));
    save(fullfile(savePath,strcat('figure_',saveName,'.fig')));
    close;
end