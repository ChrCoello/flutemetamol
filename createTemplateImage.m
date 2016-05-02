workFolder = '/data/OSLO/Flutemetamol/data';
WorkFolderContent = dir(workFolder);
OptionsRD.imageWrite = 'force';
OptionsNP.imageWrite = 'force';
%
iC = 0;
%
for iW = 3:length(WorkFolderContent),
    %
    dynamicPETfilename         = fullfile(workFolder,WorkFolderContent(iW).name,['ra' WorkFolderContent(iW).name '_Dyn_AC.hdr']);
    if exist(dynamicPETfilename,'file'),
        %
        iC = iC + 1;
        ImagePool(iC)=processImageInput(dynamicPETfilename);
        % Correcting motion in subject

        %
    end
    %
%     TT = MIT_readImage(OutImageDetails);
%     TT.file_format = 'Nifti';
    %
end