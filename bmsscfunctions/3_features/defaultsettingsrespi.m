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
%
% =========================================================================
%                   1 WHAT FEATURE FROM WHICH SIGNAL
% =========================================================================
% These are default settings for the parameters 
% fields:
%   1-level feature type: , spectral, nlindyn, misc
%   2-level feature name: several
%   3-level feature signal: BMSsignal, BMSsignalHF, BMSsignalLF, RCL, HBI
%      => value: [a,b,c,d] 
%            a - number of preceeding epochs for feature calculation 
%            b - size of epoch a=0 => dont calculate this feature in this signal
%                a=1 => 30sec, a=2 => 60 sec, etc.
%            c - number of proceeding epochs for feature calculation
%            d - non movement segment (d=0) or movement segment (d=1) or
%                both (d=2) or dont separate (d=3) 
%                Note! Only relevant for BMSsignal, BMSsignalHF, BMSsignalLF 

% Feature 1: Mean
featsettings(1).BMSsignal=[0,0,0,0];
featsettings(1).BMSsignalHF=[0,0,0,0];
featsettings(1).BMSsignalLF=[0,0,0,0];
featsettings(1).RCL=[0,0,0,0];
featsettings(1).HBI=[0,0,0,0];
    
% Feature 2: Median
featsettings(2).BMSsignal=[0,0,0,0];
featsettings(2).BMSsignalHF=[0,0,0,0];
featsettings(2).BMSsignalLF=[0,0,0,0];
featsettings(2).RCL=[0,0,0,0];
featsettings(2).HBI=[0,0,0,0];

% Feature 3: Variance  - Chosen feature
featsettings(3).BMSsignal=[0,0,0,0];
featsettings(3).BMSsignalHF=[0,1,0,0];%!!! - Chosen feature
featsettings(3).BMSsignalLF=[0,1,0,1];%!!! - Chosen feature
featsettings(3).RCL=[0,0,0,0];
featsettings(3).HBI=[0,0,0,0];

% Feature 4: Coefficient of variation
featsettings(4).BMSsignal=[0,0,0,0];
featsettings(4).BMSsignalHF=[0,0,0,0];
featsettings(4).BMSsignalLF=[0,0,0,0];
featsettings(4).RCL=[0,0,0,0];%!!! %1
featsettings(4).HBI=[0,0,0,0];

% Feature 5: Standard deviation
featsettings(5).BMSsignal=[0,0,0,0];
featsettings(5).BMSsignalHF=[0,0,0,0];
featsettings(5).BMSsignalLF=[0,0,0,0];
featsettings(5).RCL=[0,0,0,0];%1
featsettings(5).HBI=[0,0,0,0];

% Feature 6: Skewness
featsettings(6).BMSsignal=[0,0,0,0];
featsettings(6).BMSsignalHF=[0,0,0,0];% 1 2
featsettings(6).BMSsignalLF=[0,0,0,0];% 1 2
featsettings(6).RCL=[0,0,0,0];
featsettings(6).HBI=[0,0,0,0];

% Feature 7: Kurtosis - Chosen feature
featsettings(7).BMSsignal=[0,0,0,0];
featsettings(7).BMSsignalHF=[0,1,0,0]; % - Chosen feature
featsettings(7).BMSsignalLF=[0,1,0,1]; %- Chosen feature
featsettings(7).RCL=[0,1,0,0];         % - Chosen feature
featsettings(7).HBI=[0,0,0,0];

% Feature 8: Hjorth mobility
featsettings(8).BMSsignal=[0,0,0,0];
featsettings(8).BMSsignalHF=[0,0,0,0];%!!!
featsettings(8).BMSsignalLF=[0,0,0,0];
featsettings(8).RCL=[0,0,0,0];
featsettings(8).HBI=[0,0,0,0];

