function batchConvertOSLOnifti_FDG(imagesDirFDG)
% This function would prepare the subject specific folder preivous to analysis
% It will : 
% - transform FDG DICOM to Nifti files and copy them in the subject specific folder FDG
% ----------------------------------------------------------
% ----------------------------------------------------------

% if ~exist(fullfile(imagesDir,'NiftiConversion'),'dir'),
%     mkdir(imagesDir,'NiftiConversion');
% end
conversionFolder = '/data/OSLO/Flutemetamol/data';%fullfile(imagesDir,'NiftiConversion');

ImConvertOptions.OutputFiles.logTextFilename = '';
% ImConvertOptions.OutputFiles.filenamesStem = '';
ImConvertOptions.OutputFiles.filenamesPrefix = '';
ImConvertOptions.ConvOptions.SourceData.SourceFormat.formatName = 'Dicom2D';
ImConvertOptions.ConvOptions.SourceData.SourceFormat.formatNo = 1;
ImConvertOptions.ConvOptions.SourceData.processDicomBlind = true;
ImConvertOptions.ConvOptions.OutputDims.dimSpec = 'auto';
ImConvertOptions.ConvOptions.OutputDims.nDims = 3;
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
ImagesDirContent = dir(imagesDirFDG);
iC = 0;
for iL=1:length(ImagesDirContent);
    if ImagesDirContent(iL).isdir & logical(strfind(ImagesDirContent(iL).name,'Discovery690')),
        iC = iC+1;
        DynScanContent(iC) = ImagesDirContent(iL);
    end
