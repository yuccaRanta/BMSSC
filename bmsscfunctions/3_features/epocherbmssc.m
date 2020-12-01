function epochs=epocherbmssc(patient,signalname,epochparam)
% EPOCHERSTIM calculates returns epochs matrix of the chosen signal
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
p=inputParser;
validpatient=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG

addRequired(p,'patient',validpatient);
addRequired(p,'signalname',@ischar);
addRequired(p,'epochparam',@isnumeric);

parse(p,patient,signalname,epochparam)
epochparam=p.Results.epochparam;
patient=p.Results.patient;


if isfield(patient,'hypnogram') && ~isempty(patient.hypnogram)
    % If there is refernce hypnogram
    switch lower(p.Results.signalname)
        case 'bmssignal'
            [signal,stime]=setnan(patient.BMSsignal{1},patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'bmssignalhf'
            [signal,stime]=setnan(patient.BMSsignalHF,patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'bmssignallf'
            [signal,stime]=setnan(patient.BMSsignalLF,patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'rcl'
            myseries=patient.RCL;
            epochs=seriesbuffer(myseries,patient.BMSsignal{1},patient.BMSinfo.starttime,patient.BMSinfo.fs,epochparam(1:3));
        case 'hbi'
            myseries=patient.HBI;
            epochs=seriesbuffer(myseries,patient.ECGsignal,patient.ECGinfo.starttime,patient.ECGinfo.fs,epochparam(1:3));
        otherwise
            error('epocherstim: incorrect signal')
    end
    
else
    % There are no reference
    switch lower(p.Results.signalname)
        case 'bmssignal'
            [signal,stime]=setnan(patient.BMSsignal{1},patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'bmssignalhf'
            [signal,stime]=setnan(patient.BMSsignalHF,patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'bmssignallf'
            [signal,stime]=setnan(patient.BMSsignalLF,patient.BMSinfo,epochparam(4));
            epochs=mybuffer(signal,patient.BMSinfo.fs,epochparam(1:3));%stime,patient.hypnogram);
        case 'rcl'
            myseries=patient.RCL;
            epochs=seriesbuffer(myseries,patient.BMSsignal{1},patient.BMSinfo.starttime,patient.BMSinfo.fs,epochparam(1:3));
        case 'hbi'
            myseries=patient.HBI;
            epochs=seriesbuffer(myseries,patient.ECGsignal,patient.ECGinfo.starttime,patient.ECGinfo.fs,epochparam(1:3));
        otherwise
            error('epocherstim: incorrect signal')
    end
    
end
end

% =========================================================================
%   ADDITIONAL FUNCTIONS
% =========================================================================
function [signal,stime]=setnan(signal,sinfo,param)
% Sets the samples with artefacts to nan 
%
% SETNAN(signal,sinfo,starttime,fs,param,flag) calculates the time instances
%   stime for signal and takes the artefact time periods from artefacts matrix 
%   and sets the signal to nan in these periods. sinfo same as .BSMinfo or
%   .ECGinfo. fs sampling frequency, starttime as string HH:MM:SS. param in
%   [0,1,2] indicates 0=> set movement to nan, 1=> set
%   non-movement to nan, 2=> intact signal, 


% Determine time in seconds from start of day
starttime=sinfo.starttime;
starttime=strrep(starttime,'.',':');
fs=sinfo.fs;
startT=datevec(['19.05.2000 ',starttime(1:8)]);
startT=startT(4)*3600+startT(5)*60+startT(6);
stime=(1:length(signal))/fs-1/fs+startT;

% Set flat to nan
if isfield(sinfo,'flat')&&~isempty(sinfo.flat)
    for i=1:size(sinfo.flat,1)
        signal((sinfo.flat(i,1)<=stime)&(stime<=sinfo.flat(i,2)))=nan;
    end
end

% Set absence to nan
if isfield(sinfo,'absence')&&~isempty(sinfo.absence)
    for i=1:size(sinfo.absence,1)
        signal((sinfo.absence(i,1)<=stime)&(stime<=sinfo.absence(i,2)))=nan;
    end
end

% Set manualartefact to nan
if isfield(sinfo,'manualartefact')&&~isempty(sinfo.manualartefact)
    for i=1:size(sinfo.manualartefact,1)
        signal((sinfo.manualartefact(i,1)<=stime)&(stime<=sinfo.manualartefact(i,2)))=nan;
    end
end

% Handle movement 
if (param==0)&&isfield(sinfo,'movement2')&&~isempty(sinfo.movement2)
    for i=1:size(sinfo.movement2,1)
        signal((sinfo.movement2(i,1)<=stime)&(stime<=sinfo.movement2(i,2)))=nan;
    end

elseif (param==1)&&isfield(sinfo,'movement2')&&~isempty(sinfo.movement2)
    MASK=zeros(1,length(signal));
    for i=1:size(sinfo.movement2,1)
        MASK((sinfo.movement2(i,1)<=stime)&(stime<=sinfo.movement2(i,2)))=1;
    end
    signal(MASK==0)=nan;
end
    



end

function epochs=mybuffer(signal,fs,settin)%)stime,hypnogram)
% Creates a matrix out of given signal
% - TODO!!! TAKE THE TIMES FROM HYPNOGRAM

% Phase one - simple matrix
epochs1=buffer(signal,settin(2)*fs*30);

epochs=epochs1;

zeroepochs=zeros(size(epochs));

% Phase two - stack shorter epochs to larger
for i=1:settin(1) % Preceeding epochs
    epochs=[zeroepochs(:,1:i),epochs1(:,1:end-i);epochs];
end

for i=1:settin(3) % Proceeding epochs
    epochs=[epochs;epochs1(1+i:end),zeroepochs(:,1:i)];
end

end

function epochs=seriesbuffer(myseries,signal,starttime,fs,settin)
% Creates an epoch matrix from HBI or RCL data
% Determine time in seconds from start of day
starttime=strrep(starttime(1:8),'.',':');
startT=datevec(['19.05.2000 ',starttime(1:8)]);
startT=startT(4)*3600+startT(5)*60+startT(6);
stime=(1:length(signal))/fs-1/fs+startT;

epochs1=mybuffer(stime,fs,settin);

epochs={};
for i=1:size(epochs1,2)
    epochs{1,i}=myseries(1,(epochs1(1,i)<myseries(2,:))&(myseries(2,:)<epochs1(end,i)))';
end

end