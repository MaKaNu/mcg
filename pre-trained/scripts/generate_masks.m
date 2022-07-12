function num_candidates = generate_masks(path_to_images, mode, do_save, do_scale)
% generate_masks uses the MCG algorithm to create an save masks from input
% path.
filelist = dir([path_to_images, strcat(filesep, '*.png')]);
num_candidates = zeros(length(filelist),1);
for i = 1:length(filelist)
    image_file = fullfile(path_to_images, filelist(i).name);
    [tempDir, tempFile] = fileparts(image_file); 
    save_file = fullfile(tempDir, [tempFile, '.mat']);
    I = imread(fullfile(path_to_images, filelist(i).name));
    I = im2uint8(I);
    if all(size(I) > [224, 224]) && do_scale
        I = imresize(I, [224, 224]);
    end
    if strcmp(mode, 'fast')
        [candidates_mcg, ~] = im2mcg(I,'fast');
    elseif strcmp(mode, 'acc')
        [candidates_mcg, ~] = im2mcg(I,'accurate');
    else
        error("Wrong mode")
    end
    num_candidates(i) = length(candidates_mcg.labels);
    result = cell(length(candidates_mcg.labels),1);
    for j = 1:length(candidates_mcg.labels)
        mask = ismember(candidates_mcg.superpixels, candidates_mcg.labels{j});
        if ~all(all(mask))
            mask_idx = find(mask);
            result{j} = mask_idx;
        end
    end
    if do_save
        save(save_file, "result")
    end
end
[number_of_minimal_masks, min_idx] = min(num_candidates);
[number_of_maximal_masks, max_idx] = max(num_candidates);
disp('Minimal # of Masks: ' + string(number_of_minimal_masks))
disp('at index #: ' + string(min_idx))
disp('Maximal # of Masks: ' + string(number_of_maximal_masks))
disp('at index #: ' + string(max_idx))

% Create CSV FILE
x = 1:length(filelist);
x = x';
y = sort(num_candidates);
B = [x,y];
T = array2table(B);
writetable(T, "num_cands.csv")
end
