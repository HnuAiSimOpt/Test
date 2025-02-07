job_title = 'several_cracks/edge/vertical_tension';
path_main = fileparts(which('call_main.m'));
if isempty(path_main); error('path_main?');
else addpath(path_main); end

if ~exist('job_title','var') || isempty(job_title)
   job_title = input;
end

path_jobsLib = [path_main,'/JOBS_LIBRARY'];
path_jobsOut = [path_main,'/JOBS_RESULTS'];
job_srcdir = [path_jobsLib,'/',job_title];
job_outdir = [path_jobsOut,'/',job_title];
job_main_m = [job_srcdir,'/JOB_MAIN.m'];
job_input_m = [job_srcdir,'/JOB_INPUT.m'];

addpath(genpath(path_jobsLib));
rmpath(genpath(path_jobsLib));
addpath(genpath(job_srcdir));
run(job_main_m); 