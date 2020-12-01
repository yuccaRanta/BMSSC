function subject=notchbmssc(subject,varargin)
% LISENCE:
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
% 0) Input parser
p=inputParser;
defaultFreq=50;
defaultNotifications=true;
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG
validfreq=@(x) isnumeric(x) && x>0;

addRequired(p,'subject',validsubject);
addParameter(p,'freq',defaultFreq,validfreq)
addParameter(p,'notifications',defaultNotifications,@islogical)
parse(p,subject,varargin{:})

subject=p.Results.subject;

if p.Results.notifications
   fprintf('Preprocessing: Notch filtering power outlet...')
end


% -------------------------------------------------------------------------
% 1) Desing filters

% For BMS
if isfield(subject(1),'BMSsignal')&&~isempty(subject(1).BMSsignal{1}) % Only if there is BMS signal
    HdBMS=cell(numel(subject(1).BMSsignal),1);
    for i=1:numel(subject(1).BMSsignal)  % Generate Notch for each different BMS signal
        d  = fdesign.notch('N,F0,Q,Ap',6,p.Results.freq,10,1,subject(1).BMSinfo.fs);
        HdBMS{i}=design(d,'Systemobject',true);
    end
end

% For ECG
if isfield(p.Results.subject(1),'ECGsignal')&&~isempty(subject(1).ECGsignal) % Only if there is BMS signal
    d  = fdesign.notch('N,F0,Q,Ap',6,p.Results.freq,10,1,subject(1).ECGinfo.fs);
    Hdecg=design(d,'Systemobject',true);
end

% -------------------------------------------------------------------------
% 2) Filter subjects
lastsize=0;
if p.Results.notifications
    fprintf('\n')
end

for i=1:numel(p.Results.subject)
    
    if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('notchstim: iterating subjects %.0f%%',i/numel(subject)*100);
    end
    
    % Filter BMS
    if isfield(p.Results.subject(i),'BMSsignal')&&~isempty(p.Results.subject(i).BMSsignal{1})

        for j=1:numel(p.Results.subject(i).BMSsignal) 
            subject(i).BMSsignal{j}=filtfilt(HdBMS{j}.SOSMatrix,HdBMS{j}.ScaleValues,subject(i).BMSsignal{j});
            subject(i).BMSinfo.notch=1; % Adding indicator for notch
        end
    end
    
    % Filter ECG
    if isfield(p.Results.subject(i),'ECGsignal')&&~isempty(p.Results.subject(i).ECGsignal)
        subject(i).ECGsignal=filtfilt(Hdecg.SOSMatrix,Hdecg.ScaleValues,subject(i).ECGsignal);
        subject(i).ECGinfo.notch=1; % Adding indicator for notch
    end

end

if p.Results.notifications
    fprintf('\n...done.\n');
end
end
