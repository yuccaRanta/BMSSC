function subject=movbmssc(subject,varargin)
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
defaultPowerThreshold=-0.5; % RMS values lower than this are set as flat
defaultPowerWindowSize=5; % Size of power window (seconds)
defaultMinPresence=10;  % Time duration for presence (seconds)
defaultAbsenceBuffer=60;   % Buffer before and after absence period
defaultFreqRange=[6 16];   % The band window for power calculation (hz)
defaultPlot=true;       
defaultNotifications=true;
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
%tigerth=-1;
tigerth=p.Results.tigerthreshold;
%%
lastsize=0;
if p.Results.notifications
   fprintf('Preprocessing: detecting movements...\n')
end

d1=fdesign.highpass('Fst,Fp,Ast,Ap',0.2,0.4,60,0.1,200); % Stop band, pass band, attunuation, pass ripple,  sampling freq
Hd1=design(d1,'butter');

for i=1:numel(subject)
    if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('movstim: iterating subjects %.0f%%',i/numel(subject)*100);
    end
        
        Y=filtfilt(Hd1.sosMatrix,Hd1.ScaleValues,subject(i).BMSsignal{1});
        BMSsignal=buffer(Y,subject(i).BMSinfo.fs*p.Results.powerwindow); % Final parameter is the window size
        BMSpower=log10(rms(BMSsignal)); % Calculate the band power
        BMSpower=BMSpower(1:end-1);
        [movwindows]=determinemovement(BMSpower,p.Results.powerthreshold,minpresence,...
            subject(i).BMSinfo.starttime,p.Results.powerwindow);
        subject(i).BMSinfo.movement=movwindows;
        
        
        if p.Results.plotflag
            figure
            startvec=datevec(subject(i).BMSinfo.starttime(1:8)); % Vector time
            bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
            %bmstime=(1:length(subject(i).BMSsignal{1}))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
            bmstime=(1:length(Y))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
            bmstime=seconds(bmstime);
            bmsmin=min(Y)-10;
            bmsmax=max(Y)+10;
            ax3=subplot(2,1,1);
            hold on
            % Plot detected absence 

            for k=1:size(subject(i).BMSinfo.absence,1) % Plot the bad areas as gray

                X=[subject(i).BMSinfo.absence(k,1), subject(i).BMSinfo.absence(k,2),...
                   subject(i).BMSinfo.absence(k,2),subject(i).BMSinfo.absence(k,1)];
                Xtimestr=seconds(X);
                Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
            end 
            


            %plot(bmstime,subject(i).BMSsignal{1},'linewidth',1.4,'color',[0    0.4470    0.7410])
            plot(bmstime,y2,'linewidth',1.4,'color',[0    0.4470    0.7410])
            
            for k=1:size(subject(i).BMSinfo.movement2,1) % Plot the bad areas as gray

                X=[subject(i).BMSinfo.movement2(k,1), subject(i).BMSinfo.movement2(k,2),...
                   subject(i).BMSinfo.movement2(k,2),subject(i).BMSinfo.movement2(k,1)];
                Xtimestr=seconds(X);
                Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y2,[0.8500    0.3250    0.0980],'EdgeColor','none','FaceAlpha',.5)
            end 
            
            
            ylabel(subject(i).BMSinfo.units{1})
            xlim([bmstime(1)-minutes(1) bmstime(end)+minutes(1)]);
            title('BMS')
            
            hold off
            
            ax4=subplot(2,1,2);
            powertime=(1:length(BMSpower2))*p.Results.powerwindow-p.Results.powerwindow+bmsstarttime;
            powertime=seconds(powertime);
            stairs([powertime,powertime(end)+(powertime(end)-powertime(end-1))],...
            [BMSpower2,BMSpower2(end)],'linewidth',1.4)
            hold on
            plot([min(bmstime)-minutes(1) max(bmstime)+minutes(1)],[tigerth tigerth],'color','red','linewidth',2)
            hold off
            title('BMS power ')  
            xlim([powertime(1)-minutes(1) bmstime(end)+(powertime(end)-powertime(end-1))+minutes(1)])
            xlabel('Time [sec]')        
            linkaxes([ax3,ax4],'x')
            suptitle(['Patient movement',num2str(subject(i).ID)])

        end     
end
if p.Results.notifications
    fprintf('\n...done.\n');
end
end

function [movwindows]=determinemovement(RMS,powerthreshold,minpresence,starttime,powerwindow)
% Calcualtes the absence periods from band power windows

BMSpowermask=RMS>=powerthreshold; % Windows where power below or same as allowed limit
if sum(BMSpowermask)>0
    BMSpowermask=fillmaskcaps(BMSpowermask,minpresence); % Fill the caps


    % Turn into [start end] timepoints (seconds)
    starttime=strrep(starttime,'.',':');
    startvec=datevec(starttime(1:8)); % Vector time
    bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6);    % In seconds 
    bmstime=(1:numel(BMSpowermask))*powerwindow-powerwindow+bmsstarttime;% Time indexes as seconds
    movtime=bmstime(BMSpowermask);                               % Flat time index
    if numel(movtime)>1
        movwindows=[movtime(1),nan];
        ii=1;
        for j=2:numel(movtime)
            cap=movtime(j)-movtime(j-1);
            if (cap>powerwindow)||(j==numel(movtime)) % Check if not consecutive or not end
                if j==numel(movtime)                   % End special case
                    if cap<powerwindow
                        movwindows(ii,2)=movtime(j)+powerwindow;
                    else
                        movwindows(ii,:)=[movtime(j),movtime(j)+powerwindow];
                    end
                else
                    movwindows(ii,2)=movtime(j-1)+powerwindow;
                    ii=ii+1;
                    movwindows(ii,:)=[movtime(j),nan];
                end
            end
        end   

%         % Buffer upstream
%         movwindows((movwindows(:,1)-absebuffer)>bmstime(1),1)=...
%             movwindows((movwindows(:,1)-absebuffer)>bmstime(1),1)-absebuffer;
% 
%         % Buffer downstream
%         movwindows((movwindows(:,2)+absebuffer)<bmstime(end),2)=...
%             movwindows((movwindows(:,2)+absebuffer)<bmstime(end),2)+absebuffer;
    else
        movwindows=[];
    end
else
    movwindows=[];
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


end 
