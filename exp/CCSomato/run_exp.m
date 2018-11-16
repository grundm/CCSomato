function data = run_exp(s,ao,ai,p_data,PF_params,seq)
% run_exp(s,ao,ai,p_data,PF_params,seq) starts the experiment.
% 
% % Input variables %
%   s               - settings structure (doc setup)
%   ao              - analog output object
%   ai              - analog input object
%   p_data          - participant data (output of participant_data)
%   PF_params       - psychometric function parameters (e.g., psi_data.PF_params_PM)
% 
% % Output variables %
%   data            - data output structure
% 
% Author:           Martin Grund
% Last update:      November 15, 2016


%% Intensity input dialog %%
data.near = dlg_1intensity(PF_params,s.near_d,s.near_name,s.stim_steps,s.stim_max,s.stim_dec);


%% SETUP %%    
try


%% Random number generator
data.rng_state = set_rng_state(s);


%% Analog output

% daqgetfield(dio,'uddobject'); can accelerate putvalue/getvalue from ~1ms to ~20us 
% (see https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-TTL-Triggers-in-Windows)

ao_udd = daqgetfield(ao,'uddobject');


%% Response-button mapping

% 1 response -> 2 conditions
% 1: JN
% 2: NJ

data.resp_btn_map = mod(str2double(p_data.ID)-1,2)+1;

switch data.resp_btn_map
    case 1
        data.resp1_txt = s.resp1_txt;
    case 2
        data.resp1_txt = flipud(s.resp1_txt);
end


%% Sequence (doc seq)

data.seq = seq;


%% Stimulus

% Generate default waveform vector
[data.stim_wave, data.stim_offset] = rectpulse(s.pulse_t,1,ao.sampleRate,s.wave_t);

% Generate TTL pulse waveform vector
[data.TTL_wave, data.TTL_offset] = rectpulse(s.TTL_t,s.TTL_V,ao.sampleRate,s.wave_t);


%% Timing

data.trial_t = s.fix_t + s.cue_t + s.resp1_max_t;

% Trial screen flips
[data.onset_fix,...
 data.onset_cue,...
 data.onset_resp1] = deal(cell(size(data.seq,1),5));

%  data.onset_stim_p,...
%  data.onset_resp1_p,...
%  data.onset_resp2,...
%  data.onset_ITI

% % End of wait for trial end
% data.wait_trial_end = zeros(size(data.seq,1),1);

% Before block screen flips
[data.btn_instr,...
data.onset_instr] = deal(cell(1,5));

% ,...
% data.onset_start_mri

% Pause screen flips
% data.onset_pause = cell(s.blocks-1,5);

% Analog input trigger
data.ao_events = cell(size(data.seq,1),1);
data.ai_trigger = zeros(1,5);

% % Scanner trigger
% [data.mri_trigger,...
%  data.mri_trigger_date] = deal(cell(size(data.seq,1),1));
% 
% data.mri_wait = zeros(size(data.seq,1),2);

% Stimulus trigger
[data.ao_trigger_pre,...
 data.ao_trigger,...
 data.ao_trigger_post,...
 data.ao_error] = deal(zeros(size(data.seq,1),1));

% Response tracking
[data.resp1_btn,...
data.resp1_t,...
data.resp1] = deal(zeros(size(data.seq,1),1));

% ,...
% data.resp2_btn,...
% data.resp2_t,...
% data.resp2

%% Parallel port
lpt = dio_setup(s.lpt_adr1,s.lpt_adr2,s.lpt_dir);


%% Screen

window = Screen('OpenWindow',0,s.window_color);
HideCursor;

Screen('TextFont',window,s.txt_font);               
             
% Get screen frame rate
Priority(1); % recommended by Mario Kleiner's Perfomance & Timing How-to
flip_t = Screen('GetFlipInterval',window,s.get_flip_i);
Priority(0);
data.flip_t = flip_t;

