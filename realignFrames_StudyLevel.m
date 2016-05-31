function realignFrames_StudyLevel(SubjStruct)
%
OptionsRD.imageWrite = 'force';
OptionsRD.refFrameNo = 1;
OptionsNP.imageWrite = 'force';
%
for iW = 1:length(SubjStruct),
    %
    if isfield(SubjStruct,'flut'),
        %
        if isfield(SubjStruct(iW),'mri'),
            refImOrig = nifti2niftiPair(SubjStruct(iW).mri.Images(strcmp({SubjStruct(iW).mri.Images(:).descrip},'T1.nii')).ImageDetails,OptionsRD);
            refIm = refImOrig; %stripSpatialInfoFromNifti(refImOrig,'T1_stripped',OptionsRD);
        else
            refIm = '';
        end
        %
        for iIm = 1:length(SubjStruct(iW).flut.Images)
            dynamicPETfilename_NiiPair = nifti2niftiPair(SubjStruct(iW).flut.Images(iIm).ImageDetails,OptionsNP);
            %
            outFileName = fullfile(dynamicPETfilename_NiiPair.path,...
                ['ra' dynamicPETfilename_NiiPair.imageName '.hdr']);
            deleteImage(outFileName);
            if ~exist(outFileName,'file'),
                
                % Correcting motion in subject
                fprintf('\ncorrecting motion in subject %s\n',SubjStruct(iW).subjID);
                
                SubjStruct(iW).flut.Images(end+1).ImageDetails = MIAKAT_realignDynamic(dynamicPETfilename_NiiPair,refIm,'','',OptionsRD);
                SubjStruct(iW).flut.Images(end).descrip = 'realignDynamic';
                fprintf('correcting motion in subject %s - done\n',SubjStruct(iW).subjID);
            else
                fprintf('\nskipping motion in subject %s - already done\n',SubjStruct(iW).subjID);
            end
            deleteImage(dynamicPETfilename_NiiPair);
            %
            SubjStruct(iW).flut.Images(end+1).ImageDetails = MIAKAT_makeIntegralImages(SubjStruct(iW).flut.Images(end).ImageDetails);
            SubjStruct(iW).flut.Images(end).descrip = 'addImage';
        end
        
        %
    end
    %
    %     TT = MIT_readImage(OutImageDetails);
    %     TT.file_format = 'Nifti';
    %
end

fprintf('%s','Success');