% Feature 9: Hjorth complexity - Chosen feature
featsettings(9).BMSsignal=[0,0,0,0];
featsettings(9).BMSsignalHF=[0,0,0,0];
featsettings(9).BMSsignalLF=[0,1,0,0];%!!! - Chosen feature
featsettings(9).RCL=[0,0,0,0];
featsettings(9).HBI=[0,0,0,0];

% Feature 10: Peak median
featsettings(10).BMSsignal=[0,0,0,0];
featsettings(10).BMSsignalHF=[0,0,0,0];
featsettings(10).BMSsignalLF=[0,0,0,0];
featsettings(10).RCL=[0,0,0,0];
featsettings(10).HBI=[0,0,0,0];

% Feature 11: Peak standard deviation
featsettings(11).BMSsignal=[0,0,0,0];
featsettings(11).BMSsignalHF=[0,0,0,0];
featsettings(11).BMSsignalLF=[0,0,0,0];
featsettings(11).RCL=[0,0,0,0];
featsettings(11).HBI=[0,0,0,0];

% Feature 12: Trough median
featsettings(12).BMSsignal=[0,0,0,0];
featsettings(12).BMSsignalHF=[0,0,0,0];
featsettings(12).BMSsignalLF=[0,0,0,0];
featsettings(12).RCL=[0,0,0,0];
featsettings(12).HBI=[0,0,0,0];

% Feature 13: Trough standard deviation
featsettings(13).BMSsignal=[0,0,0,0];
featsettings(13).BMSsignalHF=[0,0,0,0];
featsettings(13).BMSsignalLF=[0,0,0,0];%!!!
featsettings(13).RCL=[0,0,0,0];
featsettings(13).HBI=[0,0,0,0];

% Feature 14: Mean of differences of local extrema - Chosen feature
featsettings(14).BMSsignal=[0,0,0,0];
featsettings(14).BMSsignalHF=[0,0,0,0];
featsettings(14).BMSsignalLF=[0,1,0,0];%!!! - Chosen feature
featsettings(14).RCL=[0,0,0,0];
featsettings(14).HBI=[0,0,0,0];

% Feature 15: Variance of difference of local extrema
featsettings(15).BMSsignal=[0,0,0,0];
featsettings(15).BMSsignalHF=[0,0,0,0];
featsettings(15).BMSsignalLF=[0,0,0,0];
featsettings(15).RCL=[0,0,0,0];
featsettings(15).HBI=[0,0,0,0];

% Feature 16: Mean of time difference of local extrema
featsettings(16).BMSsignal=[0,0,0,0];
featsettings(16).BMSsignalHF=[0,0,0,0];
featsettings(16).BMSsignalLF=[0,0,0,0];
featsettings(16).RCL=[0,0,0,0];
featsettings(16).HBI=[0,0,0,0];

% Feature 17: Variance of time difference of local extrema
featsettings(17).BMSsignal=[0,0,0,0];
featsettings(17).BMSsignalHF=[0,0,0,0];
featsettings(17).BMSsignalLF=[0,0,0,0];
featsettings(17).RCL=[0,0,0,0];
featsettings(17).HBI=[0,0,0,0];

% Feature 18: Zero crossings
featsettings(18).BMSsignal=[0,0,0,0];
featsettings(18).BMSsignalHF=[0,0,0,0];
featsettings(18).BMSsignalLF=[0,0,0,0];
featsettings(18).RCL=[0,0,0,0];
featsettings(18).HBI=[0,0,0,0];

% Feature 19: Zero crossings of first derivative - Chosen feature
featsettings(19).BMSsignal=[0,0,0,0];
featsettings(19).BMSsignalHF=[0,1,0,0]; %- Chosen feature
featsettings(19).BMSsignalLF=[0,0,0,0];
featsettings(19).RCL=[0,0,0,0];
featsettings(19).HBI=[0,0,0,0];

