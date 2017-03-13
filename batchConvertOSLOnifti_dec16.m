function batchConvertOSLOnifti_dec16(imagesDirFlut)
% This function would prepare the subject specific folder preivous to analysis
% It will : 
% - transform Flut DICOM to Nifti files and copy them in the subject specific folder FLUT
% ----------------------------------------------------------
% ----------------------------------------------------------

% if ~exist(fullfile(imagesDir,'NiftiConversion'),'dir'),
%     mkdir(imagesDir,'NiftiConversion');
% end
conversionFolder = '/data/OSLO/Flutemetamol/dataDec16';%fullfile(imagesDir,'NiftiConversion');

ImConvertOptions.OutputFiles.logTextFilename = '';
% ImConvertOptions.OutputFiles.filenamesStem = '';
ImConvertOptions.OutputFiles.filenamesPrefix = '';
ImConvertOptions.ConvOptions.SourceData.SourceFormat.formatName = 'Dicom2D';
ImConvertOptions.ConvOptions.SourceData.SourceFormat.formatNo = 1;
ImConvertOptions.ConvOptions.SourceData.processDicomBlind = true;
ImConvertOptions.ConvOptions.OutputDims.dimSpec = 'auto';
ImConvertOptions.ConvOptions.OutputDims.nDims = 4;
ImConvertOptions.ConvOptions.OutputDims.dimensions = [NaN NaN NaN NaN];
ImConvertOptions.ConvOptions.Orientation.flipX = false;
ImConvertOptions.ConvOptions.Orientation.flipY = true;
ImConvertOptions.ConvOptions.Orientation.flipZ = true;
ImConvertOptions.ConvOptions.Orientation.flipT = false;
ImConvertOptions.ConvOptions.Orientation.resliceCor = false;
ImConvertOptions.ConvOptions.Orientation.resliceSag = false;
ImConvertOptions.ConvOptions.Orientation.resliceTra = false;
ImConvertOptions.ConvOptions.outputFormat = 'Nifti';
ImConvertOptions.ConvConfig = fileConversionConfig;
ImConvertOptions.LogOptions.parentStructName = '';
ImConvertOptions.LogOptions.unable2Display = '<Unable to display>';
ImConvertOptions.LogOptions.arrayIndent = 4;
ImConvertOptions.LogOptions.maxLineWidth = 80;
ImConvertOptions.LogOptions.lineSep = sprintf('%s%s\n','%',repmat('-',[1,50]));
ImConvertOptions.LogOptions.sectionTitle = '';

% ---------------------------------------------------
% ANCtemplate = MIAKAT_readANCfile(ancTemplateFile);
% startingDir = pwd;

% cd(imagesDir);
% patientBirthDate = [];
% clear MasterV
ImagesDirContent = dir(imagesDirFlut);
iC = 0;
for iL=1:length(ImagesDirContent);
    if ImagesDirContent(iL).isdir & logical(strfind(ImagesDirContent(iL).name,'FlutPET')),
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
    subjectFolder = fullfile(conversionFolder,subjName,'flut');
    if ~exist(subjectFolder,'dir'),
        mkdir(subjectFolder);
    end
    %
    SubjDirContent = dir(fullfile(imagesDirFlut,DynScanContent(iLL).name,'SCANS'));
    SubjDirContent(1:2) = [];
    scanDir = fullfile(imagesDirFlut,DynScanContent(iLL).name,'SCANS');
    %
    for iK = 1:length(SubjDirContent),
        if SubjDirContent(iK).isdir,
            DicomFilesACContent = dir(fullfile(scanDir,SubjDirContent(iK).name,'DICOM','*.dcm'));
            if isempty(DicomFilesACContent),
                error('wdfasdg');
            end
            if length({DicomFilesACContent(:).name})>10,
            ImConvertOptions.InputFiles.filesPath  = fullfile(scanDir,SubjDirContent(iK).name,'DICOM');
            ImConvertOptions.OutputFiles.filesPath = subjectFolder;
            ImConvertOptions.InputFiles.filenames       = {DicomFilesACContent(:).name};
            ImConvertOptions.OutputFiles.filenamesStem  = sprintf('%s_serie%s',subjName,SubjDirContent(iK).name);
            
            %
            fprintf('\nChecking Dicom headers for AC dynamic scans for subj %s\n',subjName);
            %
            [ImConvertOptions.InputFiles,consistent,cancelled,DicomDetails] = ...
                readAndCheckDicomHeaders(ImConvertOptions.InputFiles);
            save(fullfile(ImConvertOptions.OutputFiles.filesPath,sprintf('DicomDetailsAC_serie%s.mat',SubjDirContent(iK).name)),'DicomDetails');
            %
            if ~consistent,
                error('DICOM files of folder % not consitent',ImConvertOptions.InputFiles.filesPath);
            end
            %
            if ~(exist(fullfile(ImConvertOptions.OutputFiles.filesPath,'DicomDetailsAC.mat'),'file') &&...
                    exist(fullfile(ImConvertOptions.OutputFiles.filesPath,...
                    [ImConvertOptions.OutputFiles.filenamesStem '.nii']),'file')),
                %
                strSer = strrep(DicomDetails.seriesDescriptions{1},' ','');
                fprintf('\nConverting subj %s serie %s , dynamic AC from Dicom to Nifti\n',subjName,strSer);
                ImConvertOptions.ConvOptions.OutputDims.dimensions = DicomDetails.seriesImageDims;
                imConvertLinuxBox(ImConvertOptions);
                %
                %Move image
                moveImage(fullfile(ImConvertOptions.InputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '.nii']),...
                    ImConvertOptions.OutputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '_' strSer '.nii'],true);
            else
                fprintf('\nSkipping subj %s AC\n',subjName);
            end
%             %
            end
        end
        
        
        
        
    end
    
end




