function data = intervals(s,data)
% data = intervals(s,data) computes the actual time intervals between
% screen onsets (e.g., fixation to cue) and analog output trigger in run_exp.
%
% Input:
%   s        - run_exp settings structure (doc setup)
%   data     - run_exp output data structure (e.g., exp_data1)
%   
% Author:           Martin Grund
% Last update:      October 21, 2016

%%
for i = 1:size(data.seq,1)

%% SCREEN ONSET INTERVALS

 %   data.t_mri_fix(i,1) = (data.onset_fix{i,1}-data.mri_trigger{i}(end))*1000;
    data.t_fix_cue(i,1) = (data.onset_cue{i,1}-data.onset_fix{i,1})*1000; % fix to cue interval
    data.t_cue_resp1(i,1) = (data.onset_resp1{i,1}-data.onset_cue{i,1})*1000; % fix to cue interval
    data.t_resp1_fix(i,1) = (data.onset_fix{i+1,1}-data.onset_resp1{i,1})*1000; % response 1 screen to fix interval

    % Trial
    if i < size(data.seq,1)
%         data.t_trial_mri(i,1) = (data.mri_trigger{i}(end)-data.mri_trigger{i-1}(end))*1000;
        data.t_trial_fix(i,1) = (data.onset_fix{i+1,1}-data.onset_fix{i,1})*1000;
    else
        data.t_trial_fix(i,1) = (data.wait_block_end-data.onset_fix{i,1})*1000;
    end
    
%% MRI TRIGGER TO AO TRIGGER    
%     % MRI trigger to analog output (AO) trigger [based on date vectors]
%     data.t_mri_ao_trigger(i,1) = (data.ao_trigger(i,1)-data.mri_trigger_date{i}(end))*24*60*60*1000;

%% CUE TO AO TRIGGER

    % (Cue onset to pre AO trigger) - stimulus delay
    data.t_cue_ao_trigger_pre_diff_stim_delay(i,1) = (data.ao_trigger_pre(i,1)-data.onset_cue{i,1}-data.seq(i,4))*1000;    
end
% 
% % (MRI trigger to AO trigger) - MRI trigger to fix - fix duration - stimulus delay
% data.t_mri_ao_trigger_diff_stim_delay = (data.t_mri_ao_trigger/1000-s.trigger2fix-s.fix_t-data.seq(:,4))*1000;

% Stimulus onset [best guess based on cue onset and AO trigger]
% data.t_fix_stim_onset = data.t_mri_ao_trigger + data.stim_offset;

% STIMULUS ONSET LOCKED TO FIRST FIXATION ONSET
data.t_fix_stim_onset = data.ao_trigger_pre(:,1) + data.stim_offset/1000 - data.onset_fix{1,1};

data.t_trigger_ao = data.ao_trigger_post - data.ao_trigger_pre;