end
for iLL = 1:length(DynScanContent),
    %
    idxUndr  = strfind(DynScanContent(iLL).name,'_');
    subjName = DynScanContent(iLL).name(1:idxUndr-1);
    if ~exist(fullfile(conversionFolder,subjName),'dir'),
        mkdir(conversionFolder,subjName);
    end
    subjectFolder = fullfile(conversionFolder,subjName,'fdg');
    if ~exist(subjectFolder,'dir'),
        mkdir(subjectFolder);
    else
        system(sprintf('rm -fR %s',subjectFolder));
        mkdir(subjectFolder);
    end
    %
    SubjDirContent = dir(fullfile(imagesDirFDG,DynScanContent(iLL).name));
    %
    for iK = 1:length(SubjDirContent),
        if SubjDirContent(iK).isdir & logical(strfind(SubjDirContent(iK).name,'PET_3D_AC')),
            DicomFilesACContent = dir(fullfile(imagesDirFDG,...
                DynScanContent(iLL).name,SubjDirContent(iK).name,'*.dcm'));
            if isempty(DicomFilesACContent),
                error('wdfasdg');
            end
            
            ImConvertOptions.InputFiles.filesPath  = fullfile(imagesDirFDG,...
                DynScanContent(iLL).name,SubjDirContent(iK).name);
            ImConvertOptions.OutputFiles.filesPath = subjectFolder;
            ImConvertOptions.InputFiles.filenames       = {DicomFilesACContent(:).name};
            ImConvertOptions.OutputFiles.filenamesStem  = sprintf('%s_Static_AC',subjName);
            
            %
            fprintf('\nChecking Dicom headers for AC dynamic scans for subj %s\n',subjName);
            %
            [ImConvertOptions.InputFiles,consistent,cancelled,DicomDetails] = ...
                readAndCheckDicomHeaders(ImConvertOptions.InputFiles);
            save(fullfile(ImConvertOptions.OutputFiles.filesPath,'DicomDetailsAC.mat'),'DicomDetails');
            %
            if ~consistent,
                error('DICOM files of folder % not consitent',ImConvertOptions.InputFiles.filesPath);
            end
            %
            if ~(exist(fullfile(ImConvertOptions.OutputFiles.filesPath,'DicomDetailsAC.mat'),'file') &&...
                    exist(fullfile(ImConvertOptions.OutputFiles.filesPath,...
                    [ImConvertOptions.OutputFiles.filenamesStem '.nii']),'file')),
                %
                fprintf('\nConverting subj %s , dynamic AC from Dicom to Nifti\n',subjName);
                ImConvertOptions.ConvOptions.OutputDims.dimensions = DicomDetails.seriesImageDims;
                imConvertLinuxBox(ImConvertOptions);
                %
                %Move image
                moveImage(fullfile(ImConvertOptions.InputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '.nii']),...
                    ImConvertOptions.OutputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '.nii'],true);
            else
                fprintf('\nSkipping subj %s AC\n',subjName);
            end
            %
        end
        
        
        
        % for fileNo = 1:length(DicomFilesDir)
        %     disp(sprintf('(%g%s%g)',fileNo,'/',length(EcatFilesDir)))
        %     ecatFilename = EcatFilesDir(fileNo).name;
        %     [ecatFilePath,ecatFileNameStub,ecatExtn] = fileparts(ecatFilename);
        %     % Read header.
        %     [V,frame_start,frame_end] = Read_ecat7_header(ecatFilename);
        %     % Make .anc file.
        %     ANCdata = ANCtemplate;
        %
        %     ANCdata.Info.Tracer.isotope = parseIsotopeName(V(1).mh.ISOTOPE_NAME);
        %     switch lower(V(1).mh.PATIENT_SEX)
        %         case 'm'
        %             gender = 'male';
        %         case 'f'
        %             gender = 'female';
        %         otherwise
        %             gender = 'n/s';
        %     end
        % %     ANCdata.Info.SubjectData.gender = gender;
        % %     ANCdata.Info.SubjectData.bodyWeight = V(1).mh.PATIENT_WEIGHT;
        % %     ANCdata.Info.SubjectData.bodyWeightUnits = 'kg';
        %
        %     ANCdata.Radiochem.injectedRadioactivity = V(1).mh.DOSAGE*1e-6;
        %     ANCdata.Radiochem.injectedRadioactivityUnits = 'MBq';
        %     ANCdata.Time.FrameTimes.values = [frame_start(:) frame_end(:)];
        %
        %     scanStartNum = V(1).mh.SCAN_START_TIME/(3600*24)+datenum('Jan-1-1970 00:00:00');
        %     ANCdata.Time.scanDate = datestr(scanStartNum,'dd mmm yyyy');
        %     ANCdata.Time.scanDateUnits = 'dd Mmm yyyy';
        %     ANCdata.Time.scanStart = datestr(scanStartNum,'HH:MM:SS');
        %
        %     ANCdata.Time.scanStartUnits = 'hh:mm:ss';
        %     injectionStartNum = V(1).mh.DOSE_START_TIME/(3600*24)+datenum('Jan-1-1970 00:00:00');
        %     ANCdata.Time.injectionStart = datestr(injectionStartNum,'HH:MM:SS');
        %     ANCdata.Time.injectionStartUnits = 'hh:mm:ss';
        %
        %     subjectBithdateNum = V(1).mh.PATIENT_BIRTH_DATE/(3600*24)+datenum('Jan-1-1970 00:00:00');
        %     nYearsOldAtScan = round((scanStartNum-subjectBithdateNum)/365);
        %     ANCdata.Info.SubjectData.age = nYearsOldAtScan;
        %     ANCdata.Info.SubjectData.ageUnits = 'years';
        %
        %     ANCdata.Info.subject = V(1).mh.PATIENT_ID;
        %     ANCdata.Info.visit = datestr(scanStartNum,'dd-mm-yyyy');
        %     ANCdata.Info.examination = 'PET';
        %
        %     ANCdata.revHistory = {};
        %     MIAKAT_writeANCfile(ANCdata,fullfile(imagesDir,[ecatFileNameStub '.anc']));
        
        
        
        
        if SubjDirContent(iK).isdir & logical(strfind(SubjDirContent(iK).name,'PET_3D_NAC')),
            DicomFilesACContent = dir(fullfile(imagesDirFDG,...
                DynScanContent(iLL).name,SubjDirContent(iK).name,'*.dcm'));
            if isempty(DicomFilesACContent),
                error('wdfasdg');
            end
            
            ImConvertOptions.InputFiles.filesPath  = fullfile(imagesDirFDG,...
                DynScanContent(iLL).name,SubjDirContent(iK).name);
            ImConvertOptions.OutputFiles.filesPath = subjectFolder;
            ImConvertOptions.InputFiles.filenames       = {DicomFilesACContent(:).name};
            ImConvertOptions.OutputFiles.filenamesStem  = sprintf('%s_Static_NAC',subjName);
            
            if ~(exist(fullfile(ImConvertOptions.OutputFiles.filesPath,'DicomDetailsNAC.mat'),'file') &&...
                    exist(fullfile(ImConvertOptions.OutputFiles.filesPath,...
                    [ImConvertOptions.OutputFiles.filenamesStem '.nii']),'file')),
            fprintf('\nChecking Dicom headers for NAC dynamic scans for subj %s\n',subjName);
            %
            [ImConvertOptions.InputFiles,consistent,cancelled,DicomDetails] = ...
                readAndCheckDicomHeaders(ImConvertOptions.InputFiles);
            save(fullfile(ImConvertOptions.OutputFiles.filesPath,'DicomDetailsNAC.mat'),'DicomDetails');
            %
            if ~consistent,
                error('DICOM files of folder % not consitent',ImConvertOptions.InputFiles.filesPath);
            end
            %
            %
            fprintf('\nConverting subj %s , dynamic NAC from Dicom to Nifti\n',subjName);
            ImConvertOptions.ConvOptions.OutputDims.dimensions = DicomDetails.seriesImageDims;
            imConvertLinuxBox(ImConvertOptions);
            %
            %Move image
            moveImage(fullfile(ImConvertOptions.InputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '.nii']),...
                ImConvertOptions.OutputFiles.filesPath,[ImConvertOptions.OutputFiles.filenamesStem '.nii'],true);
            else
                fprintf('\nSkipping subj %s NAC\n',subjName);
            end
        end
        
    end
    
end




