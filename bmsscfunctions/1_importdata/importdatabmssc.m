function subject=importdatabmssc(PATHS,varargin)
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
defaultBMSName={'Patja_LF','Patja_HF'}; % Default BMS channel names
defaultECGName={'EKG','ECG'};           % Default ECG channel name (either one) 
defaultStages={'W','SLEEP-S0';'R','SLEEP-REM';'N1','SLEEP-S1';'N2','SLEEP-S2';'N3','SLEEP-S3'}; % Default names sleep stages
defaultSavePath='';                     % By defaul empty string
defaultNotifications=true;              % Show notifications [1,0] [true, false] - on by default
defaultalign=true;                     % To align all the signals, true or false

validPATHS=@(x) iscell(x) && (size(x,2) ==3);

addRequired(p,'PATHS',validPATHS);
addParameter(p,'BMSName',defaultBMSName,@iscellstr)
addParameter(p,'ECGName',defaultECGName,@iscellstr)
addParameter(p,'Stages',defaultStages,@iscellstr)
addParameter(p,'savepath',defaultSavePath,@ischar)
addParameter(p,'notifications',defaultNotifications,@islogical)
addParameter(p,'align',defaultalign,@islogical)
parse(p,PATHS,varargin{:})


% -------------------------------------------------------------------------
% Iterate through the records
for i=1:size(p.Results.PATHS,1)
    
    %----------------------------------------------------------------------
    % 1) Import BSM signal  
    try
        [signals,header] = bmsscedfreader(p.Results.PATHS{i,1});          % Load BMS .edf-file
    
        I=ismember(header.label,p.Results.BMSName);         % Indexes for BMS signals
        II=find(I);
        
        subject(i).ID=i;                              % Patient index number  
        subject(i).BMSinfo.subjectID=header.subjectID;   % Patient ID
        subject(i).BMSinfo.startdate=header.startdate;   % Start date for BMS measure
        sttime=strrep(header.starttime,'.',':');
        subject(i).BMSinfo.starttime=sttime(1:8);   % Start time
        subject(i).BMSinfo.label=header.label(I);        % Signal labals
        subject(i).BMSinfo.units=header.units(I);        % Units of measurement
        subject(i).BMSinfo.fs=header.frequency(I);       % Sampling frequencies
        samples=header.samples(I);                       % Number of edf. samples in one block
        subject(i).BMSsignal=cell(numel(samples),1);  % Cell of BMS signals
        BMSstarttime=datevec(sttime);          % Numeric time matrix
        BMSstarttime=BMSstarttime(:,4)*60*60+BMSstarttime(:,5)*60+BMSstarttime(:,6); % Start time in seconds from start of the day
        for j=1:numel(samples)                        % Fill the signal cell
            subject(i).BMSsignal{j,1}=signals(II(j),1:header.records*samples(j));
            BMStime{j}=BMSstarttime+((1:header.records*samples(j))-1)/header.frequency(II(j));
        end
    catch
        error(['bmsscimportdata: cannot open BSM .edf file or parse data for subject ',num2str(i)])
    end
    
    
    %----------------------------------------------------------------------
    % 2) Import ECG signal
    if ~isempty(PATHS{i,2}) % If the additional ECG file provided use it
        [signals,header]  = bmsscedfreader(p.Results.PATHS{i,2});
    end
    
    try 
        Iecg=ismember(header.label,p.Results.ECGName);
        
        subject(i).ECGinfo.subjectID=header.subjectID;
        subject(i).ECGinfo.startdate=header.startdate;
        subject(i).ECGinfo.starttime=header.starttime;
        subject(i).ECGinfo.label=header.label(Iecg);
        subject(i).ECGinfo.units=header.units((Iecg));
        subject(i).ECGinfo.fs=header.frequency((Iecg));
        subject(i).ECGsignal=signals((Iecg),1:header.records*header.samples((Iecg)));
        ECGstarttime=datevec(strrep(header.starttime,'.',':'));          % Numeric time matrix
        ECGstarttime=ECGstarttime(:,4)*60*60+ECGstarttime(:,5)*60+ECGstarttime(:,6); % Start time in seconds from start of the day
        ECGtime=ECGstarttime+((1:header.records*header.samples(Iecg))-1)/header.frequency(Iecg);
        
    catch
        if p.Results.notifications
            warning(['bmsscimportdata: cannot find or parse ECG data for subject ',num2str(i)])
        end
    end
    
    
    %----------------------------------------------------------------------
    % 3) Import hypnogram
    try
        hypnodata = importdata(p.Results.PATHS{i,3},'\t',9);      % Load hypnogram
        
        subject(i).hypnoinfo.header=hypnodata.textdata(1:8,1); % General information
        
        % Parse sleep classes
        HypnoStages=hypnodata.textdata(10:end,2);       % Sleep stage labels
        [~,hypnomatrix]=ismember(HypnoStages,p.Results.Stages); % Stages as numeric index values 
        hypnomatrix=mod(hypnomatrix,5);                 % Set [A,R,N1,N2,N3]=[1,2,3,4,0];
        hypnomatrix(hypnomatrix==0)=5;                  %  Set [A,R,N1,N2,N3]=[1,2,3,4,5];
        hypnomatrix=6-hypnomatrix;                      % Set [A,R,N1,N2,N3]=[5,4,3,2,1]; (Better for hypno plotting)
        
        % Parse epoch start times
        EpochStarts=hypnodata.textdata(10:end,3);       % Epoch start times - cell of time strings
        EpochStarts=datevec(EpochStarts);               % Numeric time matrix
        EpochStarts=EpochStarts(:,4)*60*60+EpochStarts(:,5)*60+EpochStarts(:,6); % Convert seconds from start day
        
        DiffE=EpochStarts(2:end)-EpochStarts(1:end-1);  % Detect day change instances
        cp=find(DiffE<0)+1;                             % Indexes where day change
        for j=1:numel(cp)
            EpochStarts(cp(j):end)=EpochStarts(cp(j):end)+60*60*24; % Add whole day for instances after day change
        end
        subject(i).hypnogram=[hypnomatrix';EpochStarts']; % Matrix of stages and epoch start times
        subject(i).hypnoinfo.stages=unique(HypnoStages);  % Different stages observed in this subject
        
    catch
        if p.Results.notifications
             warning(['importdatastim: cannot find or parse hypnogram for subject ',num2str(i)])
        end
    end
    
    %----------------------------------------------------------------------
    % 4) Aling BSM and ECG to be at same interval as hypnogram
    if p.Results.align
        try
            % Determine the alignment start and end from the latest start
            % and earliest stop
            starttime=max([cellfun(@(v)v(1),BMStime),ECGtime(1),subject(i).hypnogram(2,1)]);
            epochlength=round(median(diff(subject(i).hypnogram(2,:))));  % Epoch duration in seconds
            endtime=min([cellfun(@(v)v(end),BMStime),ECGtime(end),subject(i).hypnogram(2,end)+epochlength]);
            
            % Remove hypnogram epochs where we dont have recording
            subject(i).hypnogram(:,(subject(i).hypnogram(2,:)<starttime)|(endtime<(subject(i).hypnogram(2,:)+epochlength)))=[];
            starttime=subject(i).hypnogram(2,1);             % Set new start time
            endtime=subject(i).hypnogram(2,end)+epochlength; % Set new end time
            
            % Align BMS
            for j=1:numel(BMStime)
                subject(i).BMSsignal{j}((BMStime{j}<starttime)|(endtime<BMStime{j}))=[];
            end
            
            % New BMS start time
            hs=floor(starttime/3600);
            mins=floor((starttime-hs*3600)/60);
            secs=starttime-hs*3600-mins*60;
            subject(i).BMSinfo.starttime=datestr([num2str(hs),':',num2str(mins),':',num2str(secs)],'HH:MM:SSFFF');
            
            % Align ECG
            subject(i).ECGsignal((ECGtime<starttime)|(endtime<ECGtime))=[];
            
            % New ECG start time
            subject(i).ECGinfo.starttime=datestr([num2str(hs),':',num2str(mins),':',num2str(secs)],'HH:MM:SSFFF');
            
        catch
            error(['bmsscimportdata: cannot align signals with hypnogram for subject ',num2str(i),' set align parameter to false to ignore alignment'])
        end
    end

    
    clear BMStime ECGtime
end


end
