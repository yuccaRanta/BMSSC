%    BMSSC - Bed Mattress Sleep Classifier for Infant Deep Sleep Detection
% Example usage
% Note! Requires Emfi piezoelectric Bed Mattress Sensor recording

% Place here your edf-file with a mattress sensor data
edffile='';

% This function creates a sleep trend and adds care period annotation
[classestimatesP,scoresP]=bmssc(edffile);

