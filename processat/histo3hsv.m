function histogram = histo3hsv(HSV)
    histogram = hist3(HSV(:,1:2),{0:0.2:1 0:0.2:1});
    hist3(HSV(:,1:2),{0:0.2:1 0:0.2:1})
end

