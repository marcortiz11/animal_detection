function [histo] = histo3rgb(img)
    %Convertim en 2D
    img2d = rgb2rb(img);
    histo = hist3(img2d,{0:0.12:1 0:0.12:1});
end



