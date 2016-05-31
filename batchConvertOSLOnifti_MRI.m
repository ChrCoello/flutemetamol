function batchConvertOSLOnifti_FDG(imagesDirMRI)
% This function would prepare the subject specific folder preivous to analysis
% 
% - copy the T1.mgz and Freesurfer segmentations to the subject specific folder MRI
% ----------------------------------------------------------
% ----------------------------------------------------------

conversionFolder = '/data/OSLO/Flutemetamol/data';%fullfile(imagesDir,'NiftiConversion');


% ---------------------------------------------------
% ANCtemplate = MIAKAT_readANCfile(ancTemplateFile);
% startingDir = pwd;

% cd(imagesDir);
% patientBirthDate = [];
% clear MasterV
ImagesDirContent = dir(imagesDirMRI);
iC = 0;
for iL=1:length(ImagesDirContent);
    if ImagesDirContent(iL).isdir & logical(strfind(ImagesDirContent(iL).name,'D')),
        iC = iC+1;
        DynScanContent(iC) = ImagesDirContent(iL);
    end
end
for iLL = 1:length(DynScanContent),
    %
    idxUndr  = strfind(DynScanContent(iLL).name,'-');
    subjName = DynScanContent(iLL).name(1:idxUndr-1);
    if ~exist(fullfile(conversionFolder,subjName),'dir'),
        mkdir(conversionFolder,subjName);
    end
    subjectFolder = fullfile(conversionFolder,subjName,'mri');
    if ~exist(subjectFolder,'dir'),
        mkdir(subjectFolder);
    end
    %
    SubjDirContent = dir(fullfile(imagesDirMRI,DynScanContent(iLL).name));
    %
    for iK = 1:length(SubjDirContent),
        if SubjDirContent(iK).isdir & logical(strfind(SubjDirContent(iK).name,'mri')),
            
            DicomFilesACContent = dir(fullfile(imagesDirMRI,...
                DynScanContent(iLL).name,SubjDirContent(iK).name));
            if isempty(DicomFilesACContent),
                error('wdfasdg');
            end
            fprintf('\nCopying subj %s MRI\n',subjName);
            % Copy all files
            copyfile(fullfile(imagesDirMRI,DynScanContent(iLL).name,...
                    SubjDirContent(iK).name,'*'),subjectFolder,'f')
            % Convert the ones intersting
            intVols    = {'T1','brain','aparc+aseg'};
            for iF = 1:length(intVols),
            if exist(fullfile(subjectFolder,[intVols{iF} '.mgz']),'file'),
                fprintf('\nConverting subj %s - %s\n',subjName,[intVols{iF} '.mgz']);
            cmdMriConv = sprintf('mri_convert -it mgz -ot nii --out_orientation LAS %s %s',...
                fullfile(subjectFolder,[intVols{iF} '.mgz']),...
                fullfile(subjectFolder,[intVols{iF} '.nii']));
            system(cmdMriConv);
            end
            end
            %
        end

        
    end
    
end




