% Modellbildung und Simulation 1 - Sommersemester 2022
% Praktikum Nr.: 1
% Aufgabe Nr.: 1
% Namen: Aleksander Sadowski, Joel Bemelmann, Alan Omar
% Abhaengigkeiten: XXX

clear; %clears the workspace

% Defines the size parametersfor the ground matrix
depth = 80;
width = 250;

% calculates the mean and standard deviation looping through different probabilities
% starting with 1 percent for the probability and going up one
% percent each time up to potentially 100 percent. If the mean value for the number 
% of wet cells in the last row first exceeds 3, the result is displayed
for i = 1:100
    vec = get_mean_bottom_wet(1000, i/100);
    result_mean = mean(vec);
    result_std = std(vec);
    if result_mean > 2.6 && result_mean < 4
        fprintf('Probability=%f, Mean=%f, Standard deviation= %f\n', i/100, result_mean, result_std);
        break
    end
end


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

% Define wet cells in ground matrix with 1
for i = round((1/4)*width) : round((3/4)*width)
    ground_init(1,i) = 1;
end

% Run the simulation
ground = compute_ground(ground_init, probability);
end


function ground = compute_ground(ground, probability)
% calculates the result of a ground simulation
ground_depth = size(ground, 1);
ground_width = size(ground, 2);
% loops throgh all ground rows
for i = 1:ground_depth-1
    % loops through each cell in that row
    for j = 1:ground_width
        % checks whether the current ground cell is wet
        if ground(i, j) == 1
            % checks whether the water seeps through to the left lower ground cell 
            if j == 1      
                ground(i+1, j) = rand <= probability;
                ground(i+1, j+1) = rand <= probability*0.5;
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


function result_vector = get_mean_bottom_wet(number_of_simulations, probability)
% Returns a vector containing the number of wet cells in the last row of the 
% ground matrix for the specified number of simulations and a constant
% probability
result_vector = zeros(number_of_simulations, 1);
for i=1:number_of_simulations
    result_vector(i) = get_last_row_wet(groundwater_sim(80,250,probability));
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
 


