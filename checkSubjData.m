function [SubjStruct]=checkSubjData(subjFolder)
% This function would check each subject folder if content is there and in
% good shape.
% ----------------------------------------------------------
% ----------------------------------------------------------

%
examDir = {'mri','fdg','flut'};

% List subject content
SubjectsDirContent = dir(subjFolder);
SubjectsDirContent = SubjectsDirContent(3:end);

iC=0;
% First Check : three folders (mri/ flut/ fdg/) in each subject folder
for iL=1:length(SubjectsDirContent);
    if SubjectsDirContent(iL).isdir,
        iC = iC+1;
        DynScanContent(iC) = SubjectsDirContent(iL);
    end
end
for iLL = 1:length(DynScanContent),
    %
    SubjDirContent = dir(fullfile(subjFolder,DynScanContent(iLL).name));
    %
    [isImgDir,idxDir]=ismember(examDir,{SubjDirContent(:).name});
    %
    if all(isImgDir),
        fprintf('\n - Subj %s does have the three folders',DynScanContent(iLL).name);
        SubjStruct(iLL).subjID = DynScanContent(iLL).name;
        for iF = 1:3,
            ExamDirContent = dir(fullfile(subjFolder,DynScanContent(iLL).name,examDir{iF},'*.nii'));
            if ~isempty(ExamDirContent),
                fprintf('');
                for iD = 1:length(ExamDirContent);
                SubjStruct(iLL).(examDir{iF}).Images(iD).ImageDetails = processImageInput(fullfile(subjFolder,...
                    DynScanContent(iLL).name,examDir{iF},ExamDirContent(iD).name));
                SubjStruct(iLL).(examDir{iF}).Images(iD).descrip    = ExamDirContent(iD).name;
                
                end
            else
                fprintf('');
            end
            MatDirContent = dir(fullfile(subjFolder,DynScanContent(iLL).name,examDir{iF},'*.mat'));
            if ~isempty(ExamDirContent),
                fprintf('');
                for iD = 1:length(MatDirContent);
                SubjStruct(iLL).(examDir{iF}).DicomDetails(iD).filename = fullfile(subjFolder,...
                    DynScanContent(iLL).name,examDir{iF},MatDirContent(iD).name);
                SubjStruct(iLL).(examDir{iF}).DicomDetails(iD).Content  = load(SubjStruct(iLL).(examDir{iF}).DicomDetails(iD).filename);
                
                end
            else
                fprintf('');
            end
                
        end
        fprintf('\n - Subj %s done',DynScanContent(iLL).name);
        
    else
        fprintf('\n Subj %s does not have the three folders',DynScanContent(iLL).name);
    end
    
end




