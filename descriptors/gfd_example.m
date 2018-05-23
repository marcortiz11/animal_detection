%% Example to show the functionality of the gfd(bw,m,n)-function
% example image is 'ray-1.gif' of the MPEG-7 dataset for all ray-matrices
% and 'lizard-1.gif' of the MPEG-7 dataset for all lizard matrices
% matrix 'ray' contains the original ray-1 image
% matrix 'ray_rot60' contains the image ray rotate by 60 degrees
% matrix 'ray_rz20' contains the image ray resized by the factor 0.2
% matrix 'lizard' contains the original lizard-1 image
% matrix 'lizard_rot60' contains the image lizard rotated by 60 degrees
% matrix 'lizard_rz35' contains the image lizard resized by the factor 0.35
%
% in all images the object is already centered with its centroid to the
% image center
%
% by Frederik Kratzert 24. Aug 2015
% contact f.kratzert(at)gmail.com

try
    load('ray-lizard.mat');
catch
    error('File ''ray-lizard.mat'' must be in the same folder as this script');
end

%FD's for all ray images
FD_ray = gfd(ray,3,12);
FD_ray_rot60 = gfd(ray_rot60,3,12);
FD_ray_rz20 = gfd(ray_rz20,3,12);

%FD's for all lizard images
FD_lizard = gfd(lizard,3,12);
FD_lizard_rot60 = gfd(lizard_rot60,3,12);
FD_lizard_rz35 = gfd(lizard_rz35,3,12);

%get cityblock distance between all images
dist = pdist([FD_ray,FD_ray_rot60,FD_ray_rz20,FD_lizard,FD_lizard_rot60,...
    FD_lizard_rz35]','cityblock');
dist_sf = squareform(dist);

%visualize results
figure();
imagesc(dist_sf);
colormap(jet);
txt = num2str(dist_sf(:),'%0.3f');
txt = strtrim(cellstr(txt));
[x,y] = meshgrid(1:6);
hstr  = text(x(:),y(:),txt(:),'HorizontalAlignment','center','color','white');
names = {'ray','ray_rot','ray_rz','lizard','lizard_rot','lizard_rz'};
set(gca,'XTickLabel',names,'YTickLabel',names);
title('Cityblock-distance between all FD','Fontsize',15);