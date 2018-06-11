function histogram = histo3hsv(HSV)
    HSV(:,1) = sin(HSV(:,1));
    histogram = hist3(HSV(:,1:2),{0:0.2:1 0:0.2:1});
end

