clc 
close all

% This function defines all parameters to tune in the training of MCG
params = sf_mUCM_multi_3sc_u_4r_12k_params();

%Determine database
database = params.database;

% Load which images to consider from the database (train, val, etc.)
im_ids_val = database_ids(database,params.gt_set_pareto);
im_ids_test = database_ids(database,params.gt_set_test);

% Update Validation Images
% for image_index = 1:length(im_ids_val)
%     image_name = im_ids_val{image_index};
%     %Create object image path
%     image_path_object = fullfile( ...
%         database_root_dir(database), ...
%         'SegmentationObject', [image_name '.png']);
%     %Create class image path
%     image_path_class = fullfile( ...
%         database_root_dir(database), ...
%         'SegmentationClass', [image_name '.png']);
%     % Calculate validation object segmentations
%     rgb2pascal_voc(image_path_object)
%     % Calculate validation class segmentations
%     rgb2pascal_voc(image_path_class, mode='class')
% end

% Update Test Images
for image_index = 1:length(im_ids_test)
    image_name = im_ids_test{image_index};
    %Create object image path
    image_path_object = fullfile( ...
        database_root_dir(database), ...
        'SegmentationObject', [image_name '.png']);
    %Create class image path
    image_path_class = fullfile( ...
        database_root_dir(database), ...
        'SegmentationClass', [image_name '.png']);
    % Calculate test object segmentations
    rgb2pascal_voc(image_path_object)
    % Calculate test object segmentations
    rgb2pascal_voc(image_path_class, mode='class')
end