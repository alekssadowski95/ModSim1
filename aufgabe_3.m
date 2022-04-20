% Modellbildung und Simulation 1 - Sommersemester 2022
% Praktikum Nr.: 1
% Aufgabe Nr.: 3
% Namen: Aleksander Sadowski, Joel Bemelmann, Alan Omar
% Abhaengigkeiten: XXX

clear; %clears the workspace

% Defines the size parameters for the ground matrix
depth = 80;
width = 250;

params.probability     = 0.73;
params.ratio_absorb    = 0.04;
params.depth_influence = 0.01;

[G, A] = groundwater_sim(depth, width, params);

spy(G);


function [ground, absorb_mat] = groundwater_sim(depth, width, params)
% simulate diffusion of groundwater using cellular automata.
%
% The ground is modelled as a rectangular 2D-grid of size 
%   depth x width. 
% Fluid from a cell or the surface propagates to cells below
% according to a certain probability. Initially, the central 
% half of the surface is covered by fluid
%
% Inputs:
%   - depth:       The depth of the regulear 2D grid
%   - width:       The width of the regular 2D grid
%
%   - params.probability:        The seeping probability into 
%                                lower cells
%   - params.ratio_absorb:       Ratio of absorbing material in 
%                                the ground values between 0 and 1
%   - params.depth_influence:    influence of the depth on the
%                                seeping probability (FURTHER EXPLANATION NEEDED!)
%
% Outputs:
%   - ground:      2D-grid representing the groundwater distribution
%                  It is a (depth x width) Matrix with values in {0,1}
%   - absorb_mat:  2D-grid representing  the absorbing material 
%                  It is a (depth x width) Matrix with values in {0,1}
ground_init = zeros(depth + 1,width);

% Define wet cells
for i = round((1/4)*width) : round((3/4)*width)
    ground_init(1,i) = 1;
end

absorb_mat = zeros(81, 250);
for i = 1:81
    for j = 1:250
        absorb_mat(i, j) = rand;
    end
end

% Run a simulation
ground = compute_ground(ground_init, absorb_mat, params);
end


function ground = compute_ground(ground, absorb_mat, params)
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
            ground(i , j) = ~(absorb_mat(i, j) <= params.ratio_absorb);
            % If groud cell wasnt absorbed, now gets checked whether it
            % seeps through to the lower ground cells
            if ground(i, j) == 1
               % checks whether the water seeps through to the left lower ground cell 
               % the depth influences the probability to seep through.
                if j == 1
                    if i < ground_depth
                        ground(i+1, j) = rand <= (params.probability*(1-params.depth_influence)^i);
                        ground(i+1, j+1) = rand <= (params.probability*0.5*(1-params.depth_influence)^i);
                    end
    
                % checks whether the water seeps through to the right lower ground cell 
                % the depth influences the probability to seep through.
                elseif j == ground_width
                    ground(i+1, j) = rand <= (params.probability*(1-params.depth_influence)^i);
                    ground(i+1, j-1) = rand <= (params.probability*0.5*(1-params.depth_influence)^i);
    
                % checks whether the water seeps through to the ground cell
                % directly below it
                % the depth influences the probability to seep through.
                else
                    ground(i+1, j) = rand <= (params.probability*(1-params.depth_influence)^i);
                    ground(i+1, j+1) = rand <= (params.probability*0.5*(1-params.depth_influence)^i);
                    ground(i+1, j-1) = rand <= (params.probability*0.5*(1-params.depth_influence)^i);
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