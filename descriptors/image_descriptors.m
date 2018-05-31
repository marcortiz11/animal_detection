
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

mask = poly2mask(obj_contour(1,:)+box_coord(3),obj_contour(2,:)+box_coord(1),f,c);

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
% %RGB values of the animal
% RGBanimal=impixel(img,cols,rows);
% %Compute RGB color histogram
% histogramaRGB = histo3rgb(double(RGBanimal));
% histogramaRGB = reshape(histogramaRGB,1,numel(histogramaRGB));
% %Normalize histogram
% histogramaRGB = histogramaRGB./max(histogramaRGB);

%% Mean color of the region

red = img(:,:,1);
green = img(:,:,2);
blue = img(:,:,3);
meancolor = [mean(red(mask)),mean(green(mask)),mean(blue(mask))];

%% Histogram HSV (alternative)

% %Find coordinates inside mask
% [rows, cols] = find(mask);
% %RGB values of the animal
% HSVanimal=impixel(rgb2hsv(suavitzar_gaussian(img)),cols,rows);
% %Compute RGB color histogram
% histogramaHSV = histo3hsv(HSVanimal);
% histogramaHSV = reshape(histogramaHSV,1,numel(histogramaHSV));
% %Normalize histogram
% histogramaHSV = histogramaHSV./max(histogramaHSV); 


%% Histogram of Gradient Directions (HOG)
% 
contour = xor(imerode(double(mask),strel('disk',1)),mask);
    
sob = fspecial('sobel');
sobh= sob/4;
resh=imfilter(double(mask),sobh,'conv');
resv=imfilter(double(mask),sobh','conv');
alfa = atan2(resv,resh);

buckets = 8;
histograd = imhist(alfa(contour),buckets);
histograd = reshape(histograd,1,numel(histograd));
[m, index] = max(histograd);
histograd = histograd./m;
histograd = circshift(histograd,buckets-index);


%% Fourier Descriptor

%Normalized fourier descriptor:
FD = gfd(centerobject(mask),3,14);
FD = FD';



%% Texture: Entropy of the grey-scale animal

colormask = maskimagecolor(img,mask);
gray = double(rgb2gray(colormask));
gray = gray./max(max(gray));
Entropy = entropy(gray);

%% Texture: Properties of the grey-scale region

erode = imerode(mask,strel('disk',2));
gcm = graycomatrix(gray.*erode);
grayprops = graycoprops(gcm,{'contrast','homogeneity','correlation'});


%% Return descriptors

descriptors = {meancolor,histograd,FD,grayprops.Correlation,Entropy,grayprops.Contrast,grayprops.Homogeneity,compactivitat,compactivitat2,properties(max_region).Eccentricity,properties(max_region).Solidity};

end