% Feature 20: Zero crossings of seconds derivative
featsettings(20).BMSsignal=[0,0,0,0];
featsettings(20).BMSsignalHF=[0,0,0,0];
featsettings(20).BMSsignalLF=[0,0,0,0];%!!!
featsettings(20).RCL=[0,0,0,0];
featsettings(20).HBI=[0,0,0,0];

% Feature 21: Envelope standard deviation - Chosen feature
featsettings(21).BMSsignal=[0,0,0,0];
featsettings(21).BMSsignalHF=[0,1,0,2];%!!! - Chosen feature
featsettings(21).BMSsignalLF=[0,0,0,0]; 
featsettings(21).RCL=[0,0,0,0];
featsettings(21).HBI=[0,0,0,0];

% Feature 22: Root mean square envelope crossings
featsettings(22).BMSsignal=[0,0,0,0];
featsettings(22).BMSsignalHF=[0,0,0,0];%!!!
featsettings(22).BMSsignalLF=[0,0,0,0];
featsettings(22).RCL=[0,0,0,0];
featsettings(22).HBI=[0,0,0,0];

% Feature 23: Power - Chosen feature
featsettings(23).BMSsignal=[0,1,0,3];%!!! - Chosen feature
featsettings(23).BMSsignalHF=[0,0,0,0];
featsettings(23).BMSsignalLF=[0,0,0,0];
featsettings(23).RCL=[0,0,0,0];
featsettings(23).HBI=[0,0,0,0];

% Feature 24: First spectral moment
featsettings(24).BMSsignal=[0,0,0,0];
featsettings(24).BMSsignalHF=[0,0,0,0];
featsettings(24).BMSsignalLF=[0,0,0,0];%!!!
featsettings(24).RCL=[0,0,0,0];
featsettings(24).HBI=[0,0,0,0];

% Feature 25: Second spectral moment
featsettings(25).BMSsignal=[0,0,0,0];
featsettings(25).BMSsignalHF=[0,0,0,0];%!!!
featsettings(25).BMSsignalLF=[0,0,0,0];%!!!
featsettings(25).RCL=[0,0,0,0];
featsettings(25).HBI=[0,0,0,0];

% Feature 26: Spectral entropy - Chosen feature
featsettings(26).BMSsignal=[0,0,0,0];
featsettings(26).BMSsignalHF=[0,0,0,0];
featsettings(26).BMSsignalLF=[0,1,0,0]; % - Chosen feature
featsettings(26).RCL=[0,0,0,0];
featsettings(26).HBI=[0,0,0,0];

% Feature 27: Spectral power in 3-6Hz
featsettings(27).BMSsignal=[0,0,0,0];
featsettings(27).BMSsignalHF=[0,0,0,0];
featsettings(27).BMSsignalLF=[0,0,0,0];
featsettings(27).RCL=[0,0,0,0];
featsettings(27).HBI=[0,0,0,0];

% Feature 28: Low and high freq. ratio
featsettings(28).BMSsignal=[0,0,0,0];   % NOT WORKING - DO NOT ENABLE
featsettings(28).BMSsignalHF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(28).BMSsignalLF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(28).RCL=[0,0,0,0];
featsettings(28).HBI=[0,0,0,0];

% Feature 29: High and very low freq. ratio
featsettings(29).BMSsignal=[0,0,0,0];   % NOT WORKING - DO NOT ENABLE
featsettings(29).BMSsignalHF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(29).BMSsignalLF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(29).RCL=[0,0,0,0];
featsettings(29).HBI=[0,0,0,0];

% Feature 30: High and very low freq. ratio
featsettings(30).BMSsignal=[0,0,0,0];   % NOT WORKING - DO NOT ENABLE
featsettings(30).BMSsignalHF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(30).BMSsignalLF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(30).RCL=[0,0,0,0];
featsettings(30).HBI=[0,0,0,0];

