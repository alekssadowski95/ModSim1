function ground_end_step = compute_steps(ground, probability, iterations)
ground_start_step = ground;
for i = 1:iterations
    ground_start_step = compute_step(ground_start_step, probability);
end
ground_end_step = ground_start_step;
end


function ground_step = compute_step(ground, probability)
ground_depth = size(ground, 1);
ground_width = size(ground, 2);
ground_step = zeros(ground_depth, ground_width);
for i = 1:ground_depth
    for j = 1:ground_width
        ground_step(i,j) = compute_cell_step(ground, probability, i, j);
    end
end
end


function cell_step = compute_cell_step(ground, probability, depth_index, width_index)
% Only goes through "wetting" algorythm when current cell is not already
% wet
if ground(depth_index, width_index) == 1
    cell_step = ground(depth_index, width_index);
else 
    cell_step = 0;
    if depth_index > 1
        if ground(depth_index - 1, width_index) == 1 && rand <= probability
            cell_step = 1;
        end
        if width_index > 1
            if ground(depth_index - 1, width_index - 1) == 1 && rand <= probability*0.5
                cell_step = 1;
            end
        end
        if width_index < size(ground, 2)
            if ground(depth_index - 1, width_index + 1) == 1 && rand <= probability*0.5
                cell_step = 1;
            end
        end
    end
end
end