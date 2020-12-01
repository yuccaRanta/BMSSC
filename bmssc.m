function  [classestimates,scores]=bmssc(edffile,varargin)
% BMSSC Bed Mattress Sensor Sleep Classifier for Infants
% Creates an sleep estimate from given bedmattress sensor edf-file (with one channel)
%
% [classestimatesP,scoresP]= BMSSC(edfdata) creates a sleep stage estimate 
%       for deep sleep. Returns classestimatesP where 0 - deep sleep and 
%       1 - other stages. scoresP gives the continues estimate for stage 
%       (distance from classification boundary) edffile is a string of given
%       edffile e.g. 'myrecord.edf'
% 
% LISENCE: MIT
%
% Copyright (c) 2020 Jukka Ranta jukka.r.ranta<at>helsinki.fi
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

% -------------------------------------------------------------------------
% 0. Input parser
p=inputParser;
defaultNotifications=false; % Show notifications [true, false] - off by default
defaultCarePeriod={};
defaultSignalName={'BCGRaw'};

addRequired(p,'edffile',@ischar);
addParameter(p,'notifications',defaultNotifications,@islogical)
addParameter(p,'careperiod',defaultCarePeriod,@iscell)
addParameter(p,'signalname',defaultSignalName,@iscell)
parse(p,edffile,varargin{:})


% -------------------------------------------------------------------------
% 1. Import edf-file
PATHS=cell(1,3);
PATHS{1,1}=p.Results.edffile;
subject=importdatabmssc(PATHS,'BMSName',p.Results.signalname,...
    'align',false,'notifications',p.Results.notifications);

% -------------------------------------------------------------------------
% 2. Preprocess signal(s)
subject=preprocessbmssc(subject);

% -------------------------------------------------------------------------
% 3. Calculate feature vectors
featureset=featuresbmssc(subject);
featureset.values(:,(isnan(sum(featureset.values))))=0; 

% -------------------------------------------------------------------------
% 4. Classify
load('bmssc_svm.mat') % HERE IS THE SVM CLASSIFIER
[classestimates,scores]=classifybmssc(svm,featureset);


