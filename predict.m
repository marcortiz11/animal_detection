function [ylabel] = predict(img_url,annot_url,model)
    entry = table();
    entry = [entry;image_descriptors(img_url,annot_url)];
    ylabel=model.predictFcn(entry);
end

