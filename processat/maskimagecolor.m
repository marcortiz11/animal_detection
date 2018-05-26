function [colormask] = maskimagecolor(img,mask)
    m = uint8(mask);
    colormask(:,:,1) = img(:,:,1).*m;
    colormask(:,:,2) = img(:,:,2).*m;
    colormask(:,:,3) = img(:,:,3).*m;
end

