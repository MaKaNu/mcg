function image = get_image( database, image_id )
    if strcmp(database,'pascal2012')
        image = imread(fullfile(database_root_dir(database), 'JPEGImages', [image_id '.jpg']));
    elseif strcmp(database,'bsds500')
        image = imread(fullfile(database_root_dir(database), 'images', [image_id '.jpg']));
    elseif strcmp(database, 'mars')
        image = imread(fullfile(database_root_dir(database), 'Images', [image_id '.png']));
        [r,c,m]  = size(image);
        image = im2uint8(repmat(reshape(image, [r, c, 1, m]), [1, 1, 3, 1]));
    else
        error(['Unknown database: ' database]);
    end
end

