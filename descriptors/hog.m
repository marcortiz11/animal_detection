function [histograd] = hog(mask,contour,buckets)
    sob = fspecial('sobel');
    sobh= sob/4;
    resh=imfilter(double(mask),sobh,'conv');
    resv=imfilter(double(mask),sobh','conv');
    alfa = atan2(resv,resh);
    
    histograd = imhist(alfa(contour),buckets);
    histograd = reshape(histograd,1,numel(histograd));
    [m, index] = max(histograd);
    histograd = histograd./m;
    histograd = circshift(histograd,buckets-index);
end

