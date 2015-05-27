CSVfile = dir('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching\R0027\R0027-processed\R0027_20140513a\*.csv');
cd('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching\R0027\R0027-processed\R0027_20140513a');
fileID = fopen(CSVfile(2).name,'r');
formatSpec = '%d %*d %d %s';

% k = 1;
% while ~feof(fileID)
%     ManualStartFrameData = fscanf(fileID,'%s %s %s %s');
% %     if k == 1;
% %         ManualStartFrameData(k,:) = fscanf(fileID,'%s %s %s %s');
% %         k = k+1;
% %     else
% %         ManualStartFrameData(k,:) = fscanf(fileID,'%d %d %d %d');
% %         k = k+1;
% %     end
% end
% fclose(fileID);
% ManualStartFrameData

% ManualStartFrameData = textscan(fileID,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',1,'TreatAsEmpty','','EmptyValue',NaN);
ManualStartFrame = zeros(length(RatData(27).VideoFiles),1);
AutomaticTriggerFrame = zeros(length(RatData(27).VideoFiles),1);
AutomaticPeakFrame = zeros(length(RatData(27).VideoFiles),1);
ROI_Used = cell(length(RatData(27).VideoFiles),1);

for VideoFilesUnderAnalysis = 1:length(RatData(27).VideoFiles);
    ManualStartFrame(VideoFilesUnderAnalysis) = RatData(27).VideoFiles(VideoFilesUnderAnalysis).ManualStartFrame;
    if isnan(ManualStartFrame(VideoFilesUnderAnalysis));
        ManualStartFrame(VideoFilesUnderAnalysis) = 0;
    end
    AutomaticTriggerFrame(VideoFilesUnderAnalysis) = RatData(27).VideoFiles(VideoFilesUnderAnalysis).AutomaticTriggerFrame;
    AutomaticPeakFrame(VideoFilesUnderAnalysis) = RatData(27).VideoFiles(VideoFilesUnderAnalysis).AutomaticPeakFrame;
    if isnan(AutomaticPeakFrame(VideoFilesUnderAnalysis));
        AutomaticPeakFrame(VideoFilesUnderAnalysis) = 0;
    end
    ROI_Used{VideoFilesUnderAnalysis} = RatData(27).VideoFiles(VideoFilesUnderAnalysis).ROI_Used;
end

% T = table(ManualStartFrame,AutomaticTriggerFrameRevis,AutomaticPeakFrameRevis,ROI_Used);
% filename = 'R0027_Start_Frame_Data.xlsx';
% writetable(T,filename,'Sheet',2);

CSVfile = textscan(fileID,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',1);
DomPawOrNo = cell(CSVfile{1,2});
cd('C:\Users\Administrator\Documents\GitHub\SkilledReaching');

% i = [5:10,12:13,15,17,19,21:22,24,28:29,31:32,34,36:38,40:47];
pawpref = cell(length(VideoFilesUnderAnalysis),1);
ThreshInt = (((300-200)/10));
TriggerFrame = zeros(length(VideoFilesUnderAnalysis),ThreshInt);
PeakFrame = zeros(length(VideoFilesUnderAnalysis),ThreshInt);

FirstDiffThresh = 210:ThreshInt:300; 
for VideoFilesUnderAnalysis = 1:length(RatData(27).VideoFiles);
    n = 1;
    if ischar(DomPawOrNo{VideoFilesUnderAnalysis}) && (isempty(DomPawOrNo{VideoFilesUnderAnalysis})==0);
        if strcmp(DomPawOrNo{VideoFilesUnderAnalysis},'non-dominant paw') == 1;
            pawpref{VideoFilesUnderAnalysis} = 'left';
        else
            pawpref{VideoFilesUnderAnalysis} = 'right';
        end
    else
        pawpref{VideoFilesUnderAnalysis} = 'right';
    end
    % video = RatData(27).VideoFiles(iVideoFileNum).Object;
    video = fullfile(RatData(27).DateFolders,RatData(27).VideoFiles(VideoFilesUnderAnalysis).name);
    fprintf('Working on video %s\n',RatData(27).VideoFiles(VideoFilesUnderAnalysis).name);
    video = VideoReader(video);
    %     lastFrame = read(video, inf);
    %     numFrames = video.NumberOfFrames;
    for FirstDiffThreshNum = 1:ThreshInt;
        fprintf('Working on threshold #%d of %d\n',FirstDiffThreshNum,ThreshInt);
        [TriggerFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum),PeakFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)] = identifyTriggerFrame(video,pawpref{VideoFilesUnderAnalysis},'trigger_roi',ROI_Used{VideoFilesUnderAnalysis},'firstdiffthreshold',FirstDiffThresh(n));
        n = n+1;
    end
