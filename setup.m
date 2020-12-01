% Install mscrfeatures.m
% Adds the mscrfeatures.m and all relevant helper function into Matlab
% search path

path(path,genpath(fileparts(which(mfilename))))