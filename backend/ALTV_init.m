function settings = ALTV_init(data)

% Handles
settings.daq = DaqDeviceIndex;

% General
if data.training == 0
    settings.general.blocks = 8;
    settings.general.trials = 60; % per block
    settings.general.nov = 1/5; % ratio of novelty (haptic) trials
    settings.general.nogo = 1/3; % ratio of nogo trials
else
    settings.general.blocks = 1;
    settings.general.trials = 15;
    settings.general.nov = 0;
    settings.general.nogo = 1/3;
end

% DAQ
settings.daq = DaqDeviceIndex;

% Durations
settings.duration.deadline = .5;
settings.duration.deadlineadjust = .05;
settings.duration.iti = .8;
settings.duration.fixation = .5;
settings.duration.post_check = .5;
settings.duration.delay = .05;
settings.duration.cue = .2;

% Screen
[settings.screen.outwindow, settings.screen.outwindowdims] = screenit;

% Layout
settings.layout.color.bg = [0 0 0];
settings.layout.size.offset = 150; % Stim Offsets (in pixels)
settings.layout.color.text = [255 255 255]; % white
settings.layout.color.feedback = [255 0 0]; % red
Screen(settings.screen.outwindow,'TextFont','Arial');
Screen('TextSize', settings.screen.outwindow, 42);
settings.layout.color.options = [0 255 0; 255 0 0; 0 0 255; 255 255 0; 255 0 255; 0 255 255; ...
              255 127 0; 127 255 0; 127 0 255; 255 255 127; 255 127 255; 127 255 255; ...  
              255 0 127; 0 255 127; 0 127 255]; % green = 1

% Blockfeedback calculations function handles
settings.blocktrials = @(trialseq,id,it) trialseq(trialseq(:,id.block) == trialseq(it,id.block),:);
settings.goTrials = @(blocktrials,id) blocktrials(blocktrials(:,id.go) == 1,:);
settings.nogoTrials = @(blocktrials,id) blocktrials(blocktrials(:,id.go) == 0,:);
settings.correctTrials = @(blocktrials,id) blocktrials(blocktrials(:,id.acc) == 1,:);
settings.missError = @(goTrials,id) 100 * ((sum(goTrials(:,id.acc) == 2 | goTrials(:,id.acc) == 99)) / size(goTrials,1));
settings.RT = @(correctTrials,id) mean(correctTrials(:,id.rt));
settings.succstop = @(nogoTrials,id) 100 * (sum(nogoTrials(:,id.acc) == 4) / size(nogoTrials,1));
settings.currentBlock = @(blocktrials,id) blocktrials(end,id.block);
settings.strings = {'Block # ', 'RT: ', '% Misses/Errors: ', '% Successful Stops: '};

% KEYBOARD / MOUSE
HideCursor; ListenChar(2);
KbName('UnifyKeyNames');

% BUTTON MAP
if data.buttons == 1
    settings.general.buttons = {'W','M'};
else
    settings.general.buttons = {'M','W'};
end

% SAVE INFO
[settings.files.infolder,settings.files.outfolder,settings.files.outfile] = glo_save('ALTV.m', 'out', data.nr);
