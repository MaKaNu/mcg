function rgb2pascal_voc(image_path, options)
% RGB2PASCAL_VOC transforms any RGB style Image to PascalVOC Segmentation
% style
%
%   RGB2PASCAL_VOC('PathToImage') transforms the image to PascalVOC Object
%   Segmentation.
%
%   RGB2PASCAL_VOC(_, mode='class') transforms the image to PascalVOC Class
%   Segmentation uses MARS Dataset Color values.
%
%   RGB2PASCAL_VOC(_, debug=true) enables debug mode to visualize the
%   results
%
%   RGB2PASCAL_VOC(_, mode='class', 'classes'=[<RGB-Values>]) Instead of
%   using the MARS dataset color values, the user chooses the color values.
%
%   RGB2PASCAL_VOC(_, destination='PathToDestionation') The resulting image
%   is saved to a new destionation. If not set the input image will be
%   overwritten.


arguments
    image_path char
    options.classes double = []
    options.debug logical = false
    options.mode {mustBeMember(options.mode,['class','object'])} = 'object'
    options.destination char = ""
end

if strcmp(options.mode, 'class') && isempty(options.classes)
    %ColorProperties for Mars Dataset
    options.classes = [
        189,195,210;    % Sand
        161,163,252;    % Soil
        183,171,250;    % Bedrock
        174,241,255;    % Big Rocks
        151,237,219;    % Sky
        180,209,242;    % Robot
        ];
end

warning off backtrace
if isempty(options.destination) && ~options.debug
    options.destination = image_path;
    warning("image at path: '%s' will be overwritten", image_path)
end
warning on backtrace

image = imread(image_path);
map = labelcolormap();

if ~isa(image, 'uint8')
    image = im2uint8(image);
end

bg = [0,0,0];
border = [224,224,192];

unique_colors = unique(reshape(permute(image,[3,2,1]),3,[]).','rows');

% Remove border and bg from unique_colors
index_border = ismember(unique_colors, border, 'rows');
index_bg = ismember(unique_colors, bg, 'rows');

index_mask = logical(repmat(index_bg + index_border,1,3));

unique_colors(index_mask) = [];

unique_colors = reshape(unique_colors, [], 3);

new_image = uint8(zeros(size(image,[1,2])));

for object_index = 1:length(unique_colors)
    object_mask = ...
        image(:,:,1) == unique_colors(object_index,1) & ...
        image(:,:,2) == unique_colors(object_index,2) & ...
        image(:,:,3) == unique_colors(object_index,3);

    if strcmp(options.mode, 'class')
        [~, class_index] = ismember( ...
            options.classes, unique_colors(object_index,:), 'rows');
        new_image(object_mask) = find(class_index);
    else
        new_image(object_mask) = object_index;
    end

    if options.debug
        plot_masks(new_image, object_mask, map, options.mode)
    end
end

% draw border
object_mask = ...
    image(:,:,1) == border(1) & ...
    image(:,:,2) == border(2) & ...
    image(:,:,3) == border(3);

new_image(object_mask) = 255;

if options.debug
    plot_masks(new_image, object_mask, map, options.mode)
else
    imwrite(new_image, map, options.destination)
end

end

function cmap = labelcolormap(N)

if nargin==0
    N=256;
end
cmap = zeros(N,3);
for i=1:N
    id = i-1; r=0;g=0;b=0;
    for j=0:7
        r = bitor(r, bitshift(bitget(id,1),7 - j));
        g = bitor(g, bitshift(bitget(id,2),7 - j));
        b = bitor(b, bitshift(bitget(id,3),7 - j));
        id = bitshift(id,-3);
    end
    cmap(i,1)=r; cmap(i,2)=g; cmap(i,3)=b;
end
cmap = cmap / 255;
end

function plot_masks(image, mask, map, title_string)
subplot(1,2,1)
imshow(image,map)
title(['Mode: ',title_string, 'New Image'])
subplot(1,2,2)
imshow(mask)
title(['Mode: ',title_string, 'Mask'])
pause()
end