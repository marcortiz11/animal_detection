function [out] = rgb2rb(in)
    Intensity = (in(:,1) + in(:,2) + in(:,3));
    out(:,1) = in(:,1) ./ Intensity;
    out(:,2) = in(:,3) ./ Intensity;
end