% Feature 31: Modulus of high freq.
featsettings(31).BMSsignal=[0,0,0,0];   % NOT WORKING - DO NOT ENABLE
featsettings(31).BMSsignalHF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(31).BMSsignalLF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(31).RCL=[0,0,0,0];
featsettings(31).HBI=[0,0,0,0];

% Feature 32: Phase of high freq.
featsettings(32).BMSsignal=[0,0,0,0];   % NOT WORKING - DO NOT ENABLE
featsettings(32).BMSsignalHF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(32).BMSsignalLF=[0,0,0,0]; % NOT WORKING - DO NOT ENABLE
featsettings(32).RCL=[0,0,0,0];
featsettings(32).HBI=[0,0,0,0];


% Feature 33: Sample entropy
featsettings(33).BMSsignal=[0,0,0,0];
featsettings(33).BMSsignalHF=[0,0,0,0];
featsettings(33).BMSsignalLF=[0,0,0,0];% 1 3
featsettings(33).RCL=[0,0,0,0];
featsettings(33).HBI=[0,0,0,0];

% Feature 34: Fuzzy entropy  
featsettings(34).BMSsignal=[0,0,0,0];
featsettings(34).BMSsignalHF=[0,0,0,0];
featsettings(34).BMSsignalLF=[0,0,0,0]; % 1 3
featsettings(34).RCL=[0,0,0,0];
featsettings(34).HBI=[0,0,0,0];

% Feature 35: Hurst exponent
featsettings(35).BMSsignal=[0,0,0,0];
featsettings(35).BMSsignalHF=[0,0,0,0];%!!!
featsettings(35).BMSsignalLF=[0,0,0,0];%!!! % 3 1 3
featsettings(35).RCL=[0,0,0,0];
featsettings(35).HBI=[0,0,0,0];

% Feature 36: Lyapunov exponent
featsettings(36).BMSsignal=[0,0,0,0];
featsettings(36).BMSsignalHF=[0,0,0,0];
featsettings(36).BMSsignalLF=[0,0,0,0]; % 1 3
featsettings(36).RCL=[0,0,0,0];
featsettings(36).HBI=[0,0,0,0];

% Feature 37: Increased respiratory resistance instances
featsettings(37).BMSsignal=[0,0,0,0];
featsettings(37).BMSsignalHF=[0,0,0,0];%!!!
featsettings(37).BMSsignalLF=[0,0,0,0];
featsettings(37).RCL=[0,0,0,0];
featsettings(37).HBI=[0,0,0,0];


% Feature 38: 0.25-2Hz mode frequency - Only raw signal - Chosen feature
featsettings(38).BMSsignal=[0,1,0,3]; %- Chosen feature
featsettings(38).BMSsignalHF=[0,0,0,0];
featsettings(38).BMSsignalLF=[0,0,0,0];
featsettings(38).RCL=[0,0,0,0];
featsettings(38).HBI=[0,0,0,0];

% Feature 39: 0.25-2Hz mode value in desibels - Only raw signal - Chosen feature
featsettings(39).BMSsignal=[0,1,0,3]; % - Chosen feature
featsettings(39).BMSsignalHF=[0,0,0,0];
featsettings(39).BMSsignalLF=[0,0,0,0];
featsettings(39).RCL=[0,0,0,0];
featsettings(39).HBI=[0,0,0,0];

% Feature 40: 0.25-2Hz mode wide - Only raw signal - Chosen feature
featsettings(40).BMSsignal=[0,1,0,3]; %- Chosen feature
featsettings(40).BMSsignalHF=[0,0,0,0];
featsettings(40).BMSsignalLF=[0,0,0,0];
featsettings(40).RCL=[0,0,0,0];
featsettings(40).HBI=[0,0,0,0];

% Feature 41: 0.25-2Hz mode energy in +/-0.2Hz - Only raw signal  - Chosen feature
featsettings(41).BMSsignal=[0,1,0,3]; %- Chosen feature
featsettings(41).BMSsignalHF=[0,0,0,0];
featsettings(41).BMSsignalLF=[0,0,0,0];
featsettings(41).RCL=[0,0,0,0];
featsettings(41).HBI=[0,0,0,0];

