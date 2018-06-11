function [ylabel] = predict(img_url,annot_url,models)
    entry = table();
    entry = [entry;image_descriptors(img_url,annot_url)];
    [~,n] = size(models);
    PROB = zeros(1,12);
    for m = 1:n
        [ylabel,score] = models{m}.predictFcn(entry);
        PROB = PROB+score;
    end
    PROB = PROB/(n)
    [maximum,index] = max(PROB);
    if maximum < 0.5
        ylabel = 'NoAnimal';
    else
        ylabel = models{m}.ClassificationEnsemble.ClassNames{index};
    end
end

