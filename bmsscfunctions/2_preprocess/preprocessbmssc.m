function subject=preprocessbmssc(subject,varargin)
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
% 0) Input parser
p=inputParser;
defaultNotifications=true;              % Show notifications [1,0] [true, false] - on by default
defaultManualArtefact={};

validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG

addRequired(p,'subject',validsubject);
addParameter(p,'notifications',defaultNotifications,@islogical)
addParameter(p,'manualartefact',defaultManualArtefact,@iscell)
parse(p,subject,varargin{:})

subject=p.Results.subject;

% -------------------------------------------------------------------------
% 1) Notch BMS and ECG - remove power outlet 
subject=notchbmssc(subject,'freq',50);
 
% % -------------------------------------------------------------------------
% % 2) BMS flat
subject=flatbmssc(subject,'plotflag',false);

% -------------------------------------------------------------------------
% 3) BMS anomaly - add manually artefact period - optional
subject=manualartefactbmssc(subject,'artefact',p.Results.manualartefact);

% -------------------------------------------------------------------------
% 4) BMS precense
subject=presencebmssc(subject,'plotflag',false);

% -------------------------------------------------------------------------
% 5) BMS movement
subject=movbmssc(subject,'plotflag',false);

% -------------------------------------------------------------------------
% 6) BMS band filtering
subject=bmsbandbmssc(subject);%,'plotflag',false);

% -------------------------------------------------------------------------
% 7) BMS recpiration cycle lenght (RCL)
subject=rclbmssc(subject,'plotflag',false);%,'plotflag',false);

% -------------------------------------------------------------------------
% 8) ECG heart beat intervals (HBI)
subject=hbibmssc(subject);%,'plotflag',false);

end

