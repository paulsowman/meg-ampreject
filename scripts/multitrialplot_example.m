
clear

%path to collab
base_path = '/cubric/collab/meg-cleaning/';
cd(base_path)

%task
task_label = 'restopen';

%path to data (.mat files)
data_path = fullfile(base_path, 'megpartnership', task_label, 'traindata');

%save paths
data_savepath = data_path;
fig_savepath = fullfile(base_path, 'megpartnership', task_label, 'trainfigures');

%list of files
dir_struct = dir(fullfile(data_path, 'sub-*_data.mat'));
file_list = {dir_struct(:).name}';
nsubj = length(file_list);

%%

%define subj from list
s = 1;
subj_label = strrep(file_list{s}, '_data.mat', '');

%load data
cd(data_path)
data = load(file_list{s});

%%

%low-pass filtering
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 4;
cfg.padding = 0.5*(abs(data.time{1}(end)-data.time{1}(1)))+abs(data.time{1}(end)-data.time{1}(1));
data_lp = ft_preprocessing(cfg,data);

%interactive multitrial plot
cfgplot = [];
cfgplot.title = 'bad trials marked in red';
cfgplot.drawnow = 'yes';
cfgplot.ylim = [];
cfgplot.chandownsamp = 4;
cfgplot.timedownsamp = 20;
cfgplot.badtrialscolor = [];
cfgplot.numrows = [];
cfgplot.numcolumns = [];

cfgplot.ylim = [-1 1]*5e-12;
cfgplot.interactive = 'yes';

%plot highpass trials
[badtrialsindex, h] = amprej_multitrialplot(cfgplot, data_lp);

%%

%high-pass filtering
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 60;
cfg.padding = 0.5*(abs(data.time{1}(end)-data.time{1}(1)))+abs(data.time{1}(end)-data.time{1}(1));
data_hp = ft_preprocessing(cfg,data);

%visualise previously marked bad trials
cfgplot.ylim = [-1 1]*2e-12;
cfgplot.badtrialsindex = badtrialsindex;
cfgplot.interactive = 'no';

%plot highpass trials
[badtrialsindex, h] = amprej_multitrialplot(cfgplot, data_hp);

%initialise interactive mode, if necessary
badtrialsindex = init_multitrialplot_interactive(cfgplot);

%%

%visualise previously marked bad trials
cfgplot.ylim = [-1 1]*5e-12;
cfgplot.badtrialsindex = badtrialsindex;
cfgplot.interactive = 'no';

%plot broadband trials
[badtrialsindex, h] = amprej_multitrialplot(cfgplot, data);

%initialise interactive mode, if necessary
badtrialsindex = init_multitrialplot_interactive(cfgplot);

%%

%save figure
saveas(gcf, fullfile(fig_savepath, [subj_label '_cls-multitrial.png']))

%save bad trials index
save(fullfile(data_savepath, [subj_label '_cls-multitrial.mat']), 'badtrialsindex')
