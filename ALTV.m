 % % % % % % % % % % % % % % % % % % % % % % % %  
%    ALT-V (Version 3 from ALT)                  %
%    Program Written by: Alec Mather - Nov. 2018 %
%    Professor In charge: Jan Wessel             %
%    Tools: Matlab/Psychtoolbox                  %
 % % % % % % % % % % % % % % % % % % % % % % % % 

% Clean up
clear;clc
commandwindow;

% MacOS Specific
Screen('Preference', 'SkipSyncTests', 1);

% INITIALIZE
addpath(genpath(fileparts(which('ALTV.m'))));

% DESCRIPTIVES
data = ALTV_data;

% INITIALIZE
settings = ALTV_init(data);

% TRIAL SEQUENCE
trialseq = ALTV_sequence(settings,data);

% TRIALS
trialseq = ALTV_backend(settings,trialseq,data);

Screen('CloseAll');