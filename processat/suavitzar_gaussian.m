function [sim] = suavitzar_gaussian(im)
    w = fspecial('gaussian',7,5);
    sim = imfilter(im,w,'conv','replicate');
end