% Compute response text location
[data.window(1),data.window(2)] = Screen('WindowSize',window);
resp1_x1 = WindowCenter(window) - s.resp1_offset;
%resp2_x1 = WindowCenter(window) - s.resp1_offset*3;                                

    
%% EXPERIMENTAL PROCEDURE %%
% Priority(1) seems to cause DataMissed events for analog input
block = data.seq(1,1);


%% Instructions

% Get directory (based on response-button mapping)
instr_dir = [fileparts(mfilename('fullpath')) s.instr_dir];
instr_subdir = dir([instr_dir s.instr_subdir_wildcard num2str(data.resp_btn_map) '*']);

% Load image data
instr_images = load_images([instr_dir instr_subdir.name '/'],s.instr_img_wildcard);

% Show images
[data.btn_instr, data.onset_instr] = show_instr_img(instr_images,window,lpt);

% Delete image data from memory
clear instr_images img_texture


%% Analog input

ai.LogFileName = [tempdir s.file_prefix p_data.ID '_ai_0' num2str(block)];

flushdata(ai);
start(ai);

data.ai_logfile = ai.LogFileName;        
data.ai_trigger = datenum(ai.InitialTriggerTime);        

WaitSecs(2);


%% Prompt - Start scanner

%Screen('TextSize',window,s.txt_size);
%DrawFormattedText(window,s.scanner_msg,'center','center',s.txt_color);
%[data.onset_start_mri{1,:}] = Screen('Flip',window);

%% Trial loop

for i = 1:size(data.seq,1)    
    
    %%% WAIT FOR SCANNER %%%
    
    %[data.mri_trigger{i},data.mri_trigger_date{i},data.mri_wait(i,1),data.mri_wait(i,2)] = wait_for_scanner(lpt,s.TR,s.trigger_bit,s.trigger_max);
    
    
    %%% FIX %%%
    
    % Set font size for symbols
    Screen('TextSize',window,s.cue_size);
    DrawFormattedText(window,s.fix,'center','center',s.txt_color);
    
    %[data.onset_fix{i,:}] = Screen('Flip',window,data.mri_trigger{i}(end)+s.trigger2fix-flip_t);
    [data.onset_fix{i,:}] = Screen('Flip',window);
    
    
    %%% CUE %%%
    
    DrawFormattedText(window,s.cue,'center','center',s.txt_color);
    
    if i == 1
        [data.onset_cue{i,:}] = Screen('Flip',window,data.onset_fix{i,1}+s.fix_t-flip_t);
    else
        [data.onset_cue{i,:}] = Screen('Flip',window,data.onset_resp1{i-1,1}+s.resp1_max_t+s.fix_t-flip_t);
    end
    
    
    %%% STIMULUS %%%
    
    % Select intensity
    
    switch data.seq(i,2)
        case 0 % null
            data.intensity(i,1) = 0;
        case 1 % near
            data.intensity(i,1) = round_dec(data.near*data.seq(i,3),s.stim_dec);
        %case 2 % supra
        %    data.intensity(i,1) = round_dec(data.supra*data.seq(i,3),s.stim_dec);
    end
    
    % Buffer waveform
    
    if data.intensity(i,1) == 0
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.TTL_wave]);
    else
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.TTL_wave]);
    end
    
    % Random stimulus delay (locked to scanner trigger)
    data.ao_trigger_pre(i,1) = WaitSecs('UntilTime',data.onset_cue{i,1}+data.seq(i,4));
    
    % Trigger waveform
    try
        start(ao_udd);
        wait(ao_udd,.5);
    catch lasterr
        disp(['Trial ', num2str(i), ': ', lasterr.message]);
        data.ao_error(i,1) = 1;
        stop(ao_udd);
    end
    
    data.ao_trigger_post(i,1) = GetSecs;
    data.ao_events{i,1} = ao.EventLog;
    data.ao_trigger(i,1) = datenum(data.ao_events{i,1}(2).Data.AbsTime);
    
    
    %%% RESPONSE 1 - DETECTION %%%
    
    % Response options
    % 28 ms
    Screen('TextSize',window,s.txt_size);
    resp1_nx1 = DrawFormattedText(window,data.resp1_txt(1,:),resp1_x1,'center',s.txt_color);
                DrawFormattedText(window,data.resp1_txt(2,:),data.window(1)-resp1_nx1,'center',s.txt_color);

    [data.onset_resp1{i,:}] = Screen('Flip',window,data.onset_cue{i,1}+s.cue_t-flip_t);
        
    % Wait for key press
    [data.resp1_btn(i,1),data.resp1_t(i,1),data.resp1_port(i,:)] = parallel_button(s.resp1_max_t,data.onset_resp1{i,1},s.resp_window,lpt);        

    
