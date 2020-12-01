function subject=flatbmssc(subject,varargin)
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
defaultRMSThresholds=[0.01 30]; % RMS values lower than this are set as flat
defaultMaxCap=[30,30];      % Minimum limit (seconds) between flat segments before they get merged
defaultNotifications=true;
defaultPlot=false;
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG
validRMSandMax=@(x) isvector(x) && length(x)==2;

addRequired(p,'subject',validsubject);
addParameter(p,'rmsthreshold',defaultRMSThresholds,validRMSandMax)
addParameter(p,'maxcap',defaultMaxCap,validRMSandMax)
addParameter(p,'notifications',defaultNotifications,@islogical)
addParameter(p,'plotflag',defaultPlot,@islogical)
parse(p,subject,varargin{:})


subject=p.Results.subject;

if p.Results.notifications
   fprintf('Preprocessing: detecting flats...\n')
end

% -------------------------------------------------------------------------
% 1) Remove flat lines
lastsize=0;

for i=1:numel(subject)
    if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('flatstim: iterating subjects %.0f%%',i/numel(subject)*100);
    end
        
        BMSsignal=buffer(subject(i).BMSsignal{1},...
            round(subject(i).BMSinfo.fs)); % Window the signal into 1 sec non-overlapping segments
        BMSpower2=rms(BMSsignal); % Calculate rms
        BMSpower2=BMSpower2(1:end-1);
        [flatwindows]=determineflat(BMSpower2,p.Results.rmsthreshold(1),p.Results.maxcap(1),...
            subject(i).BMSinfo.starttime,1,5);
        subject(i).BMSinfo.flat=flatwindows;
        
        if isfield(p.Results.subject(i),'ECGsignal')&&~isempty(p.Results.subject(i).ECGsignal)
            ECGsignal=buffer(subject(i).ECGsignal,...
                          round(subject(i).ECGinfo.fs)); % Window the signal into 1 sec non-overlapping segments
            BMSpower=rms(ECGsignal);
            [flatwindows]=determineflat(BMSpower,p.Results.rmsthreshold(2),p.Results.maxcap(2),...
                subject(i).ECGinfo.starttime,1,2);
            subject(i).ECGinfo.flat=flatwindows;
        end
% %         figure
% %         plot(BMSpower2)
        if p.Results.plotflag
            figure
            % Plot raw signal
            ax1=subplot(1+isfield(p.Results.subject(i),'ECGsignal'),1,1);
            startvec=datevec(subject(i).BMSinfo.starttime(1:8)); % Vector time
            bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
            bmstime=(1:length(subject(i).BMSsignal{1}))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
            bmstime=seconds(bmstime);
            
            bmsmin=min(subject(i).BMSsignal{1})-10;
            bmsmax=max(subject(i).BMSsignal{1})+10;
            hold on
            % Plot detected flat
            for k=1:size(subject(i).BMSinfo.flat,1) % Plot the bad areas as gray

                X=[subject(i).BMSinfo.flat(k,1), subject(i).BMSinfo.flat(k,2),...
                   subject(i).BMSinfo.flat(k,2),subject(i).BMSinfo.flat(k,1)];
                Xtimestr=seconds(X);
                Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
            end 

            plot(bmstime,subject(i).BMSsignal{1},'linewidth',1.4,'color',[0    0.4470    0.7410])
            ylabel(subject(i).BMSinfo.units{1});ylim([-50 50]);xlim([bmstime(1)-minutes(1) bmstime(end)+minutes(1)]);title('BMS')
            hold off
            
            if isfield(p.Results.subject(i),'ECGsignal')
                ax2=subplot(2,1,2);
                startvec=datevec(subject(i).ECGinfo.starttime(1:8)); % Vector time
                ecgstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
                ecgtime=(1:length(subject(i).ECGsignal))/subject(i).ECGinfo.fs-1/subject(i).ECGinfo.fs+ecgstarttime;
                ecgtime=seconds(ecgtime);
                ecgmin=min(subject(i).ECGsignal)-10;
                ecgmax=max(subject(i).ECGsignal)+10;
                hold on
                % Plot detected flat
                for k=1:size(subject(i).ECGinfo.flat,1) % Plot the bad areas as gray
                    X=[subject(i).ECGinfo.flat(k,1), subject(i).ECGinfo.flat(k,2),...
                       subject(i).ECGinfo.flat(k,2),subject(i).ECGinfo.flat(k,1)];
                    Xtimestr=seconds(X);
                    Y2=[ecgmin-10, ecgmin-10, ecgmax+10, ecgmax+10];
                    fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
                end 

                plot(ecgtime,subject(i).ECGsignal,'linewidth',1.4,'color',[0    0.4470    0.7410])
                ylabel(subject(i).ECGinfo.units{1});ylim([-1000 1000]);xlim([ecgtime(1)-minutes(1) ecgtime(end)+minutes(1)]);title('ECG')
                hold off
                linkaxes([ax1,ax2],'x')
            end
            suptitle(['Patient ',num2str(p.Results.subject(i).ID)])
        end     
end

if p.Results.notifications
    fprintf('\n...done.\n');
end

end

function [flatwindows]=determineflat(RMS,powerthreshold,mindist,starttime,powerwindow,flatbuffer)
% Calcualtes the absence periods from band power windows

BMSpowermask=RMS<=powerthreshold; % Windows where power below or same as allowed limit
if sum(BMSpowermask)>0
    BMSpowermask=fillmaskcaps(BMSpowermask,mindist); % Fill the caps


    % Turn into [start end] timepoints (seconds)
    startvec=datevec(starttime(1:8)); % Vector time
    bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6);    % In seconds 
    bmstime=(1:numel(BMSpowermask))*powerwindow-powerwindow+bmsstarttime;% Time indexes as seconds
    flattime=bmstime(BMSpowermask);                               % Flat time index
    if numel(flattime)>1
        flatwindows=[flattime(1),nan];
        ii=1;
        for j=2:numel(flattime)
            cap=flattime(j)-flattime(j-1);
            if (cap>powerwindow)||(j==numel(flattime)) % Check if not consecutive or not end
                if j==numel(flattime)                   % End special case
                    if cap<powerwindow
                        flatwindows(ii,2)=flattime(j)+powerwindow;
                    else
                        flatwindows(ii,:)=[flattime(j),flattime(j)+powerwindow];
                    end
                else
                    flatwindows(ii,2)=flattime(j-1)+powerwindow;
                    ii=ii+1;
                    flatwindows(ii,:)=[flattime(j),nan];
                end
            end
        end   

        % Buffer upstream
        flatwindows(:,1)=flatwindows(:,1)-flatbuffer;
 

        % Buffer downstream
        flatwindows(:,2)=flatwindows(:,2)+flatbuffer;
    else
        flatwindows=[];
    end
else
    flatwindows=[];
end

end

% 2/2 Fill the caps between binary mask

function binMASK=fillmaskcaps(binMASK,mindist)
I=find(binMASK);           % Absence indexes

if I(1)~=1                 % Boundary effect start
    I=[1,I];          % Add first index
end
if I(end)~=length(binMASK) % Boundary effect end
    I=[I,length(binMASK)]; % Add last index
end

diffI=diff(I); 
diffII=find(diffI<=mindist);
for j=1:numel(diffII)                                       % Merge close flats
    binMASK(I(diffII(j)):I(diffII(j)+1))=1;     % Set binary between adjacent absences
end

end 




