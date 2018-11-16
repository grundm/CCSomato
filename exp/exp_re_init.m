function [ao,ai] = exp_re_init(exp_dir,p_data)
% [ao,ai] = exp_re_init(exp_dir,p_data) runs initial procedures for 
% experiment:
%   - sets paths
%   - starts diary
%	- aio_setup
%
% Author:           Martin Grund
% Last update:      November 8, 2016

%%
% Make all assets available (e.g., Palamedes toolbox)
addpath(genpath([pwd, '/', exp_dir]))
addpath(genpath([pwd, '/psi_1AFC']))
addpath(genpath([pwd, '/assets']))

%% Diary logfile   
diary([p_data.dir 'exp_' p_data.ID '_log.txt']);

%% Setup analog output (ao) and input (ai)
[ao,ai] = aio_setup;
