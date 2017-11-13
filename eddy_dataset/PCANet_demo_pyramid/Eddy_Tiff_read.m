clc; clear all; close all;
file_path =  'F:\Matlab\Data\UCMerced_LandUse\Images\agri0cultural\';
img_path_list = dir(strcat(file_path,'*.tif'));
img_num = length(img_path_list);
img_data = [];
if img_num > 0 
     for j = 1:img_num 
       image_name = img_path_list(j).name;
       image =  imread(strcat(file_path,image_name));
       image = imresize (image, [280 280]);
       image = rgb2gray(image);
       image = uint16(image);
       img_row1=reshape(image,280*280*1,1);
       img_data = [img_data; img_row1'];
       fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));
   end
end


%crop the image
file_path =  'F:\Matlab\Data\UCMerced_LandUse\Images\agricultural\';
img_path_list = dir(strcat(file_path,'*.tif'));
img_num = length(img_path_list);
img_data = [];
if img_num > 0 
     for j = 1:img_num 
       image_name = img_path_list(j).name; 
       image =  imread(strcat(file_path,image_name));
       [m n]=size(image);
       m = round(m*0.8);
       n = round(n*0.8);
       image = imcrop(image,[10 10 m n]);
       image = imresize (image, [280 280]);
       image = rgb2gray(image);
       image = uint16(image);
       img_row1=reshape(image,280*280*1,1);
       img_data = [img_data; img_row1'];
       fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));
   end
end