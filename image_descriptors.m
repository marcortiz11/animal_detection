
function [descriptors] = image_descriptors(img_url, anot_url)
%imt_url: path imatge
%Aquesta funció extreu les propietats d'una imatge i les retorna com a una
%cell-array.

%Load contour and boundary box
img = imread(img_url);
load(anot_url);

%Greyscale -> 3D
[f,c,z] = size(img);
if (z == 1)
    face = img;
    img(:,:,2) = face;
    img(:,:,3) = face;
end

mask = poly2mask(obj_contour(1,:)+box_coord(1),obj_contour(2,:)+box_coord(3),f,c);
subimg = img(box_coord(1):box_coord(2),box_coord(3):box_coord(4),:);

%% Region properties

properties = regionprops(mask,'Eccentricity','Solidity','Area','Perimeter','PixelIdxList');
[~,max_region] = max([properties.Area]);

%Deleting minor regions (noise)
mask(:,:) = 0;
mask(properties(max_region).PixelIdxList) = 1;


%% Area

area = properties(max_region).Area;

%% Perimeter

long_perimetre = properties(max_region).Perimeter;

%% Compactitat: Relació entre perímetre i àrea

compactivitat = (long_perimetre*long_perimetre/area);


%% Relació entre caixa englobant i animal

box_height = box_coord(2) - box_coord(1);
box_width = box_coord(4) - box_coord(3);
area_box = box_height * box_width;

compactivitat2 = area/area_box;


%% Histogram RGB

% %Find coordinates inside mask
% [rows, cols] = find(mask);
% figure,imshow(img);
% %RGB values of the animal
% RGBanimal=impixel(img,cols,rows);
% %Compute RGB color histogram
% histogramaRGB = histo3rgb(double(RGBanimal));
% histogramaRGB = reshape(histogramaRGB,1,numel(histogramaRGB));
% %Normalize histogram
% histogramaRGB = histogramaRGB./max(histogramaRGB);



%% Histogram HSV (alternative)

% Find coordinates inside mask
% [rows, cols] = find(mask);
% RGB values of the animal
% HSVanimal=impixel(rgb2hsv(suavitzar_gaussian(img)),cols,rows);
% Compute RGB color histogram
% histogramaHSV = histo3hsv(HSVanimal);
% histogramaHSV = reshape(histogramaHSV,1,numel(histogramaHSV));
% Normalize histogram
% histogramaHSV = histogramaHSV./max(histogramaHSV); 


%% Histogram of Gradient Directions (HOG)

sob = fspecial('sobel');
sobh= sob/4;
resh=imfilter(double(mask),sobh,'conv');
resv=imfilter(double(mask),sobh','conv');
alfa =atan2(resv,resh);
alfa = 255*(alfa+pi)/2/pi;
histograd = hist(reshape(alfa,1,numel(alfa)),10);
histograd = reshape(histograd,1,numel(histograd));
histograd = histograd./max(histograd);


%% Fourier Descriptor

%Normalized fourier descriptor:
FD = gfd(centerobject(mask),1,8);
FD = FD';


%% Return descriptors
descriptors = {histogramaHSV,FD,histograd,compactivitat,compactivitat2,properties(max_region).Eccentricity,properties(max_region).Solidity};

end

