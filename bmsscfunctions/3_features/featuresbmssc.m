function featureset=featuresbmssc(subject,varargin)
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

validsubject=@(x) isstruct(x) && (isfield(x,'BMSsignal')||isfield(x,'ECGsignal')); % Need to be struct and have BMS or ECG

addRequired(p,'subject',validsubject);
addParameter(p,'notifications',defaultNotifications,@islogical)
parse(p,subject,varargin{:})

subject=p.Results.subject;

% -------------------------------------------------------------------------
% Add feature functions into path
if ~(exist('features','dir')==7)
    error('featuresbmssc: feature vector folder "features" missing')
end

% -------------------------------------------------------------------------
% Add default feature calculation setttings
defaultsettingsrespi % For respiration features only

% -------------------------------------------------------------------------
% Feature function handles
featurefunctions1={@mean,@median,@var,@coefvar,@std,@skewness,@kurtosis,@hjorthmob,...
    @hjorthcomp,@peakmedian,@peakstd,@troughmedian,@troughstd,@dma,@dva,@dmt,@dvt,...
    @zeroca,@zerocb,@zerocc,@envelopestd,@rmsec,@pow,@firstspectralmoment,@secondspectralmoment,...
    @spectralentropy,@H3Z6,@lfhf,@lfvlh,@hfvlf,@modhf,@phf,@sampen,@fuzzyen,@hurst,...
    @lyapunov,@irri,...
    @modefreq,@modelevel,@modew,@modeprom,@modeautoc,@modeautocf,@rmssd};

% Feature names
featurenames={'M','MED','VAR','COFV','STD','SKEW','KURT','MOB','COMP','PM',...
    'PSTD','TM','TSTD','DMA','DVA','DMT','DVT','ZRCA','ZRCB','ZRCC','ESTD',...
    'RMSEC','POW','M1','M2','SE','H3Z6','LF/HF','LF/VLF','HF/VLF','MODHF','PHF',...
    'SampE','FuzE','HE','LE','IRRI',...
    'MOF','MOL','MOW','MOP','MAU','MAUF','RMSSD'};


% -------------------------------------------------------------------------
% Calculate the features for subjects
featureset(numel(subject))=struct(); % Collection of features
featureset(1).values=[];
featureset(1).names={};

if p.Results.notifications
   fprintf('Feature calculation: calculating...\n')
end

for i=1:numel(subject)
    if p.Results.notifications
         %fprintf(repmat('\b', 1, lastsize));
         fprintf('featuresbmssc: iterating subjects %.0f%%\n',i/numel(subject)*100);
         %lastsize = fprintf('featurestim: iterating subjects %.0f%%',i/numel(subject)*100);
    end
    lastsize=0;
    for j=1:numel(featurefunctions1) % Calculate the feature and update featureset
        tic
        if p.Results.notifications
            fprintf(repmat('\b', 1, lastsize));
            lastsize=fprintf(['feature ',num2str(j),' of ',num2str(numel(featurefunctions1)),' possible']);
        end
        featureset(i)=featcalculatorbmssc(featurefunctions1{j},subject(i),...
            featureset(i),featsettings(j),featparams(j),featurenames{j});

    end
    
    if p.Results.notifications
        fprintf('\n')
    end
    
end


% Log-modulus, Z-score normalization and handling missing values
load('logmFnames.mat')
[featureset,logmFnames]=postprosfeatbmssc(featureset,logmFnames);

% Add hypnogram and other data
featureset=addinfosbmssc(featureset,subject);


if p.Results.notifications
    fprintf('\n...done.\n');
end


end

% =========================================================================
% Additional functions
% =========================================================================
function featureset=replaceinfty(featureset)
% This function sets the infinity values to max non inf value
for i=1:numel(featureset)
    for j=1:numel(featureset(i).names)
        % Infinity indexes and replace them with max value
        temp=featureset(i).values(:,j);
        I=isinf(temp);
        sV=sign(temp);
        temp(I)=[];
        featureset(i).values(I&(sV==1),j)=max(temp);
        featureset(i).values(I&(sV==-1),j)=min(temp);
    end
end
end

function [featureset,logmFnames]=postprosfeatbmssc(featureset,logmFnames)
% POSTPROSFEATSTIM(featureset)parses missing values for nan epochs. If
% feature is from movement segment then it is set to zero. Else linear
% interpolation is made for the missing value. Also subjectwise z-score
% normalization is applied.

featureset=replaceinfty(featureset);

[featureset,logmFnames]=checklogmodulusnorm(featureset,logmFnames);

