function subject=rclbmssc(subject,varargin)
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
defaultPlot=true;       
defaultNotifications=true;
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG


addRequired(p,'subject',validsubject);
addParameter(p,'plotflag',defaultPlot,@islogical);
addParameter(p,'notifications',defaultNotifications,@islogical);

parse(p,subject,varargin{:})

%--------------------------------------------------------------------------
% Filtering
if p.Results.notifications
   fprintf('Preprocessing: respiratory cycle lenght...\n')
end
lastsize=0;

for i=1:numel(subject)
     if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('rclstim: iterating subjects %.0f%%',i/numel(subject)*100);
     end
     
     % Time
     LF=subject(i).BMSsignalLF;
     tempstarttime=strrep(subject(i).BMSinfo.starttime(1:8),'.',':');
     startvec=datevec(tempstarttime); % Vector time
     bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
     bmstime=(1:length(LF))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
     
     fullset=[];

     % Set flat to zero
     if isfield(subject(i).BMSinfo,'flat')
         for j=1:size(subject(i).BMSinfo.flat,1)
             I=(subject(i).BMSinfo.flat(j,1)<=bmstime)&(bmstime<=subject(i).BMSinfo.flat(j,2));

             LF(I)=0;
             fullset=[fullset;subject(i).BMSinfo.flat(j,1),subject(i).BMSinfo.flat(j,2)];
         end
     end
     % Set manual artefact to zero
     if isfield(subject(i).BMSinfo,'manualartefact')
         for j=1:size(subject(i).BMSinfo.manualartefact,1)
             I=(subject(i).BMSinfo.manualartefact(j,1)<=bmstime)&(bmstime<=subject(i).BMSinfo.manualartefact(j,2));

             LF(I)=0;
             fullset=[fullset;subject(i).BMSinfo.manualartefact(j,1),subject(i).BMSinfo.manualartefact(j,2)];
         end
     end
     
     % Set absence to zero
     if isfield(subject(i).BMSinfo,'absence')
         for j=1:size(subject(i).BMSinfo.absence,1)
             I=(subject(i).BMSinfo.absence(j,1)<=bmstime)&(bmstime<=subject(i).BMSinfo.absence(j,2));

             LF(I)=0;
             fullset=[fullset;subject(i).BMSinfo.absence(j,1),subject(i).BMSinfo.absence(j,2)];
         end
     end
     % Set movement to zero
     if isfield(subject(i).BMSinfo,'movement2')
         for j=1:size(subject(i).BMSinfo.movement2,1)
             I=(subject(i).BMSinfo.movement2(j,1)<=bmstime)&(bmstime<=subject(i).BMSinfo.movement2(j,2));

             LF(I)=0;
             fullset=[fullset;subject(i).BMSinfo.movement2(j,1),subject(i).BMSinfo.movement2(j,2)];
         end
     end
     % Find the respiration peaks
     [P,L]=findpeaks(LF,'MinPeakProminence',0.02,'MinPeakWidth',subject(i).BMSinfo.fs/4,'MinPeakDistance',subject(i).BMSinfo.fs*1);
     
     % Determine the intervals
     subject(i).RCL=determineintervals(bmstime(L),fullset);
     subject(i).BMSinfo.resppeaks=L;
     bmstime=seconds(bmstime);
     
     if p.Results.plotflag
        figure
        % Plot raw signal
        
        ax1=subplot(2,1,1);
        Y=subject(i).BMSsignal{1};
        bmsmin=min(Y)-10;
        bmsmax=max(Y)+10;
        hold on
        % Plot detected absence 

        for k=1:size(subject(i).BMSinfo.absence,1) % Plot the bad areas as gray

            X=[subject(i).BMSinfo.absence(k,1), subject(i).BMSinfo.absence(k,2),...
               subject(i).BMSinfo.absence(k,2),subject(i).BMSinfo.absence(k,1)];
            Xtimestr=seconds(X);
            Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
            fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
        end 

        for k=1:size(subject(i).BMSinfo.flat,1) % Plot the bad areas as gray

            X=[subject(i).BMSinfo.flat(k,1), subject(i).BMSinfo.flat(k,2),...
               subject(i).BMSinfo.flat(k,2),subject(i).BMSinfo.flat(k,1)];
            Xtimestr=seconds(X);
            Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
            fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
        end 



        %plot(bmstime,subject(i).BMSsignal{1},'linewidth',1.4,'color',[0    0.4470    0.7410])
        plot(bmstime,Y,'linewidth',1.4,'color',[0    0.4470    0.7410]);

        for k=1:size(subject(i).BMSinfo.movement2,1) % Plot the bad areas as gray

            X=[subject(i).BMSinfo.movement2(k,1), subject(i).BMSinfo.movement2(k,2),...
               subject(i).BMSinfo.movement2(k,2),subject(i).BMSinfo.movement2(k,1)];
            Xtimestr=seconds(X);
            Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
            fill(Xtimestr,Y2,[0.8500    0.3250    0.0980],'EdgeColor','none','FaceAlpha',.5)
        end 


        ylabel(subject(i).BMSinfo.units{1})
        %ylim([-50 50])
        xlim([bmstime(1)-minutes(1) bmstime(end)+minutes(1)]);
        title('BMS')
        hold off


        ax2=subplot(2,1,2);
        hold on
        for k=1:size(subject(i).BMSinfo.absence,1) % Plot the bad areas as gray
            X=[subject(i).BMSinfo.absence(k,1), subject(i).BMSinfo.absence(k,2),...
               subject(i).BMSinfo.absence(k,2),subject(i).BMSinfo.absence(k,1)];
            Xtimestr=seconds(X);
            Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
            fill(Xtimestr,Y2,[0 0 0],'EdgeColor','none','FaceAlpha',.3)
        end 

        plot(bmstime,LF,'linewidth',1.4,'color',[0.4940    0.1840    0.5560])
        plot(bmstime(L),P,'-o','linewidth',1.4,'color','k')
        for k=1:size(subject(i).BMSinfo.movement2,1) % Plot the bad areas as gray
            X=[subject(i).BMSinfo.movement2(k,1), subject(i).BMSinfo.movement2(k,2),...
               subject(i).BMSinfo.movement2(k,2),subject(i).BMSinfo.movement2(k,1)];
            Xtimestr=seconds(X);
            Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
            fill(Xtimestr,Y2,[0.8500    0.3250    0.0980],'EdgeColor','none','FaceAlpha',.5)
        end 
        %ylim([-2 2])
        linkaxes([ax1,ax2],'x')          

        suptitle(['Patient ',num2str(subject(i).ID)])
    end

    
end





if p.Results.notifications
    fprintf('\n...done.\n');
end

end

% =========================================================================
%   ADDITIONAL FUNCTIONS
% =========================================================================
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