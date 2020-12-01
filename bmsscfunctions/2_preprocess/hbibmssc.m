function subject=hbibmssc(subject,varargin)
% Calculate heart beat interval time series
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

%--------------------------------------------------------------------------
% Input parser
p=inputParser;
defaultPlot=false;       
defaultNotifications=true;
defaultECGRamplitude=200; % Minimum R-peak amplitude voltage
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG


addRequired(p,'subject',validsubject);
addParameter(p,'plotflag',defaultPlot,@islogical);
addParameter(p,'notifications',defaultNotifications,@islogical);
addParameter(p,'minR',defaultECGRamplitude,@isnumeric)

parse(p,subject,varargin{:})

%--------------------------------------------------------------------------
% Filtering
if p.Results.notifications
   fprintf('Preprocessing: Calculating heart beat intervals...\n')
end
lastsize=0;

for i=1:numel(subject)
     if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('hbistim: iterating subjects %.0f%%',i/numel(subject)*100);
     end
     
     if isfield(subject(i),'ECGsignal')&&~isempty(subject(i).ECGsignal)
     
         % Time
         
         ECG=subject(i).ECGsignal;
         tempstarttime=strrep(subject(i).ECGinfo.starttime(1:8),'.',':');
         startvec=datevec(tempstarttime); % Vector time
         ecgstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
         ecgtime=(1:length(ECG))/subject(i).ECGinfo.fs-1/subject(i).ECGinfo.fs+ecgstarttime;
         

         
         ECG=setzero(ECG,ecgtime,subject(i).ECGinfo.flat,subject(i).ECGinfo.artefact);
         [RRpeaks,ex]=pantombmssc(ECG);
      
         % Determine missed peaks - if HBI too long
         dRR=diff(RRpeaks);
         fracRR=dRR(2:end)./dRR(1:end-1);
         missedI=(1.8<fracRR);
         missedI=[false,missedI];
         shortpeaks1=RRpeaks(1:end-1);
         shortpeaks2=RRpeaks(2:end);
         missedstart=shortpeaks1(missedI)+5; %
         missedend=shortpeaks2(missedI)-5;
         missedend=ecgtime(missedend);
         missedstart=ecgtime(missedstart);
         
         MissedPeak=[missedstart',missedend'];
         subject(i).ECGinfo.missedpeak=MissedPeak;
         
         % Collect all the artefacts
         fullset=[MissedPeak];
         if isfield(subject(i).ECGinfo,'flat')&&~isempty(subject(i).ECGinfo.flat)
             fullset=[fullset;subject(i).ECGinfo.flat];
         end
         if isfield(subject(i).ECGinfo,'artefact')&&~isempty(subject(i).ECGinfo.artefact)
             fullset=[fullset;subject(i).ECGinfo.artefact];
         end
         
         
         subject(i).HBI=determineintervals(ecgtime(RRpeaks),fullset);
         subject(i).ECGinfo.RRpeaks=RRpeaks;

         if p.Results.plotflag
            figure
            ax=subplot(2,1,1);
            % Plot raw signal
            ecgtime=seconds(ecgtime);
            ecgmin=min(ECG)-10;
            ecgmax=max(ECG)+10;
            hold on
            % Plot detected flat
            
            for k=1:size(subject(i).ECGinfo.flat,1) % Plot the bad areas as gray
                X=[subject(i).ECGinfo.flat(k,1), subject(i).ECGinfo.flat(k,2),...
                   subject(i).ECGinfo.flat(k,2),subject(i).ECGinfo.flat(k,1)];
                Xtimestr=seconds(X);
                Y2=[ecgmin-10, ecgmin-10, ecgmax+10, ecgmax+10];
                fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
            end 
            

            plot(ecgtime,ECG,'linewidth',1.4,'color',[0    0.4470    0.7410])
            plot(ecgtime(RRpeaks),ECG(RRpeaks),'-o','linewidth',1.4,'color','k')
            
            for k=1:size(MissedPeak,1) % Plot the bad areas as gray
                X=[MissedPeak(k,1), MissedPeak(k,2),...
                   MissedPeak(k,2),MissedPeak(k,1)];
                Xtimestr=seconds(X);
                Y2=[ecgmin-10, ecgmin-10, ecgmax+10, ecgmax+10];
                fill(Xtimestr,Y2,[0.6350    0.0780    0.1840],'EdgeColor','none','FaceAlpha',.6)
            end 
            
            ylabel(subject(i).ECGinfo.units{1});ylim([-1000 1000]);xlim([ecgtime(1)-minutes(1) ecgtime(end)+minutes(1)]);title('ECG')
            hold off
            ax2=subplot(2,1,2);
            plot(ecgtime,ex)
            linkaxes([ax,ax2],'x')
        end
      end
    
 end

if p.Results.notifications
    fprintf('\n...done.\n');
end

end




% =========================================================================
%   ADDITIONAL FUNCTIONS
% =========================================================================


function ECG=setzero(ECG,ecgtime,flat,artefact)
% Sets the artefacts to zero

for i=1:size(flat,1)
     I=(flat(i,1)<=ecgtime)&(ecgtime<=flat(i,2));
     ECG(I)=0;
end

for i=1:size(artefact,1)
     I=(artefact(i,1)<=ecgtime)&(ecgtime<=artefact(i,2));
     ECG(I)=0;
end

end


function [ibi]=determineintervals(peaktime,fullset)
% Determines the inter breath intervals
% Calculate ibi
ibiD=peaktime(2:end)-peaktime(1:end-1);
ibi=[ibiD;peaktime(2:end)];

if ~isempty(fullset)
    % Sort the set
    [~,I]=sort(fullset(:,1));
    fullset=fullset(I,:);

    % Merge the overlapping segments
    newset=[];
    newset=[fullset(1,1),nan];
    ii=1;
    lastend=fullset(1,2);
    for i=2:size(fullset,1)
        if (lastend<fullset(i,1))||(i==size(fullset,1)) % If next start is not within or we at end 
            newset(ii,2)=lastend;
            if i<size(fullset,1) % We are not at the end yet
                ii=ii+1;
                newset(ii,1)=fullset(i,1);
                lastend=fullset(i,2);
            end
            
        end
        
    end

    % Remove ibis that are on different sides of artefacts
    remI=[];
    for i=1:size(newset,1)
        [~,ii]=find(newset(i,2)<ibi(2,:),1); % The first peak after interval (ibi over interval)
        remI=[remI,ii]; % remove the interval
    end
    ibi(:,remI)=[];
end




end