function compare_candidates(paths_to_images, num_candidates, mode)
%This function calls a single/multiple image/s and compares their
%candidates
    paths = check_path(paths_to_images);
    figure;
    for i = 1:length(paths)
        I = load_image_as_uint8(paths{i});
        I = imresize(I, [224, 224]);
        candidates = run_mcg(I, mode);
        candidates_table = create_candidate_table(candidates);
        masks = generate_masks(candidates_table, candidates.superpixels, num_candidates);
        overlayed_masks = generate_overlayed_masks(masks);
        subplot(1,length(paths), i)
        imshow(overlayed_masks)
        [~, name, ~] = fileparts(paths{i});
        save(name, 'masks')
    end
    
end

function paths = check_path(paths_to_images)
    if isa(paths_to_images, "cell") 
        for i = 1:length(paths_to_images)
            check_exist = exist(paths_to_images{i}, "file");
            if check_exist ~= 2
                error("Path %s is not a file", paths_to_images{i})
            end
        end
        paths = paths_to_images;
    elseif isa(paths_to_images, "char")
        check_exist = exist(paths_to_images, "file");
        if check_exist ~= 2
                error("Path %s is not a file", paths_to_images{i})
        end
        paths = {paths_to_images};
    else
        error("Path/Paths is not the correct format!")
    end
end

function I = load_image_as_uint8(image_path)
    I = imread(image_path);
    I = im2uint8(I);
end


function candidates = run_mcg(I, mode)
    if strcmp(mode, 'fast')
        [candidates, ~] = im2mcg(I,'fast');
    elseif strcmp(mode, 'acc')
        [candidates, ~] = im2mcg(I,'accurate');
    else
        error("Wrong mode")
    end
end

function [candidates_table] = create_candidate_table(candidates)
    candidates_2 = struct(...
        'scores', num2cell(candidates.scores), ...
        'labels', candidates.labels ...
        );
    candidates_table = struct2table(candidates_2);
    candidates_table = sortrows(candidates_table, 'scores', 'descend');
end

function final_masks = generate_masks(candidates_table, superpixels, num_candidates)
    final_masks = false(224,224,num_candidates);
    for i = 1:num_candidates
        final_masks(:,:,i) = ismember(superpixels, candidates_table.labels{i});
    end
end

function overlayed_masks = generate_overlayed_masks(masks)
    [u, v, masks_count] = size(masks);
    overlayed_masks = zeros([u,v,3]);
    for i = 1:masks_count
        mask = masks(:,:,i);
        colored_mask = generate_colored_mask(mask, i, masks_count);
        overlayed_masks = overlay_next_image(overlayed_masks, colored_mask, mask);
    end
end

function colored_mask = generate_colored_mask(mask, index, num_candidates)
    cmap = hsv(num_candidates);
    colored_mask(:,:,1) = mask .* cmap(index,1);
    colored_mask(:,:,2) = mask .* cmap(index,2);
    colored_mask(:,:,3) = mask .* cmap(index,3);
end

function overlayed_img = overlay_next_image(previous, next, binary_next)
    cutted_previous = previous .* binary_next;
    inv_cutted_previous = previous .* ~binary_next;
    overlayed_next = imadd(cutted_previous/2, next/2);
    overlayed_img = imadd(inv_cutted_previous, overlayed_next);
end