% Feature 42: 0.25-2Hz mode - autocorrelation value  - Only raw signal 
featsettings(42).BMSsignal=[0,0,0,0];
featsettings(42).BMSsignalHF=[0,0,0,0];
featsettings(42).BMSsignalLF=[0,0,0,0];
featsettings(42).RCL=[0,0,0,0];
featsettings(42).HBI=[0,0,0,0];

% Feature 43: 0.25-2Hz mode  frequency - autocorrelation - Only raw signal 
featsettings(43).BMSsignal=[0,0,0,0];
featsettings(43).BMSsignalHF=[0,0,0,0];
featsettings(43).BMSsignalLF=[0,0,0,0];
featsettings(43).RCL=[0,0,0,0];
featsettings(43).HBI=[0,0,0,0];

% Feature 44: RMSSD - only for HBI! 
featsettings(44).BMSsignal=[0,0,0,0];
featsettings(44).BMSsignalHF=[0,0,0,0];
featsettings(44).BMSsignalLF=[0,0,0,0];
featsettings(44).RCL=[0,0,0,0];
featsettings(44).HBI=[0,0,0,0];

% =========================================================================
%                   2 FEATURE EXTRA PARAMETERS
% =========================================================================
% Note! Some of the features are not indented for some signals. This is
% indicated with 'not recommended' comment

% Feature 1: Mean
featparams(1).BMSsignal={'omitnan'};
featparams(1).BMSsignalHF={'omitnan'};
featparams(1).BMSsignalLF={'omitnan'};
featparams(1).RCL={'omitnan'};
featparams(1).HBI={'omitnan'};
    
% Feature 2: Median
featparams(2).BMSsignal={'omitnan'};
featparams(2).BMSsignalHF={'omitnan'};
featparams(2).BMSsignalLF={'omitnan'};
featparams(2).RCL={'omitnan'};
featparams(2).HBI={'omitnan'};

% Feature 3: Variance
featparams(3).BMSsignal={'omitnan'};
featparams(3).BMSsignalHF={'omitnan'};
featparams(3).BMSsignalLF={'omitnan'};
featparams(3).RCL={'omitnan'};
featparams(3).HBI={'omitnan'};

% Feature 4: Coefficient of variation - NO ADDITIONAL PARAMETERS!
featparams(4).BMSsignal={}; 
featparams(4).BMSsignalHF={};
featparams(4).BMSsignalLF={};
featparams(4).covstim.RCL={};
featparams(4).covstim.HBI={};

% Feature 5: Standard deviation
featparams(5).BMSsignal={'omitnan'};
featparams(5).BMSsignalHF={'omitnan'};
featparams(5).BMSsignalLF={'omitnan'};
featparams(5).RCL={'omitnan'};
featparams(5).HBI={'omitnan'};

% Feature 6: Skewness
featparams(6).BMSsignal={'omitnan'};
featparams(6).BMSsignalHF={'omitnan'};
featparams(6).BMSsignalLF={'omitnan'};
featparams(6).RCL={'omitnan'};
featparams(6).HBI={'omitnan'};

% Feature 7: Kurtosis
featparams(7).BMSsignal={'omitnan'};
featparams(7).BMSsignalHF={'omitnan'};
featparams(7).BMSsignalLF={'omitnan'};
featparams(7).RCL={'omitnan'};
featparams(7).HBI={'omitnan'};

% Feature 8: Hjorth mobility  - NO ADDITIONAL PARAMETERS!
featparams(8).BMSsignal={};
featparams(8).BMSsignalHF={};
featparams(8).BMSsignalLF={};
featparams(8).RCL={};
featparams(8).HBI={};

