function [ylabel] = predict(img_url,annot_url,models)
    entry = table();
    entry = [entry;image_descriptors(img_url,annot_url)];
    [~,n] = size(models);
    [~,classes] = size(models{1}.ClassificationEnsemble.ClassNames);
    PROB = zeros(1,classes);
    for m = 1:n
        [~,score] = models{m}.predictFcn(entry);
        PROB = PROB+score;
    end
    PROB = PROB/(n)
    [maximum,index] = max(PROB);
    if maximum < 0.55
        ylabel = 'NoAnimal';
    else
        ylabel = models{1}.ClassificationEnsemble.ClassNames{index};
    end
end

