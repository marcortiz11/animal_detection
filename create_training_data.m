%% Crea una taula amb els descriptors de totes les imatges i el seu resultat
%Resultat en la variable: Dataset

imgdir = 'imatges/';
classes = dir(imgdir);
Dataset = table();

for c = 1:size(classes)
    animaldir = [classes(c).name,'/'];
    imgs = dir([imgdir,animaldir,'*.jpg']);
    annotations = dir([imgdir,animaldir,'*.mat']);
    for i = 1:size(imgs)
        img = [imgdir,animaldir,imgs(i).name];
        annotation = [imgdir,animaldir,annotations(i).name];
        %Obtenim els descriptors de cada imatge
        descriptor = image_descriptors(img,annotation);
        descriptor(end+1) = {classes(c).name};
        Dataset = [Dataset;descriptor];
    end
end


