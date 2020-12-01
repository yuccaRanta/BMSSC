function subject=presencebmssc(subject,varargin)
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
defaultPowerThreshold=-44; % RMS values lower than this are set as flat
defaultPowerWindowSize=10; % Size of power window (seconds)
defaultMinPresence=10*60;  % Time duration for presence (seconds)
defaultAbsenceBuffer=60;   % Buffer before and after absence period
defaultFreqRange=[6 16];   % The band window for power calculation (hz)
defaultPlot=false;       
defaultNotifications=false;
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG
validfreq=@(x) isvector(x) && (numel(x)==2);

addRequired(p,'subject',validsubject);
addParameter(p,'powerthreshold',defaultPowerThreshold,@isnumeric);
addParameter(p,'powerwindow',defaultPowerWindowSize,@isnumeric);
addParameter(p,'minpresence',defaultMinPresence,@isnumeric);
addParameter(p,'absencebuffer',defaultAbsenceBuffer,@isnumeric);
addParameter(p,'freqrange',defaultFreqRange,validfreq);
addParameter(p,'plotflag',defaultPlot,@islogical);
addParameter(p,'notifications',defaultNotifications,@islogical);

parse(p,subject,varargin{:})



minpresence=p.Results.minpresence/p.Results.powerwindow; % Convert to numer of powerwindows
subject=p.Results.subject;
%dummy
% p.Results.subject=subject;
% p.Results.powerthreshold=defaultPowerThreshold;
% p.Results.powerwindow=defaultPowerWindowSize;
% p.Results.minpresence=defaultMinPresence/p.Results.powerwindow;
% p.Results.freqrange=defaultFreqRange;
% p.Results.plotflag=defaultPlot;
if p.Results.notifications
   fprintf('Preprocessing: detecting precense...\n')
end
%%
lastsize=0;

for i=1:numel(subject)
    
    if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('presencestim: iterating subjects %.0f%%',i/numel(subject)*100);
    end
    
    if isfield(subject(i),'BMSsignal')
        
        % Detrend the signal
        detme=buffer(subject(i).BMSsignal{1},subject(i).BMSinfo.fs*5); % Final parameter is the window size
        for j=1:size(detme,2)
             detme(:,j)=detrend(detme(:,j));
        end
        Y=detme(:);
        BMSsignal=buffer(Y,subject(i).BMSinfo.fs*p.Results.powerwindow); % Final parameter is the window size
        BMSpower=10*log10(bandpower(BMSsignal,subject(i).BMSinfo.fs,p.Results.freqrange)); % Calculate the band power
        BMSpower=BMSpower(1:end-1);
        % Plot new density
        %plotkdensy(BMSpower,p.Results.subject(i).BMSinfo.starttime,p.Results.powerwindow,p.Results.subject(i))
        % Determining absence time windows from band power windows
        [absencewindows]=determineabsence(BMSpower,p.Results.powerthreshold,minpresence,...
            p.Results.subject(i).BMSinfo.starttime,p.Results.powerwindow,p.Results.absencebuffer);
        subject(i).BMSinfo.absence=absencewindows;
        
        % Plot for diagnostic
        if p.Results.plotflag
            figure
            % Plot raw signal
            ax1=subplot(2,1,1);
            startvec=datevec(subject(i).BMSinfo.starttime(1:8)); % Vector time
            bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
            bmstime=(1:length(subject(i).BMSsignal{1}))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
            bmstime=seconds(bmstime);
            
            bmsmin=min(subject(i).BMSsignal{1})-10;
            bmsmax=max(subject(i).BMSsignal{1})+10;
            hold on
            % Plot detected absence 

            for k=1:size(subject(i).BMSinfo.absence,1) % Plot the bad areas as gray

                X=[subject(i).BMSinfo.absence(k,1), subject(i).BMSinfo.absence(k,2),...
                   subject(i).BMSinfo.absence(k,2),subject(i).BMSinfo.absence(k,1)];
                Xtimestr=seconds(X);
                Y=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
            end 

            plot(bmstime,subject(i).BMSsignal{1},'linewidth',1.4)
            ylabel(subject(i).BMSinfo.units{1})
            %ylim([min(subject(i).BMSsignal{1})-10 max(subject(i).BMSsignal{1})+10])
            xlim([bmstime(1)-minutes(1) bmstime(end)+minutes(1)]);
            title('BMS')
            hold off
            
            % Plot power
            ax2=subplot(2,1,2);
            powertime=(1:length(BMSpower))*p.Results.powerwindow-p.Results.powerwindow+bmsstarttime;
            powertime=seconds(powertime);
            %BMSpower=BMSpower/(median(BMSpower));
            stairs([powertime,powertime(end)+(powertime(end)-powertime(end-1))],...
            [BMSpower,BMSpower(end)],'linewidth',1.4)
            hold on
            plot([min(bmstime)-minutes(1) max(bmstime)+minutes(1)],[p.Results.powerthreshold p.Results.powerthreshold],'color','red','linewidth',2)
            hold off
            title(['BMS power in ',num2str(p.Results.freqrange(1)),' to ',num2str(p.Results.freqrange(2)),'Hz'])  
            %ylim([-50 2])
            xlim([powertime(1)-minutes(1) bmstime(end)+(powertime(end)-powertime(end-1))+minutes(1)])
            xlabel('Time [sec]')
            
            linkaxes([ax1,ax2],'x')          
            
            suptitle(['Presence Patient ',num2str(p.Results.subject(i).ID)])
        end     
    end
    

