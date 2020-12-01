function subject=manualartefactbmssc(subject,varargin)
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
defaultNotifications=false;
defaultArtefact={};
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG

addRequired(p,'subject',validsubject);
addParameter(p,'artefact',defaultArtefact,@iscell)
addParameter(p,'notifications',defaultNotifications,@islogical)
parse(p,subject,varargin{:})


subject=p.Results.subject;

% Set an artefact session manually 
if p.Results.notifications
   fprintf('Preprocessing: adding manually annotated artefacts...\n')
end
lastsize=0;
if ~isempty(p.Results.artefact)
    for i=1:numel(subject)

        if p.Results.notifications
            fprintf(repmat('\b', 1, lastsize));
            lastsize = fprintf('manualartefactstim: iterating subjects %.0f%%',i/numel(subject)*100);
        end

        if ~isempty(p.Results.artefact{i})
            subject(i).BMSinfo.manualartefact=p.Results.artefact{i};
        else
            subject(i).BMSinfo.manualartefact=[];
        end
    end
end
if p.Results.notifications
    fprintf('\n...done.\n');
end
end