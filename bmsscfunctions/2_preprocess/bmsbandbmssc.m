function subject=bmsbandbmssc(subject,varargin)
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
validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG


addRequired(p,'subject',validsubject);
addParameter(p,'plotflag',defaultPlot,@islogical);
addParameter(p,'notifications',defaultNotifications,@islogical);

parse(p,subject,varargin{:})

%--------------------------------------------------------------------------
% Filtering
if p.Results.notifications
   fprintf('Preprocessing: filtering...\n')
end
lastsize=0;

% Low frequency
butterorder=20;
d1=fdesign.bandpass('N,F3dB1,F3dB2',butterorder,0.2,1,200); 
Hd1=design(d1,'butter');

% Respiration
order=4;
framelen=subject(1).BMSinfo.fs*2+1;

order2=18;
framelen2=subject(1).BMSinfo.fs*4+1;


% High frequency
d2=fdesign.bandpass('N,F3dB1,F3dB2',butterorder,4,18,200);
Hd2=design(d2,'butter');

for i=1:numel(subject)
    
     if p.Results.notifications
         fprintf(repmat('\b', 1, lastsize));
         lastsize = fprintf('bmsbandstim: iterating subjects %.0f%%',i/numel(subject)*100);
     end
     
     % Low band
     subject(i).BMSsignalLF=filtfilt(Hd1.sosMatrix,Hd1.ScaleValues,subject(i).BMSsignal{1});
     
     % High band
     subject(i).BMSsignalHF=filtfilt(Hd2.sosMatrix,Hd2.ScaleValues,subject(i).BMSsignal{1});
     
     
     if p.Results.plotflag
            figure
            % Plot raw signal
            ax1=subplot(2,1,1);
            startvec=datevec(subject(i).BMSinfo.starttime(1:8)); % Vector time
            bmsstarttime=startvec(4)*60*60+startvec(5)*60+startvec(6); % In seconds 
            bmstime=(1:length(subject(i).BMSsignal{1}))/subject(i).BMSinfo.fs-1/subject(i).BMSinfo.fs+bmsstarttime;
            bmstime=seconds(bmstime);
            
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
            


            h1=plot(bmstime,subject(i).BMSsignal{1},'linewidth',1.4,'color',[0    0.4470    0.7410])
             
            h2=plot(bmstime,subject(i).BMSsignalLF,'linewidth',1.2,'color',[0.4940    0.1840    0.5560]);
            

            
            for k=1:size(subject(i).BMSinfo.movement2,1) % Plot the bad areas as gray

                X=[subject(i).BMSinfo.movement2(k,1), subject(i).BMSinfo.movement2(k,2),...
                   subject(i).BMSinfo.movement2(k,2),subject(i).BMSinfo.movement2(k,1)];
                Xtimestr=seconds(X);
                Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y2,[0.8500    0.3250    0.0980],'EdgeColor','none','FaceAlpha',.5)
            end 
            
            
            ylabel(subject(i).BMSinfo.units{1})
            ylim([-50 50])
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
            
            plot(bmstime,subject(i).BMSsignalHF,'color',[0.4940    0.1840    0.5560])
            
            for k=1:size(subject(i).BMSinfo.movement2,1) % Plot the bad areas as gray
                X=[subject(i).BMSinfo.movement2(k,1), subject(i).BMSinfo.movement2(k,2),...
                   subject(i).BMSinfo.movement2(k,2),subject(i).BMSinfo.movement2(k,1)];
                Xtimestr=seconds(X);
                Y2=[bmsmin-10, bmsmin-10, bmsmax+10, bmsmax+10];
                fill(Xtimestr,Y2,[0.8500    0.3250    0.0980],'EdgeColor','none','FaceAlpha',.5)
            end 
            ylim([-2 2])
            linkaxes([ax1,ax2],'x')          
            
            suptitle(['Subject ',num2str(subject(i).ID)])
     end
     
     
end

if p.Results.notifications
    fprintf('\n...done.\n');
end

end