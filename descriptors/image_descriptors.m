
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
descriptors = {};

%% Region properties

properties = regionprops(mask,'Eccentricity','PixelIdxList','Solidity','Area','Perimeter','Centroid','BoundingBox','Orientation');
[~,max_region] = max([properties.Area]);

mask(:,:) = 0;
mask(properties(max_region).PixelIdxList) = 1;
contour = xor(imerode(double(mask),strel('disk',1)),mask);
descriptors{end+1} = properties(max_region).Eccentricity;
descriptors{end+1} = properties(max_region).Solidity;


%% Area & Perímetre

area = properties(max_region).Area;
long_perimetre = properties(max_region).Perimeter;

%% Compactitat: Relació entre perímetre i àrea

compactness = (long_perimetre*long_perimetre/area);
descriptors{end+1} = compactness;

%% Relació entre caixa englobant i animal

box_height = box_coord(2) - box_coord(1);
box_width = box_coord(4) - box_coord(3);
area_box = box_height * box_width;

rectangularity = area/area_box;
descriptors{end+1} = rectangularity;

%% Histogram RGB
[rows, cols] = find(mask);
RGBanimal=impixel(suavitzar_gaussian(img),cols,rows);
histogramaRGB = histo3rgb(double(RGBanimal));
buckets = numel(histogramaRGB);
histogramaRGB = reshape(histogramaRGB,1,buckets);
histogramaRGB = histogramaRGB./max(max(histogramaRGB));

descriptors{end+1} = var(histogramaRGB);
descriptors{end+1} = std(histogramaRGB);
% %descriptors{end+1} = sum((1:buckets) .* (histogramaRGB));
[~,C1] = kmeans(RGBanimal,2);
C1(1) = C1(1)./sum(C1(1));
C1(2) = C1(2)./sum(C1(2));
C1=reshape(C1,1,2*3);
% % descriptors{end+1} = C1;


%% Histogram HSV (alternative)
% Find coordinates inside mask
[rows, cols] = find(mask);
HSVanimal=impixel(rgb2hsv(suavitzar_gaussian(img)),cols,rows);

% histogramaHSV = histo3hsv(HSVanimal);
% buckets = numel(histogramaHSV);
% histogramaHSV = reshape(histogramaHSV,1,buckets);
% histogramaHSV = histogramaHSV./max(max(histogramaHSV)); 
 [~,C2] = kmeans(HSVanimal(:,2:3),2);
 C2=reshape(C2,1,2*2);
 descriptors{end+1} = [C1,C2];
% descriptors{end+1} = std(histogramaHSV);
% descriptors{end+1} = sum((1:buckets) .* (histogramaHSV));
% descriptors{end+1} = var(histogramaHSV);
% descriptors{end+1} = mean(histogramaHSV);

%% Histogram of Gradient Directions (HOG)

descriptors{end+1} = hog(mask,contour,8);


%% Fourier Descriptor

%Normalized fourier descriptor:
FD = gfd(centerobject(mask),3,16);
FD = FD';
descriptors{end+1} = FD;

%% Texture: Entropy of the grey-scale animal

colormask = maskimagecolor(img,mask);
gray = double(rgb2gray(colormask));
gray = gray./max(max(gray));
Entropy = entropy(gray);
descriptors{end+1} = Entropy;
descriptors{end+1} = stdfilt(gray);

%% Texture: Properties of the grey-scale region

erode = imerode(mask,strel('disk',2));
gcm = graycomatrix(gray.*erode);
grayprops = graycoprops(gcm,{'contrast','homogeneity','correlation'});
descriptors{end+1} = grayprops.Correlation;
descriptors{end+1} = grayprops.Contrast;
descriptors{end+1} = grayprops.Homogeneity;


%% Local Features 

angle = properties(max_region).Orientation;
mask_centered = imrotate(mask,-angle);

p = regionprops(mask_centered,'Area','PixelIdxList');
[~,m] = max([p.Area]);
mask_centered(:,:) = 0;
mask_centered(p(m).PixelIdxList) = 1;

mask_centered = centerobject(mask_centered);
contour_centered = imabsdiff(mask_centered , imerode(mask_centered,strel('disk',1)));

properties_centered_rotated = regionprops(mask_centered,'BoundingBox','Extent','Area','Centroid');
[~,max_region] = max([properties_centered_rotated.Area]);

box_coord(1)=properties_centered_rotated(max_region).BoundingBox(1);
box_coord(2)=properties_centered_rotated(max_region).BoundingBox(1) + properties_centered_rotated(max_region).BoundingBox(3);
box_coord(3)=properties_centered_rotated(max_region).BoundingBox(2);
box_coord(4)=properties_centered_rotated(max_region).BoundingBox(2)+properties_centered_rotated(max_region).BoundingBox(4);

xinici = box_coord(1);
xfinal = box_coord(2);
yinici = box_coord(3);
yfinal = box_coord(4);

stepx = (xfinal-xinici)/3;
stepy = (yfinal-yinici)/1;

descriptors{end+1} = properties_centered_rotated(max_region).Extent;

for i = yinici:stepy:yfinal-stepy
    for j = xinici:stepx:xfinal-stepx
        
        submask = mask_centered(i:i+stepy,j:j+stepx);
        subcontour = contour_centered(i:i+stepy,j:j+stepx);
        subproperties = regionprops(submask,'Eccentricity','Extent','PixelIdxList','Solidity','Area','Perimeter','Centroid','BoundingBox','Orientation');
        [~,max_region] = max([subproperties.Area]);
        descriptors{end+1} = hog(submask,subcontour,8);
        descriptors{end+1} = subproperties(max_region).Eccentricity;
        descriptors{end+1} = subproperties(max_region).Solidity;
        descriptors{end+1} = subproperties(max_region).Extent;
        compactness = (subproperties(max_region).Perimeter*subproperties(max_region).Perimeter/area);
        descriptors{end+1} = compactness;

    end
end

stepx = (xfinal-xinici)/1;
stepy = (yfinal-yinici)/3;

for i = yinici:stepy:yfinal-stepy
    for j = xinici:stepx:xfinal-stepx
        
        submask = mask_centered(i:i+stepy,j:j+stepx);
        subcontour = contour_centered(i:i+stepy,j:j+stepx);
        subproperties = regionprops(submask,'Eccentricity','Extent','PixelIdxList','Solidity','Area','Perimeter','Centroid','BoundingBox','Orientation');
        [~,max_region] = max([subproperties.Area]);
        descriptors{end+1} = hog(submask,subcontour,8);
        descriptors{end+1} = subproperties(max_region).Eccentricity;
        descriptors{end+1} = subproperties(max_region).Solidity;
        descriptors{end+1} = subproperties(max_region).Extent;
        compactness = (subproperties(max_region).Perimeter*subproperties(max_region).Perimeter/area);
        descriptors{end+1} = compactness;

    end
end

end