%     % RT dependent fix between responses
%     if s.resp1_max_t-data.resp1_t(i,1) > s.resp_p_min_t
%         Screen('TextSize',window,s.cue_size);
%         DrawFormattedText(window,s.ITI_cue,'center','center',s.txt_color);
%         [data.onset_resp1_p{i,:}] = Screen('Flip',window);
%     end        
%     
%     
%     %%% RESPONSE 2 - CONFIDENCE %%%
%     
%     % Response options
%     % Screen('TextSize') takes ~10 ms
%     % DrawFormattedText takes ~42 ms
%     Screen('TextSize',window,s.txt_size);
%     resp2_nx1 = DrawFormattedText(window,data.resp2_txt(1),resp2_x1,'center',s.txt_color);
%                 DrawFormattedText(window,data.resp2_txt(2),resp1_x1,'center',s.txt_color);
%                 DrawFormattedText(window,data.resp2_txt(3),data.window(1)-resp1_nx1,'center',s.txt_color);
%                 DrawFormattedText(window,data.resp2_txt(4),data.window(1)-resp2_nx1,'center',s.txt_color);
%     
%     if GetSecs > data.onset_resp1{i,1}+s.resp1_max_t-2*flip_t %GetSecs-resp1_onset(i,1)-s.resp1_max_t+2*flip_t > 0
%         [data.onset_resp2{i,:}] = Screen('Flip',window);
%     else
%         [data.onset_resp2{i,:}] = Screen('Flip',window,data.onset_resp1{i,1}+s.resp1_max_t-flip_t);
%     end
%         
%     % Wait for key press
%     [data.resp2_btn(i,1),data.resp2_t(i,1),data.resp2_port(i,:)] = parallel_button(s.resp2_max_t,data.onset_resp2{i,1},s.resp_window,lpt);   
%     
%     
%     %%% ITI %%%
%     
%     Screen('TextSize',window,s.cue_size);
%     DrawFormattedText(window,s.ITI_cue,'center','center',s.txt_color);
%     [data.onset_ITI{i,:}] = Screen('Flip',window);

    
    %%% RESPONSE EVALUATION %%% (0.2-5.8 ms)
    
    % Response 1
    switch data.resp1_btn(i,1)
        case num2cell(s.btn_resp1)
            switch data.resp1_txt(s.btn_resp1==data.resp1_btn(i,1))
                case s.resp1_txt(1)
                    data.resp1(i,1) = 1; % yes
                case s.resp1_txt(2)
                    data.resp1(i,1) = 0; % no
            end
%         case s.btn_esc
%             break
        otherwise
            data.resp1(i,1) = 0;
    end             

%     % Response 2
%     switch data.resp2_btn(i,1)
%         case num2cell(s.btn_resp2)
%             data.resp2(i,1) = str2double(data.resp2_txt(s.btn_resp2==data.resp2_btn(i,1)));
% %         case s.btn_esc
% %             break
%         otherwise
%             data.resp2(i,1) = 0;
%     end
    
    
    %%% WAIT UNTIL TRIAL END - TR/2 %%%

    if i == size(data.seq,1)
        [data.onset_fix{i+1,:}] = Screen('Flip',window);
        data.wait_block_end = WaitSecs('UntilTime',data.onset_resp1{i,1}+s.resp1_max_t);
    end
    
end


%% End procedures

% Stop analog input recording
stop(ai);

% Close all screens
sca;


%% Error handling

catch lasterr
    stop(ai);
    sca;
    rethrow(lasterr);
end