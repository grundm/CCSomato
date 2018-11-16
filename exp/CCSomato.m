%% Modulation of somatosensory perception across cardiac cycle
%  Forced-choice experiment with near-threshold somatosensory stimulation
% 
% Author:           Martin Grund
% Last update:      November 15, 2016

%% PREPARE

%% [SKIP IF RE-RUN] Initialize experiment

cd('C:/Users/willi/Desktop/ds5_control/');

% [p_data,ao,ai] = exp_init('CCSomato',0);
[p_data,ao,ai] = exp_init('CCSomato');

%% Re-run experiment

% (0) Got to working directory
%
%     cd('C:/Users/willi/Desktop/ds5_control/');
%
% (1) Load sequence data "CCSomato_settings_seq.mat" [exp_seq; p_data; s;]
%
% (2) Load last threshold assessment data, e.g. "psi_1AFC_01_data_02_01.mat" [p_data; psi; psi_data;]
%
% (3) Rename "psi_data" to last successful threshold assessment:
%
%     psi_data1 = psi_data; clear psi_data; % If 1st block failed
%     psi_data2 = psi_data; clear psi_data; % If 2nd block failed
%     psi_data3 = psi_data; clear psi_data; % If 3rd block failed
%
% (4) Load last block data, e.g. "CCSomato_01_data_02.mat" [exp_data; p_data; s;]
%
% (5) Rename 'exp_data' to the loaded block:
%
%     exp_data1 = exp_data; clear exp_data;
%     exp_data2 = exp_data; clear exp_data;
%     exp_data3 = exp_data; clear exp_data;
%
% (6) Initialize experiment
%
%     cd('C:/Users/willi/Desktop/ds5_control/');
%
%     [ao,ai] = exp_re_init('CCSomato',p_data);
%
% (7) Run "Test DAQ card" section (Strg + Enter)
%
% (8) Run "Test parallel port" section
%
% (9) Run block or threshold assessment you want to re-run

%% Test DAQ card

psi = psi_1AFC_setup(0:.02:5);

% ai_rec_test = aio_test(ao,ai,rectpulse(psi.pulse_t,1,ao.SampleRate,psi.wave_t));
ai_rec_test = aio_test(ao,ai,rectpulse(1,5,ao.SampleRate,psi.wave_t));

clear ai_rec_test psi

% Note: same settings for analog output data vector as for psi_1AFC and 
% nt_exp, because if subsequently the analog output is started with an 
% increased data vector, Matlab crashes (reported to Data Translation 
% Support on Dec 9, 2015, who will test this bug)

%% EXPERIMENT
%% [SKIP IF RE-RUN] Settings for experiment
s = setup;

% TESTING PURPOSE
% s.stim_types_num = [2 10];

% Since parallel port addresses change (check in device manager)
s.lpt_adr1 = '3000';
s.lpt_adr2 = '3008';

%% Test parallel port
lpt = dio_setup(s.lpt_adr1,s.lpt_adr2,s.lpt_dir);

[button,respTime,port] = parallel_button(10,GetSecs,'variable',lpt)

clear lpt button respTime port

%% [SKIP IF RE-RUN] Create sequence and save settings
[exp_seq,s] = seq(s);

save([p_data.dir s.file_prefix 'settings_seq.mat'],'p_data','exp_seq','s');
 

%%
%% ThA 1
block = 1;

psi = psi_1AFC_setup(0:.02:5);
psi.lpt_adr1 = s.lpt_adr1;
psi.lpt_adr2 = s.lpt_adr2;
% psi = psi_1AFC_setup(4:.01:6);

% Initial ThA with more trials and coarser steps
psi.UD_stopRule = 50;
psi.UD_meanNumber = 15;
psi.UD_startValue = 2.0;
psi.trials_psi = 35;
% psi.UD_stepSizeUp = 0.2;
% psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi_data1 = psi_loop(psi,p_data,ao,ai,block,1);

% If repetition necessary:
% (1) Narrow stimulus range
% psi = psi_1AFC_setup(0:.02:5);
% (2) Use last threshold estimate as start value
% psi.UD_startValue = psi_data1.near;
% (3) Indicate another run with last input - psi_loop(...,block,run)
% psi_data1 = psi_loop(psi,p_data,ao,ai,block,2); 


%% BLOCK 1
block = 1;

exp_data1 = run_exp(s,ao,ai,p_data,psi_data1.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

exp_data1 = intervals(s,exp_data1);

save_exp(p_data,exp_data1,s,['0' num2str(block)]);

log_detection(psi_data1,exp_data1);


%%
%% ThA 2
block = 2;

psi = psi_1AFC_setup(0:.02:5);
psi.lpt_adr1 = s.lpt_adr1;
psi.lpt_adr2 = s.lpt_adr2;

psi.UD_stepSizeUp = 0.1;
psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi.UD_startValue = exp_data1.near(end,1);

psi_data2 = psi_loop(psi,p_data,ao,ai,block,1);

% psi.UD_startValue = psi_data2.near;
% psi_data2 = psi_loop(psi,p_data,ao,ai,block,2);


%% BLOCK 2
block = 2;

exp_data2 = run_exp(s,ao,ai,p_data,psi_data2.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

exp_data2 = intervals(s,exp_data2);

save_exp(p_data,exp_data2,s,['0' num2str(block)]);

log_detection(psi_data2,exp_data2);


%%
%% ThA 3
block = 3;

psi.UD_startValue = exp_data2.near(end,1);
% psi.UD_stepSizeUp = 0.2;
% psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi_data3 = psi_loop(psi,p_data,ao,ai,block,1);
% psi.UD_startValue = psi_data3.near; %nt_data2.near(end,1);
% psi_data3 = psi_loop(psi,p_data,ao,ai,block,2);


%% BLOCK 3
block = 3;

exp_data3 = run_exp(s,ao,ai,p_data,psi_data3.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

exp_data3 = intervals(s,exp_data3);

save_exp(p_data,exp_data3,s,['0' num2str(block)]);

log_detection(psi_data3,exp_data3);


%% CLOSE

diary off
clear all