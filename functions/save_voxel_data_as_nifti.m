%optional 
function save_voxel_data_as_nifti(voxData, outputFileName)
    % Create a new NIfTI structure for the voxel data
    nii = make_nii(voxData(:,:,:,1));
    % Save the NIfTI file
    save_nii(nii, outputFileName);
end