end
if p.Results.notifications
    fprintf('\n...done.\n');
end

end

% -------------------------------------------------------------------------
% Local helper functions (2)
% -------------------------------------------------------------------------

% 1/2 Determine absense start and ends
function [absencewindows]=determineabsence(BMSpower,powerthreshold,minpresence,starttime,powerwindow,absebuffer)
% Calcualtes the absence periods from band power windows

BMSpowermask=BMSpower<=powerthreshold; % Windows where power below or same as allowed limit
if sum(BMSpowermask)>0
    BMSpowermask=fillmaskcaps(BMSpowermask,minpresence); % Fill the caps


    % Turn into [start end] timepoints (seconds)
    startvec=datevec(starttime(1:8)); % Vector time
    bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6);    % In seconds 
    bmstime=(1:numel(BMSpowermask))*powerwindow-powerwindow+bmsstarttime;% Time indexes as seconds
    absetime=bmstime(BMSpowermask);                               % Flat time index
    if numel(absetime)>1
        absencewindows=[absetime(1),nan];
        ii=1;
        for j=2:numel(absetime)
            if (absetime(j)-absetime(j-1)>powerwindow)||(j==numel(absetime)) % Check if not consecutive or not end
                if j==numel(absetime)                                        % End special case
                    absencewindows(ii,2)=absetime(j)+powerwindow;
                else
                    absencewindows(ii,2)=absetime(j-1)+powerwindow;
                    ii=ii+1;
                    absencewindows(ii,:)=[absetime(j),nan];
                end
            end
        end   

        % Buffer upstream
        absencewindows((absencewindows(:,1)-absebuffer)>bmstime(1),1)=...
            absencewindows((absencewindows(:,1)-absebuffer)>bmstime(1),1)-absebuffer;

        % Buffer downstream
        absencewindows((absencewindows(:,2)+absebuffer)<bmstime(end),2)=...
            absencewindows((absencewindows(:,2)+absebuffer)<bmstime(end),2)+absebuffer;
    else
        absencewindows=[];
    end
else
    absencewindows=[];
end

end

% 2/2 Fill the caps between binary mask

function binMASK=fillmaskcaps(binMASK,cap)
I=find(binMASK);           % Absence indexes

if I(1)~=1                 % Boundary effect start
    I=[1,I];          % Add first index
end
if I(end)~=length(binMASK) % Boundary effect end
    I=[I,length(binMASK)]; % Add last index
end

diffI=diff(I); 
diffII=find(diffI<=cap);
for j=1:numel(diffII)                                       % Merge close flats
    binMASK(I(diffII(j)):I(diffII(j)+1))=1;     % Set binary between adjacent absences
end

% Remove roque instances
A=diff([0,binMASK,0]);
binMASK((A(1:end-1)==1)&(A(2:end)==-1))=0;
end
