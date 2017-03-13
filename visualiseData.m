function visualiseData(dataFolder)
%
[fslVer,fslDir] = getFSLVersion;
setenv('LD_LIBRARY_PATH',fullfile(fslDir,'lib'))
%
examDir = {'mri','flut'};
%
ImagesDirContent = dir(dataFolder);
ImagesDirContent = ImagesDirContent(3:end);
%
if ~exist(fullfile(dataFolder,'gatherData'),'dir'),
    mkdir(fullfile(dataFolder,'gatherData'));
end
destDir = fullfile(dataFolder,'gatherData');
%
qcStatusID = fopen(fullfile(dataFolder,'qcStatus.txt'),'w+');
%
iC = 0;
try
    for iL=1:length(ImagesDirContent);
        %
        subjID = ImagesDirContent(iL).name;
        %
        fprintf('\n %s \n',repmat('-',1,60));
        fprintf(qcStatusID,'\n %s \n',repmat('-',1,60));
        fprintf('\nvisualising subject %s\n',subjID);
        fprintf(qcStatusID,'\nQC subject %s\n',subjID);
        SubjDirContent = dir(fullfile(dataFolder,subjID));
        SubjDirContent = SubjDirContent(3:end);
        %
        [isImgDir,~]=ismember(examDir,{SubjDirContent(:).name});
        %
        if all(isImgDir),
            iC = iC+1;
            mriFile  = fullfile(dataFolder,subjID,'mri','T1.nii');
            fdgFile  = fullfile(dataFolder,subjID,'fdg',sprintf('r%s_Static_AC.img',subjID));
            flutFile = fullfile(dataFolder,subjID,'flut',sprintf('ra%s_Dyn_AC_add_f0_f4.img',subjID));
            % Check if destination files exist
            mriDestFile  = fullfile(destDir,sprintf('%s_T1.nii.gz',subjID));
            fdgDestFile  = fullfile(destDir,sprintf('%s_FDG.nii.gz',subjID));
            flutDestFile = fullfile(destDir,sprintf('%s_FLUT.nii.gz',subjID));
            
            
            if ~(exist(mriDestFile,'file') && exist(fdgDestFile,'file') && exist(flutDestFile,'file')),
                
                if exist(mriFile,'file') && exist(fdgFile,'file') && exist(flutFile,'file'),
                    system(sprintf('fslview %s %s %s',mriFile,fdgFile,flutFile));
                    userResponse = twoButtonDialog('',...
                        sprintf('Is subject %s QC passed',subjID),...
                        {'Passed','Failed'});
                    if userResponse==1,
                        qcResp = 'Passed';
                        %
                        % zip mri
                        mriZip = gzip(mriFile);
                        copyfile(mriZip{1},mriDestFile);
                        % nifti pair to nifti and zipped
                        G = MIAKAT_readImage(fdgFile);
                        G.file_format = 'Nifti';
                        OutFDG = MIAKAT_writeImage(G,'','',struct('imageWrite','force'));
                        fdgZip = gzip(OutFDG.fullImageDataFilename);
                        copyfile(fdgZip{1},fdgDestFile);
                        %
                        % nifti pair to nifti and zipped
                        G = MIAKAT_readImage(flutFile);
                        G.file_format = 'Nifti';
                        OutFLUT = MIAKAT_writeImage(G,'','',struct('imageWrite','force'));
                        flutZip = gzip(OutFLUT.fullImageDataFilename);
                        copyfile(flutZip{1},flutDestFile);
                        %
                        fprintf('\n %s \n',repmat('-',1,60));
                        fprintf('\n subject %s exported with success\n',subjID);
                        %
                    elseif userResponse==2,
                        qcResp = 'Failed';
                    else
                        qcResp = 'Undefined';
                    end
                    fprintf(qcStatusID,'\nQC status %s\n',qcResp);
                end
            else % already passed the QC
                
                qcResp = 'Passed';
                fprintf(qcStatusID,'\nQC status %s\n',qcResp);
            end
            
        else
            fprintf('\n %s \n',repmat('-',1,60));
            fprintf('\nskipping subject %s, not all three folders\n',subjID);
            fprintf(qcStatusID,'\nskipping subject %s, not all three folders\n',subjID);
        end
    end
    fprintf(qcStatusID,'\n %s \n',repmat('-',1,60));
    fprintf(qcStatusID,'\n QC fully completed \n');
catch
    fprintf(qcStatusID,'\n %s \n',repmat('-',1,60));
    fprintf(qcStatusID,'\n QC not fully completed \n');
end
fclose(qcStatusID);