end

VideoAccForFirstDiffThresh = zeros(length(VideoFilesUnderAnalysis),ThreshInt);
TrigFrameVidAcc = zeros(length(VideoFilesUnderAnalysis),ThreshInt);
PeakFrameVidAcc = zeros(length(VideoFilesUnderAnalysis),ThreshInt);

for VideoFilesUnderAnalysis = 1:length(VideoFilesUnderAnalysis);
    for FirstDiffThreshNum = 1:ThreshInt;
        if abs(TriggerFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))> 5 && abs(PeakFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))> 5;
            VideoAccForFirstDiffThresh(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 0;
            TrigFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 0;
            PeakFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 0;
        elseif abs(TriggerFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))< 5 && abs(PeakFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))< 5; 
            VideoAccForFirstDiffThresh(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 1;
            TrigFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 1;
            PeakFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 1;
        elseif abs(TriggerFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))< 5 && abs(PeakFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))> 5; 
            VideoAccForFirstDiffThresh(VideoFilesUnderAnalysis,FirstDiffThreshNum) = .5;
            TrigFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 1;
            PeakFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 0;
        elseif abs(TriggerFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))> 5 && abs(PeakFrame(VideoFilesUnderAnalysis,FirstDiffThreshNum)-ManualStartFrame(VideoFilesUnderAnalysis))< 5; 
            VideoAccForFirstDiffThresh(VideoFilesUnderAnalysis,FirstDiffThreshNum) = .5;
            TrigFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 0;
            PeakFrameVidAcc(VideoFilesUnderAnalysis,FirstDiffThreshNum) = 1;
        end        
    end
end

MeanAccForFirstDiffThresh = mean(VideoAccForFirstDiffThresh,1).*100;
MeanTrigFrameAcc = mean(TrigFrameVidAcc,1).*100;
MeanPeakFrameAcc = mean(PeakFrameVidAcc,1).*100;

DiffMeanAccForFirstDiffThresh = diff(MeanAccForFirstDiffThresh);
DiffMeanTrigFrameAcc = diff(MeanTrigFrameAcc);
DiffMeanPeakFrameAcc = diff(MeanPeakFrameAcc);

figure;
plot(FirstDiffThresh,MeanAccForFirstDiffThresh,...
    FirstDiffThresh,MeanTrigFrameAcc,...
    FirstDiffThresh,MeanPeakFrameAcc,...
    FirstDiffThresh(:,1:length(DiffMeanAccForFirstDiffThresh)),DiffMeanAccForFirstDiffThresh,...
    FirstDiffThresh(:,1:length(DiffMeanTrigFrameAcc)),DiffMeanTrigFrameAcc,...
    FirstDiffThresh(:,1:length(DiffMeanPeakFrameAcc)),DiffMeanPeakFrameAcc);
legend('Mean Acc. for Thresholds',...
    'Mean Trig. Frame Acc. for Thresholds',...
    'Diff. of Mean Peak Frame Acc. for Thresholds',...
    'Diff of Mean Acc. for Thresholds',...
    'Diff of Mean Trig. Frame Acc. for Thresholds',...
    'Diff of Mean Peak Frame Acc. for Thresholds');

T = table(ManualStartFrame,AutomaticTriggerFrame,AutomaticPeakFrame,...
    TriggerFrame(:,1),PeakFrame(:,1),...
    TriggerFrame(:,2),PeakFrame(:,2),...
    TriggerFrame(:,3),PeakFrame(:,3),...
    TriggerFrame(:,4),PeakFrame(:,4),...
    TriggerFrame(:,5),PeakFrame(:,5),...
    TriggerFrame(:,6),PeakFrame(:,6),...
    TriggerFrame(:,7),PeakFrame(:,7),...
    TriggerFrame(:,8),PeakFrame(:,8),...
    TriggerFrame(:,9),PeakFrame(:,9),...
    TriggerFrame(:,10),PeakFrame(:,10));
Z = table(MeanAccForFirstDiffThresh,...
    MeanTrigFrameAcc,...
    MeanPeakFrameAcc,...
    DiffMeanAccForFirstDiffThresh,...
    DiffMeanTrigFrameAcc,...
    DiffMeanPeakFrameAcc);
filename = 'R0027_Start_Frame_Data_With_Highlights.xlsx';
writetable(T,filename,'Sheet',2);
writetable(Z,filename,'Sheet',3);