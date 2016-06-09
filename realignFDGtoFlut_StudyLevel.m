function SubjStruct = realignFDGtoFlut_StudyLevel(SubjStruct)
%
OptionsRD.imageWrite = 'force';

%
for iW = 1:length(SubjStruct),
    %
    fprintf('\n %s \n',repmat('-',1,60));
    fprintf('\nprocessing subject %s\n',SubjStruct(iW).subjID);
    
    if isfield(SubjStruct(iW),'flut') & isfield(SubjStruct(iW),'fdg'),
        
        if exist(SubjStruct(iW).fdg.Images(~cellfun('isempty',strfind({SubjStruct(iW).fdg.Images(:).descrip},'Static_AC.nii'))).ImageDetails.fullImageDataFilename,'file'),
            
            fdgNiiPair = nifti2niftiPair(SubjStruct(iW).fdg.Images(~cellfun('isempty',strfind({SubjStruct(iW).fdg.Images(:).descrip},'Static_AC.nii'))).ImageDetails,OptionsRD);
        else
            fprintf('\nmissing fdg image for subject %s\n',SubjStruct(iW).subjID);
            continue
        end
        if any(strcmp('addImage',{SubjStruct(iW).flut.Images(:).descrip})),
            flutNiiPair = SubjStruct(iW).flut.Images(strcmp('addImage',{SubjStruct(iW).flut.Images(:).descrip})).ImageDetails;
        else
            if exist(SubjStruct(iW).flut.Images(~cellfun('isempty',strfind({SubjStruct(iW).flut.Images(:).descrip},'_AC_add_f0_f4.hdr'))).ImageDetails.fullImageDataFilename,'file'),
                
                flutNiiPair = processImageInput(SubjStruct(iW).flut.Images(~cellfun('isempty',strfind({SubjStruct(iW).flut.Images(:).descrip},'_AC_add_f0_f4.hdr'))).ImageDetails,'','',struct('calcMD5','false'));
            else
                FlutDirContent = dir(SubjStruct(iW).flut.Images(1).ImageDetails.path);
                idxStaticFlt = find(~cellfun('isempty',strfind({FlutDirContent(:).name},'_AC_add_f0_f4.hdr')));
                if ~isempty(idxStaticFlt),
                flutNiiPair = processImageInput(fullfile(SubjStruct(iW).flut.Images(1).ImageDetails.path,FlutDirContent(idxStaticFlt).name),'','',struct('calcMD5','false'));
                else
                fprintf('\nmissing flut staticimage for subject %s\n',SubjStruct(iW).subjID);
                continue
                end
            end
        end
        %
        
        %
        outFileName = ['r' fdgNiiPair.imageName];
        if ~exist(fullfile(fdgNiiPair.path,outFileName),'file'),
            
            % Correcting motion in subject
            fprintf('\ncoregistration FDG to FLUT of image %s - subject %s\n',fdgNiiPair.imageName,SubjStruct(iW).subjID);
            
            SubjStruct(iW).flut.Images(end+1).ImageDetails = MIAKAT_registerImage(fdgNiiPair,flutNiiPair,'','','',outFileName,OptionsRD);
            SubjStruct(iW).flut.Images(end).descrip = 'registerStatic';
            fprintf('\ncoregistration FDG to FLUT of image %s - subject %s - done\n',fdgNiiPair.imageName,SubjStruct(iW).subjID);
        else
            fprintf('\nskipping coregistration FDG to FLUT for subject %s - already done\n',SubjStruct(iW).subjID);
            SubjStruct(iW).flut.Images(end+1).ImageDetails = processImageInput(outFileName,'','',struct('calcMD5',false));
            SubjStruct(iW).flut.Images(end).descrip = 'registerStatic';
        end
        deleteImage(fdgNiiPair);
        %
        %
    else
        fprintf('\nmissing flut or fdg folder for subject %s\n',SubjStruct(iW).subjID);
    end
    %
    %
    fprintf('\nprocessing subject %s - done\n',SubjStruct(iW).subjID);
    fprintf('\n %s \n',repmat('-',1,60));
end

fprintf('%s','Success');