for i=1:numel(featureset)
    
    for j=1:numel(featureset(i).names)
          
        % z-score normalization
        I=~isnan(featureset(i).values(:,j)); % Only for non-nan values
        featureset(i).values(I,j)=(featureset(i).values(I,j)-mean(featureset(i).values(I,j)))/std(featureset(i).values(I,j));
        
        % Sampling the missing
        if  strcmp(featureset(i).names{j}(end-3:end),'pres') % Calculated from movements etc.
            featureset(i).values(I==0,j)=0; % Set the missing values to zero
        else % Otherwise linear interpolation
            % Boundary effect set first and last value same as last closest
            % observed value
            if isnan(featureset(i).values(1,j))
                ifn=find(~isnan(featureset(i).values(:,j)),1,'first');
                if ~isempty(ifn)
                    featureset(i).values(1,j)=featureset(i).values(ifn,j);
                end
            end
            if isnan(featureset(i).values(end,j))
                iln=find(~isnan(featureset(i).values(:,j)),1,'last');
                if ~isempty(iln)
                    featureset(i).values(end,j)=featureset(i).values(iln,j);
                end
            end
            % Linaer interpolation to rest
            featureset(i).values(:,j)=fillmissing(featureset(i).values(:,j),'linear');
        end
        
    end
    
end

end

% --- check for log -modulus normalization
function [featureset,logmFnames]=checklogmodulusnorm(featureset,logmFnames)
% Checks if the feature values need to be log normalized

% Vote for log-modulus transformed features
if isnumeric(logmFnames)
    DM=zeros(numel(featureset),numel(featureset(1).names));
    for i=1:numel(featureset)
        for j=1:numel(featureset(i).names)
            I=~isnan(featureset(i).values(:,j)); % Only for non-nan values
            % Quartiles
            [Q]=quantile(featureset(i).values(I,j),[0.25,0.75]);
            % Mean
            meanf=mean(featureset(i).values(I,j));
            % Log modulus scaling
            meanf=sign(meanf)*log10(abs(meanf));
            Q(1)=sign(Q(1))*log10(abs(Q(1))+1);
            Q(2)=sign(Q(2))*log10(abs(Q(2))+1);
            % If the mean values is one magnitude away from the quartiles
            if (meanf<Q(1)-1)||(Q(2)+1<meanf) 
                % Set for log-modulus scaling
                DM(i,j)=1;
           end
        end
    end

    II=sum(DM)>0.60*numel(featureset); % If over than 60% subjects qualify -> set for transformation
    logmFnames=featureset(1).names(II);
else
    II=ismember(featureset(1).names,logmFnames);
end
for i=1:numel(featureset)
    for j=1:numel(featureset(i).names)
        I=~isnan(featureset(i).values(:,j)); % Only for non-nan values
        % If the mean values is one magnitude away from the quartiles
        if II(j)
            % Set for log-modulus scaling
            featureset(i).values(I,j)=sign(featureset(i).values(I,j)).*log10(abs(featureset(i).values(I,j))+1);
       end
    end
end



end
% ---

function featureset=addinfosbmssc(featureset,subject)
% Adds relevant info to featureset
for i=1:numel(subject)
    % HYPNOGRAM
    if isfield(subject(i),'hypnogram')&&~isempty(subject(i).hypnogram)
        featureset(i).hypnogram=subject(i).hypnogram;
    end
    
    % ARTEFACTS BMS
    if isfield(subject(i),'BMSinfo')&&~isempty(subject(i).BMSinfo)
        featureset(i).startdate=subject(i).BMSinfo.startdate;
        featureset(i).starttime=subject(i).BMSinfo.starttime;
        
        % Flat
        if isfield(subject(i).BMSinfo,'flat')&&~isempty(subject(i).BMSinfo.flat)
            featureset(i).artefact.BMSflat=subject(i).BMSinfo.flat;
        end
        
        % Absence
        if isfield(subject(i).BMSinfo,'absence')&&~isempty(subject(i).BMSinfo.absence)
            featureset(i).artefact.absence=subject(i).BMSinfo.absence;
        end
        
        % Movement
        if isfield(subject(i).BMSinfo,'movement2')&&~isempty(subject(i).BMSinfo.movement2)
            featureset(i).artefact.movement=subject(i).BMSinfo.movement2;
        end
        
        % Manual artefact
        if isfield(subject(i).BMSinfo,'manualartefact')&&~isempty(subject(i).BMSinfo.manualartefact)
            featureset(i).artefact.manual=subject(i).BMSinfo.manualartefact;
        end
    end
    
    % ATRTEFACTS ECG
    if isfield(subject(i),'ECGinfo')&&~isempty(subject(i).ECGinfo)      
        % Flat
        if isfield(subject(i).ECGinfo,'flat')&&~isempty(subject(i).ECGinfo.flat)
            featureset(i).artefact.ECGflat=subject(i).ECGinfo.flat;
        end
        
        % Absence
        if isfield(subject(i).BMSinfo,'artefact')&&~isempty(subject(i).ECGinfo.artefact)
            featureset(i).artefact.ECGartefact=subject(i).ECGinfo.artefact;
        end
     end
    
end
end