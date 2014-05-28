function runCheckData()

directories = {'\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0026';
               '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0027';
               '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0028';
               '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029';
               '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030'};

    for i = 1:length(directories)
        fprintf(1,'Checking %s ...\n',directories{i});
        checkData(directories{i});
    end

end