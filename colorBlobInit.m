function colorBlobInit()
    workingDirectory = uigetdir;
    copyfile(fullfile(pwd,'defaults.mat'),workingDirectory);
    allVideos = dir(fullfile(workingDirectory,'*.avi'));
    for i=1:size(allVideos,1)
        % move each video into its own folder
        [path,name,ext] = fileparts(allVideos(i).name);
        newVideoFolder = fullfile(workingDirectory,name);
        mkdir(newVideoFolder);
        newVideoPath = fullfile(workingDirectory,name,allVideos(1).name);
        movefile(fullfile(workingDirectory,allVideos(1).name),newVideoPath);
    end
    
    disp('File structure created...');
    
    S = load(fullfile(workingDirectory,'defaults.mat'));
    disp('Defaults loaded...');
    disp(S);
    
    fields = fieldnames(S);
    for i=1:size(fields,1)
       r = input(strcat('Replace "',fields{i},'"?: '));
       if(~isempty(r))
           S.(fields{i}) = r;
       end
    end
    
    save('defaults.mat', '-struct', 'S');
    disp('Defaults saved...');
    disp(S);
    
end