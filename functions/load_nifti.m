function [image_data, voxDim] = load_nifti(niftiPath)
    nii = load_nii(niftiPath);
    image_data = nii.img;
    voxDim = nii.hdr.dime.pixdim(2:4);
end