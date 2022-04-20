% Modellbildung und Simulation 1 - Sommersemester 2022
% Praktikum Nr.: 1
% Aufgabe Nr.: 2
% Namen: Aleksander Sadowski, Joel Bemelmann, Alan Omar
% Abhaengigkeiten: XXX

clear; %clears the workspace

% Defines the size parametersfor the ground matrix
depth = 80;
width = 250;


% Loops through absorptions ratios and calculates the mean value for the 
% number of wet cells in the last row of the ground matrix. When mean value
% first is below 1 the absorption ratio is printed out.
for i = 1:100
    absorptions_ratio = i/100;
    vec = get_mean_bottom_wet(1000, 0.73, absorptions_ratio);
    result_mean = mean(vec);
    result_std = std(vec);
    if result_mean > 0 && result_mean < 1
        fprintf('Absorption ratio= %f, Mean=%f, Standard deviation= %f\n', absorptions_ratio, result_mean, result_std);
        break
    end
end

function [ground, absorb_mat] = groundwater_sim(depth, width, probability, ratio_absorb)
% simulate diffusion of groundwater using cellular automata.
%
% The ground is modelled as a rectangular 2D-grid of size 
%   depth x width. 
% Fluid from a cell or the surface propagates to cells below
% according to a certain probability. Initially, the central 
% half of the surface is covered by fluid
%
% Inputs:
%   - depth:        The depth of the regulear 2D grid
%   - width:        The width of the regular 2D grid
%   - probability:  The seeping probability into lower cells
%   - ratio_absorb: Ratio of absorbing material in the ground
%                   values between 0 and 1
%
% Outputs:
%   - ground:      2D-grid representing the groundwater distribution
%                  It is a (depth x width) Matrix with values in {0,1}
%   - absorb_mat:  2D-grid representing the absorbing material 
%                  It is a (depth x width) Matrix with values in {0,1}

% Setup the initial state of the simulation
% Initialize ground array with zeros
ground_init = zeros(depth + 1,width);

% Define wet cells
for i = round((1/4)*width) : round((3/4)*width)
    ground_init(1,i) = 1;
end

% Create an absorption matrix representing the absorption in each cell 
absorb_mat = zeros(81, 250);
for i = 1:81
    for j = 1:250
        absorb_mat(i, j) = rand;
    end
end

% Run a simulation
ground = compute_ground(ground_init, probability, absorb_mat, ratio_absorb);
end

function ground = compute_ground(ground, probability, absorb_mat, ratio_absorb)
% calculates the result of a ground simulation
ground_depth = size(ground, 1);
ground_width = size(ground, 2);
% loops throgh all ground rows
for i = 1:ground_depth
    % loops through each cell in that row
    for j = 1:ground_width
        % checks whether the current ground cell is wet
        if ground(i, j) == 1
            % when the ground cell is wet, checks whether it gets absorbed
            % depending on the absorption rate
            ground(i , j) = ~(absorb_mat(i, j) <= ratio_absorb);
            % If groud cell wasnt absorbed, now gets checked whether it
            % seeps through to the lower ground cells
            if ground(i, j) == 1
                % checks whether the water seeps through to the left lower ground cell 
                if j == 1
                    if i < ground_depth
                        ground(i+1, j) = rand <= probability;
                        ground(i+1, j+1) = rand <= probability*0.5;
                    end

                % checks whether the water seeps through to the right lower ground cell 
                elseif j == ground_width
                    ground(i+1, j) = rand <= probability;
                    ground(i+1, j-1) = rand <= probability*0.5;
    
                % checks whether the water seeps through to the ground cell
                % directly below it
                else
                    ground(i+1, j) = rand <= probability;
                    ground(i+1, j+1) = rand <= probability*0.5;
                    ground(i+1, j-1) = rand <= probability*0.5;
                end
            end 
        end
    end
end
end


function result_vector = get_mean_bottom_wet(number_of_simulations, probability, absorb_ratio)
% Returns a vector containing the number of wet cells in the last row of the 
% ground matrix for the specified number of simulations and a constant
% probability
result_vector = zeros(number_of_simulations, 1);
for i=1:number_of_simulations
    result_vector(i) = get_last_row_wet(groundwater_sim(80,250,probability, absorb_ratio));
end
end

function number_of_wet = get_last_row_wet(ground)
% returns the number of wet cells in the last row of the ground matrix
% given
number_of_wet = 0;
for i=1:250
    if ground(81, i) == 1
        number_of_wet = number_of_wet + 1;
    end    
end
end