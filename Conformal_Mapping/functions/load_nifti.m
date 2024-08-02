function [image_data_bin, voxDim, size_image] = load_nifti(niftiPath)
    nii = load_nii(niftiPath);
    image_data = nii.img;
    voxDim = nii.hdr.dime.pixdim(2:4);
    size_image = size(nii.img);
    image_data_bin = image_data > 0;
end