% Feature 9: Hjorth complexity  - NO ADDITIONAL PARAMETERS!
featparams(9).BMSsignal={};
featparams(9).BMSsignalHF={};
featparams(9).BMSsignalLF={};
featparams(9).RCL={};
featparams(9).HBI={};

% Feature 10: Peak median - THE MINIMUM PEAK DISTANCE IN SAMPLES
featparams(10).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(10).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(10).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(10).RCL={1};             % not recommended            
featparams(10).HBI={1};             % not recommended  

% Feature 11: Peak standard deviation
featparams(11).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(11).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(11).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(11).RCL={1};              % not recommended    
featparams(11).HBI={1};              % not recommended    

% Feature 12: Trough median
featparams(12).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(12).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(12).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(12).RCL={1};             % not recommended    
featparams(12).HBI={1};             % not recommended    

% Feature 13: Trough standard deviation
featparams(13).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(13).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(13).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(13).RCL={1};             % not recommended    
featparams(13).HBI={1};             % not recommended    

% Feature 14: Mean of differences of local extrema
featparams(14).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(14).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(14).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(14).RCL={1};             % not recommended    
featparams(14).HBI={1};             % not recommended    

% Feature 15: Variance of difference of local extrema
featparams(15).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(15).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(15).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(15).RCL={1};             % not recommended    
featparams(15).HBI={1};             % not recommended    

% Feature 16: Mean of time difference of local extrema
featparams(16).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(16).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(16).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(16).RCL={1};             % not recommended    
featparams(16).HBI={1};             % not recommended    

% Feature 17: Variance of time difference of local extrema
featparams(17).BMSsignal={200*1};   % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(17).BMSsignalHF={70};    % DEFAULT ABOUT hr=170 bpm  with fs=200   
featparams(17).BMSsignalLF={200*1}; % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(17).RCL={1};             % not recommended    
featparams(17).HBI={1};             % not recommended    

% Feature 18: Zero crossings - NO ADDITIONAL PARAMETERS!
featparams(18).BMSsignal={};        
featparams(18).BMSsignalHF={};
featparams(18).BMSsignalLF={};     
featparams(18).RCL={};
featparams(18).HBI={};

% Feature 19: Zero crossings of first derivative - NO ADDITIONAL PARAMETERS!
featparams(19).BMSsignal={};
featparams(19).BMSsignalHF={};
featparams(19).BMSsignalLF={};
featparams(19).RCL={};
featparams(19).HBI={};

% Feature 20: Zero crossings of seconds derivative - NO ADDITIONAL PARAMETERS!
featparams(20).BMSsignal={};
featparams(20).BMSsignalHF={};
featparams(20).BMSsignalLF={};
featparams(20).RCL={};
featparams(20).HBI={};

% Feature 21: Envelope standard deviation - THE MINIMUM PEAK DISTANCE IN SAMPLES
featparams(21).BMSsignal={200*1};           % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(21).BMSsignalHF={70};            % DEFAULT ABOUT hr=170 bpm  with fs=200  
featparams(21).BMSsignalLF={200*1};         % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(21).RCL={1};                     % not recommended 
featparams(21).HBI={1};                     % not recommended 

% Feature 22: Root mean square envelope crossings  -  THE MINIMUM QUALITY DURATION IN SAMPLES, THE MINIMUM PEAK DISTANCE IN SAMPLES
featparams(22).BMSsignal={200*10,200*1};    % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(22).BMSsignalHF={200*10,70};     % DEFAULT ABOUT hr=170 bpm  with fs=200  
featparams(22).BMSsignalLF={200*10,200*1};  % DEFAULT ONE SECOND WHEN fs=200 (breathing)
featparams(22).RCL={5,1};                   % not recommended    
featparams(22).HBI={5,1};                   % not recommended    

% Feature 23: Power - sampling frequency!
featparams(23).BMSsignal={200};
featparams(23).BMSsignalHF={200};
featparams(23).BMSsignalLF={200};
featparams(23).RCL={};
featparams(23).HBI={};

