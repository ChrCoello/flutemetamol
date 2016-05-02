workFolder = '/data/OSLO/Flutemetamol/data';
WorkFolderContent = dir(workFolder);
OptionsRD.imageWrite = 'force';
OptionsNP.imageWrite = 'force';
%
for iW = 3:length(WorkFolderContent),
    %
    dynamicPETfilename         = fullfile(workFolder,WorkFolderContent(iW).name,[WorkFolderContent(iW).name '_Dyn_AC.nii']);
    if exist(dynamicPETfilename,'file'),
        %
        
        dynamicPETfilename_NiiPair = nifti2niftiPair(dynamicPETfilename,OptionsNP);
        %
        outFileName = fullfile(dynamicPETfilename_NiiPair.path,...
            ['ra' dynamicPETfilename_NiiPair.imageName '.hdr']);
        if ~exist(outFileName,'file'),
        % Correcting motion in subject
        fprintf('\ncorrecting motion in subject %s\n',WorkFolderContent(iW).name);
        [OutImageDetails,Analysis,OutImages] = MIAKAT_realignDynamic(dynamicPETfilename_NiiPair,'','','',OptionsRD);
        fprintf('correcting motion in subject %s - done\n',WorkFolderContent(iW).name);
        else
            fprintf('\nskipping motion in subject %s - already done\n',WorkFolderContent(iW).name);
        end
            
        %
    end
    %
%     TT = MIT_readImage(OutImageDetails);
%     TT.file_format = 'Nifti';
    %
end