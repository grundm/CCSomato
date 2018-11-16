function [p_data,ao,ai] = exp_init(exp_dir)
% [p_data,ao,ai] = exp_init(exp_dir) runs initial procedures for 
% experiment:
%   - sets paths
%   - starts diary
%   - participant_data
%	- aio_setup
%
% Author:           Martin Grund
% Last update:      November 8, 2016

%%
% Make all assets available (e.g., Palamedes toolbox)
addpath(genpath([pwd, '/', exp_dir]))
addpath(genpath([pwd, '/psi_1AFC']))
addpath(genpath([pwd, '/assets']))

%% Particpant data
p_data = participant_data(['data/', exp_dir, '/ID']);

%% Diary logfile   
diary([p_data.dir 'exp_' p_data.ID '_log.txt']);

%% Setup analog output (ao) and input (ai)
[ao,ai] = aio_setup;