% Feature 24: First spectral moment - SAMPLING FREQUENCY
featparams(24).BMSsignal={200};     
featparams(24).BMSsignalHF={200};
featparams(24).BMSsignalLF={200};
featparams(24).RCL={1};                     % not recommended  
featparams(24).HBI={1};                     % not recommended  

% Feature 25: Second spectral moment - SAMPLING FREQUENCY
featparams(25).BMSsignal={200};
featparams(25).BMSsignalHF={200};
featparams(25).BMSsignalLF={200};
featparams(25).RCL={1};                     % not recommended 
featparams(25).HBI={1};                     % not recommended 

% Feature 26: Spectral entropy - NO ADDITIONAL PARAMETERS!
featparams(26).BMSsignal={};
featparams(26).BMSsignalHF={};
featparams(26).BMSsignalLF={};
featparams(26).RCL={};
featparams(26).HBI={};

% Feature 27: Spectral power in 3-6Hz - SAMPLING FREQUENCY
featparams(27).BMSsignal={200};
featparams(27).BMSsignalHF={200};           % not recommended  
featparams(27).BMSsignalLF={200};           % not recommended  
featparams(27).RCL={1};                     % not recommended  
featparams(27).HBI={1};                     % not recommended  

% Feature 28: Low and high freq. ratio - frequency band limits [lower cutoff, VLF-LF-cut,LF-HF-cut,upper cut]
featparams(28).BMSsignal={};                % NOT WORKING 
featparams(28).BMSsignalHF={};              % NOT WORKING
featparams(28).BMSsignalLF={};              % NOT WORKING
featparams(28).RCL={[0.003,0.04,0.15,0.5]}; % not recommended
featparams(28).HBI={[0.003,0.04,0.15,0.5]}; % Note! adult limits                  

% Feature 29: High and very low freq. ratio
featparams(29).BMSsignal={};                % NOT WORKING 
featparams(29).BMSsignalHF={};              % NOT WORKING 
featparams(29).BMSsignalLF={};              % NOT WORKING 
featparams(29).RCL={[0.003,0.04,0.15,0.5]}; % not recommended
featparams(29).HBI={[0.003,0.04,0.15,0.5]}; % Note! adult limits      

% Feature 30: High and very low freq. ratio
featparams(30).BMSsignal={};                % NOT WORKING 
featparams(30).BMSsignalHF={};              % NOT WORKING 
featparams(30).BMSsignalLF={};              % NOT WORKING 
featparams(30).RCL={[0.003,0.04,0.15,0.5]}; % not recommended
featparams(30).HBI={[0.003,0.04,0.15,0.5]}; % Note! adult limits      

% Feature 31: Modulus of high freq.
featparams(31).BMSsignal={};                % NOT WORKING 
featparams(31).BMSsignalHF={};              % NOT WORKING 
featparams(31).BMSsignalLF={};              % NOT WORKING 
featparams(31).RCL={[0.003,0.04,0.15,0.5]}; % not recommended
featparams(31).HBI={[0.003,0.04,0.15,0.5]}; % Note! adult limits      

% Feature 32: Phase of high freq.
featparams(32).BMSsignal={};                % NOT WORKING 
featparams(32).BMSsignalHF={};              % NOT WORKING 
featparams(32).BMSsignalLF={};              % NOT WORKING 
featparams(32).RCL={[0.003,0.04,0.15,0.5]}; % not recommended
featparams(32).HBI={[0.003,0.04,0.15,0.5]}; % Note! adult limits      


% Feature 33: Sample entropy - Embedding dim (Embedding with lag 1),Tolerance
featparams(33).BMSsignal={3,0.64};
featparams(33).BMSsignalHF={3,0.42};
featparams(33).BMSsignalLF={3,0.64};
featparams(33).RCL={2,6};
featparams(33).HBI={2,6};

