function SubjStruct = realignFramesNoReftoRefIm_dec16(dir)
%
OptionsRD.imageWrite = 'force';
OptionsRD.refFrameNo = 1;
OptionsNP.imageWrite = 'force';
%
for iW = 1:length(SubjStruct),
    %
    fprintf('\n %s \n',repmat('-',1,60));
    fprintf('\nprocessing subject %s\n',SubjStruct(iW).subjID);
    if isfield(SubjStruct,'flut'),
        %
%         if isfield(SubjStruct(iW),'mri'),
%             refImOrig = nifti2niftiPair(SubjStruct(iW).mri.Images(strcmp({SubjStruct(iW).mri.Images(:).descrip},'T1.nii')).ImageDetails,OptionsRD);
%             refIm = refImOrig; %stripSpatialInfoFromNifti(refImOrig,'T1_stripped',OptionsRD);
%         else
%             refIm = '';
%         end
        %
        idxDynAC = find(~cellfun('isempty',strfind({SubjStruct(iW).flut.Images(:).descrip},'Dyn_AC.nii')));
        %
        dynamicPETfilename_NiiPair = nifti2niftiPair(SubjStruct(iW).flut.Images(idxDynAC).ImageDetails,OptionsNP);
        %
        outFileName = fullfile(dynamicPETfilename_NiiPair.path,...
            ['ra' dynamicPETfilename_NiiPair.imageName '_nonRegMRI.nii']);
        %             if exist(outFileName,'file'),
        %                 deleteImage(outFileName);
        %             end
        if ~exist(outFileName,'file'),
            
            % Correcting motion in subject
            fprintf('\ncorrecting motion of image %s - subject %s\n',SubjStruct(iW).flut.Images(idxDynAC).descrip,SubjStruct(iW).subjID);
            
            SubjStruct(iW).flut.Images(end+1).ImageDetails = MIAKAT_realignDynamic(dynamicPETfilename_NiiPair,'',...
                '',['ra' dynamicPETfilename_NiiPair.imageName '_nonRegMRI'],OptionsRD);
            SubjStruct(iW).flut.Images(end).descrip = 'realignDynamic_nonRegMRI';
            fprintf('correcting motion in subject %s - done\n',SubjStruct(iW).subjID);
        else
            fprintf('\nskipping motion in subject %s - already done\n',SubjStruct(iW).subjID);
            SubjStruct(iW).flut.Images(end+1).ImageDetails = processImageInput(outFileName,'','',struct('calcMD5',false));
            SubjStruct(iW).flut.Images(end).descrip = 'realignDynamic_nonRegMRI';
        end
        deleteImage(dynamicPETfilename_NiiPair);
        %
        outFileNameStatic = fullfile(dynamicPETfilename_NiiPair.path,...
            ['ra' dynamicPETfilename_NiiPair.imageName '_nonRegMRI_add_f0_f4.hdr']);
        if ~exist(outFileNameStatic,'file'),%raD10030_Dyn_AC_add_f0_f4
            fprintf('\nadd image of image %s - subject %s\n',SubjStruct(iW).flut.Images(idxDynAC).descrip,SubjStruct(iW).subjID);
            SubjStruct(iW).flut.Images(end+1).ImageDetails = MIAKAT_makeIntegralImages(SubjStruct(iW).flut.Images(end).ImageDetails);
            SubjStruct(iW).flut.Images(end).descrip = 'addImage';
        else
            fprintf('\nskipping add image in subject %s - already done\n',SubjStruct(iW).subjID);
            SubjStruct(iW).flut.Images(end+1).ImageDetails = processImageInput(outFileNameStatic,'','',struct('calcMD5',false));
            SubjStruct(iW).flut.Images(end).descrip = 'addImage';
        end
        
        %
    end
    %
    %     TT = MIT_readImage(OutImageDetails);
    %     TT.file_format = 'Nifti';
    %
    %
    fprintf('\nprocessing subject %s - done\n',SubjStruct(iW).subjID);
    fprintf('\n %s \n',repmat('-',1,60));
end

fprintf('%s','Success');
