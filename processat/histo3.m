function [histo] = histo3(img)
    %Convertim en 2D
    img2d = rgb2rb(img);
    [f,c,~] = size(img2d);
    histo = hist3(img2d,{0:0.1:1 0:0.1:1});
end


function [sim] = suavitzar(im)
    w = fspecial('gaussian',7,2);
    sim = imfilter(im,w,'conv','replicate');
end

