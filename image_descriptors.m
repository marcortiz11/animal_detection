
function [descriptors] = image_descriptors(img_url, anot_url)
%imt_url: path imatge
%Aquesta funció extreu les propietats d'una imatge i les retorna com a una
%cell-array.

%Load contour and boundary box
img = imread(img_url);
load(anot_url);

[f,c,z] = size(img);
mask = poly2mask(obj_contour(1,:),obj_contour(2,:),f,c);
subimg = img(box_coord(1):box_coord(2),box_coord(3):box_coord(4),:);

%% Area
area = sum(sum(mask(:,:)));


%% Regionprops properties

%Eccentricity: Ratio between major axis and minor axis
%Solidity: Ratio between region area and convex hull area
properties = regionprops(mask,'Eccentricity','Solidity','Area','Perimeter');
[~,max_region] = max([properties.Area]);


%% Perimeter
%Euclidean distance between points:
long_perimetre = properties(max_region).Perimeter;

%% Compactitat: Relació entre perímetre i àrea
compactivitat = (long_perimetre*long_perimetre/area);


%% Relació entre caixa englobant i animal

box_height = box_coord(2) - box_coord(1);
box_width = box_coord(4) - box_coord(3);
area_box = box_height * box_width;

compactivitat2 = area/area_box;


%% Color of the animal -> Falta Millorar

%Find coordinates inside mask
[rows cols] = find(mask);
%RGB values of the animal
RGBanimal=impixel(subimg,cols,rows);
%Compute RGB color histogram
histograma = histo3(RGBanimal);
histograma = reshape(histograma,1,numel(histograma));
histograma = histograma./max(histograma);

%% Gradient directions
sob = fspecial('sobel');
sobh= sob/4;
resh=imfilter(double(mask),sobh,'conv');
resv=imfilter(double(mask),sobh','conv');
alfa =atan2(resv,resh);
alfa = 255*(alfa+pi)/2/pi;
histograd = hist(reshape(alfa,1,numel(alfa)),10);
histograd = reshape(histograd,1,numel(histograd));
histograd = histograd./max(histograd);

%% Return descriptors
descriptors = {histograd,compactivitat,compactivitat2,properties(max_region).Eccentricity,properties(max_region).Solidity};

end

