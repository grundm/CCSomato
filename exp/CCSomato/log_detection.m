function log_detection(psi_data,exp_data)
% detection_log(psi_data,exp_data) displays the applied intensities and 
% their detection rates in the experimental block, as well as the expected
% detection rates based on the estimated psychometric function in psi_1AFC.
%
% Input:
%   psi_data        - output of threshold assessment psi_1AFC
%   exp_data        - output of experimental block (run_exp)
%
% Author:           Martin Grund
% Last update:      October 21, 2016

% Display block number
disp(['Block #' num2str(exp_data.seq(1,1))]);

% Calculate detection rates for all intensities in experiment
nt_detection = count_resp([exp_data.intensity exp_data.resp1]);
    
% Display expected detection rates
arrayfun(@(intensity) disp(['PF(' num2str(intensity) ' mA) = ' num2str(PAL_Quick(psi_data.PF_params_PM,intensity))]), nt_detection(:,1));
    
% Display actual detection rates
disp(nt_detection);