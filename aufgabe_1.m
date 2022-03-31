% Modellbildung und Simulation 1 - Sommersemester 2022
% Praktikum Nr.: XXX
% Aufgabe Nr.: 1
% Namen: Aleksander Sadowski
% Abhaengigkeiten: XXX

clear; % clear all variables from workspace

% Create the groundwater sumlutaion and output ground state
ground = groundwater_sim(80,250,0.022);

% Visualize the ground
%spy(ground)
%imagesc(ground)

%%file groundwater_sim.m
function ground = groundwater_sim(depth, width, probability)
% simulate diffusion of groundwater using cellular automata.
%
% The ground is modelled as a rectangular 2D-grid of size 
%   depth x width. 
% Fluid from a cell or the surface propagates to cells below
% according to a certain probability. Initially, the central 
% half of the surface is covered by fluid
%
% Inputs:
%   - depth:       The depth of the regular 2D grid
%   - width:       The width of the regular 2D grid
%   - probability: The seeping probability into lower cells
%
% Outputs:
%   - ground:      2D-grid representing the groundwater distribution
%                  It is a (depth x width) Matrix with values in [0,1]

% Setup the initial state of the simulation
% Initialize ground array with zeros
ground_init = zeros(depth + 1,width);
% Define wet cells
for i = round((1/4)*width) : round((3/4)*width)
    ground_init(1,i) = 1;
end
% Run a simulation step
ground = compute_steps(ground_init, probability, 1000);
end

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