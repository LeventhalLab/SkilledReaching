vidFiles = dir('*.avi');

for ii = 1 : length(vidFiles)
    
    old_vidName = vidFiles(ii).name;
    if strcmp(old_vidName(1:2),'R0')
        new_vidName = old_vidName(7:end);
        movefile(old_vidName,new_vidName);
    end
end