% Feature 34: Fuzzy entropy - Embedding dim (Embedding with lag 1),Tolerance,step of the fuzzy exponential function 
featparams(34).BMSsignal={3,0.64,2};
featparams(34).BMSsignalHF={3,0.42,2};
featparams(34).BMSsignalLF={3,0.64,2};
featparams(34).RCL={2,6,2};
featparams(34).HBI={2,6,2};

% Feature 35: Hurst exponent - NO ADDITIONAL PARAMETERS!
featparams(35).BMSsignal={};
featparams(35).BMSsignalHF={};
featparams(35).BMSsignalLF={};
featparams(35).RCL={};
featparams(35).HBI={};

% Feature 36: Lyapunov exponent -Sampling frequency, Embedding dim, Time delay (samples), Meanperiod (samples)
featparams(36).BMSsignal={[200,4,72,250]};
featparams(36).BMSsignalHF={[200,4,23,120]};
featparams(36).BMSsignalLF={[200,4,72,250]};
featparams(36).RCL={[1,2,2,5]};
featparams(36).HBI={[1,2,2,5]};

% Feature 37: Increased respiratory resistance instances -Baseline,threshold,sampling frequency 
Baseline=[-0.49;0.68;1.53;-1.34;1.24;2.67;3.38;2.29;0.79;3.34;-4.86;1.70;3.36;2.31;1.16;1.39;2.30;3.32;-0.31;0.35;1.71;-1.91;-1.39;-0.17;-3.87;3.84;3.86;0.29;3.51;0.64;3.905;0.84;0.53;2.39;2.55;4.07;3.94;5.50;6.63;5.30;4.76;2.64;1.13;-1.29;2.93;2.48;4.10;5.18;5.23;6.69;6.08;6.08];
featparams(37).BMSsignal={};                    % not recommended
featparams(37).BMSsignalHF={Baseline,25,200};
featparams(37).BMSsignalLF={};                  % not recommended
featparams(37).RCL={};                          % not recommended
featparams(37).HBI={};                          % not recommended


% Feature 38: 0.25-2Hz mode frequency - sampling frequency
featparams(38).BMSsignal={200};
featparams(38).BMSsignalHF={};
featparams(38).BMSsignalLF={};
featparams(38).RCL={};
featparams(38).HBI={};

% Feature 39: 0.25-2Hz mode value in desibels - sampling frequency
featparams(39).BMSsignal={200};
featparams(39).BMSsignalHF={};
featparams(39).BMSsignalLF={};
featparams(39).RCL={};
featparams(39).HBI={};

% Feature 40: 0.25-2Hz mode wide - sampling frequency
featparams(40).BMSsignal={200};
featparams(40).BMSsignalHF={};
featparams(40).BMSsignalLF={};
featparams(40).RCL={};
featparams(40).HBI={};

% Feature 41: 0.25-2Hz mode energy in +/-0.2Hz - sampling frequency
featparams(41).BMSsignal={200};
featparams(41).BMSsignalHF={};
featparams(41).BMSsignalLF={};
featparams(41).RCL={};
featparams(41).HBI={};

% Feature 42: 0.25-2Hz mode - autocorrelation value - sampling frequency
featparams(42).BMSsignal={200};
featparams(42).BMSsignalHF={};
featparams(42).BMSsignalLF={};
featparams(42).RCL={};
featparams(42).HBI={};

% Feature 43: 0.25-2Hz mode  frequency - autocorrelation - sampling frequency
featparams(43).BMSsignal={200};
featparams(43).BMSsignalHF={};
featparams(43).BMSsignalLF={};
featparams(43).RCL={};
featparams(43).HBI={};

% Feature 44: RMSSD - ONLY FOR HBI! 
featparams(44).BMSsignal={};
featparams(44).BMSsignalHF={};
featparams(44).BMSsignalLF={};
featparams(44).RCL={};
featparams(44).HBI={};
