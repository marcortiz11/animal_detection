function [descriptors] = image_descriptors(img_url, anot_url)
%imt_url: path imatge

img = imread(img_url);
load(anot_url);

[f,c,z] = size(img);
mask = poly2mask(obj_contour(1,:),obj_contour(2,:),f,c);

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


%% Return descriptors
descriptors = {compactivitat,compactivitat2,properties(max_region).Eccentricity,properties(max_region).Solidity};

end

