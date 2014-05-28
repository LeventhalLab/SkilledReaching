
% folder = {'\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140505a';
%     '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140506a';
%     '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140507a';
%           '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140508a';
%           '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140509a';
%           '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140512a';
%           '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140513a';
%           '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140514a'};
% % 
folder = {'\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140505a';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140506a';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140507a';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140508a';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140509c';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140512a';
          '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140513a'};

figure()
hold on
shift = zeros(size(folder)); stdev = zeros(size(folder));
for i = 1:length(folder)
	[shift(i),stdev(i)] = findShift(folder{i});
    
end
dates = [0505, 0506, 0507, 0508, 0509, 0512, 0513];
plot(dates,shift,'k*-');
plot(dates,shift+stdev,'k--',dates,shift-stdev,'k--');
title('R29 mean paw crossing frame');
xlabel('Date'); ylabel('Frame');