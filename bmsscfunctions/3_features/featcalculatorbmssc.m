function featureset=featcalculatorbmssc(featfunc,patient,featureset,featsettings,featparams,featurenames)
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
% Calculate the features of given function featfunc based on the options fiven 
% in featsettings. The signals are in patient struct and returns updated
% featureset. feature name in name parameter

% -------------------------------------------------------------------------
% Determine features

% -------------------------------------------------------------------------
% Raw BMS signal
if featsettings.BMSsignal(2)>0
    
    % Determine do we calculate from movement segments or where
    switch featsettings.BMSsignal(4)
        case 0  % Calculate from movement free segments
            epochs=epocherbmssc(patient,'bmssignal',[featsettings.BMSsignal(1:3),0]);
            finput=[{epochs},featparams.BMSsignal];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignal_free']}];
            
        case 1  % Calculate from movement segments
            epochs=epocherbmssc(patient,'bmssignal',[featsettings.BMSsignal(1:3),1]);
             finput=[{epochs},featparams.BMSsignal];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignal_pres']}];


        case 2  % Calculate from both
            epochs=epocherbmssc(patient,'bmssignal',[featsettings.BMSsignal(1:3),0]);
             finput=[{epochs},featparams.BMSsignal];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignal_free']}];
            
            epochs=epocherbmssc(patient,'bmssignal',[featsettings.BMSsignal(1:3),1]);
             finput=[{epochs},featparams.BMSsignal];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignal_pres']}];
            
        case 3  % Ignore the movement segmentation
            epochs=epocherbmssc(patient,'bmssignal',[featsettings.BMSsignal(1:3),2]);
             finput=[{epochs},featparams.BMSsignal];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignal_full']}];
    end
    
end

% -------------------------------------------------------------------------
% High freqeuncy band of BMS signal
if featsettings.BMSsignalHF(2)>0

    % Determine do we calculate from movement segments or where
    switch featsettings.BMSsignalHF(4)
        case 0  % Calculate from movement free segments
            epochs=epocherbmssc(patient,'bmssignalhf',[featsettings.BMSsignalHF(1:3),0]);
            finput=[{epochs},featparams.BMSsignalHF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalHF_free']}];
            
        case 1  % Calculate from movement segments
            epochs=epocherbmssc(patient,'bmssignalhf',[featsettings.BMSsignalHF(1:3),1]);
            finput=[{epochs},featparams.BMSsignalHF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalHF_pres']}];

        case 2  % Calculate from both
            epochs=epocherbmssc(patient,'bmssignalhf',[featsettings.BMSsignalHF(1:3),0]);
            finput=[{epochs},featparams.BMSsignalHF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalHF_free']}];
            
            epochs=epocherbmssc(patient,'bmssignalhf',[featsettings.BMSsignalHF(1:3),1]);
            finput=[{epochs},featparams.BMSsignalHF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalHF_pres']}];
            
        case 3  % Ignore the movement segmentation
            epochs=epocherbmssc(patient,'bmssignalhf',[featsettings.BMSsignalHF(1:3),2]);
            finput=[{epochs},featparams.BMSsignalHF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalHF_full']}]; 
    end
    
end

% -------------------------------------------------------------------------
% Low frequency band of BMS signal
if featsettings.BMSsignalLF(2)>0
    % Determine do we calculate from movement segments or where
    switch featsettings.BMSsignalLF(4)
       
        case 0  % Calculate from movement free segments
            epochs=epocherbmssc(patient,'bmssignallf',[featsettings.BMSsignalLF(1:3),0]);
            finput=[{epochs},featparams.BMSsignalLF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalLF_free']}];
            
        case 1  % Calculate from movement segments
            epochs=epocherbmssc(patient,'bmssignallf',[featsettings.BMSsignalLF(1:3),1]);
            finput=[{epochs},featparams.BMSsignalLF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalLF_pres']}];

        case 2  % Calculate from both
            epochs=epocherbmssc(patient,'bmssignallf',[featsettings.BMSsignalLF(1:3),0]);
            finput=[{epochs},featparams.BMSsignalLF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalLF_free']}];        
            
            epochs=epocherbmssc(patient,'bmssignallf',[featsettings.BMSsignalLF(1:3),1]);
            finput=[{epochs},featparams.BMSsignalLF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalLF_pres']}];
            
        case 3  % Ignore the movement segmentation
            epochs=epocherbmssc(patient,'bmssignallf',[featsettings.BMSsignalLF(1:3),2]);
            finput=[{epochs},featparams.BMSsignalLF];
            featureset.values=[featureset.values,featfunc(finput{:})'];
            featureset.names=[featureset.names,{[featurenames,'_BMSsignalLF_full']}];      
    end
    
end

% -------------------------------------------------------------------------
% Respiratory cycle lenght series
if featsettings.RCL(2)>0
    epochs=epocherbmssc(patient,'rcl',[featsettings.RCL(1:3),0]);
    featureset.names=[featureset.names,{[featurenames,'_RCL']}];
    finput=inputecreator(epochs,featparams.RCL);
    if size(finput,1)==1
        disp(featfunc)
        results=cellfun(featfunc,epochs,finput);
    elseif size(finput,1)==2
        results=cellfun(featfunc,epochs,finput(1,:),finput(2,:));
    elseif size(finput,1)==3
        results=cellfun(featfunc,epochs,finput(1,:),finput(2,:),finput(3,:));
    else
        results=cellfun(featfunc,epochs);
    end
    featureset.values=[featureset.values,results'];
end

% -------------------------------------------------------------------------
% Heart beat interval series
if featsettings.HBI(2)>0
    epochs=epocherbmssc(patient,'hbi',[featsettings.HBI(1:3),0]);
    featureset.names=[featureset.names,{[featurenames,'_HBI']}];
    finput=inputecreator(epochs,featparams.HBI);
    if size(finput,1)==1
        results=cellfun(featfunc,epochs,finput);
    elseif size(finput,1)==2
        results=cellfun(featfunc,epochs,finput(1,:),finput(2,:));
    elseif size(finput,1)==3
        results=cellfun(featfunc,epochs,finput(1,:),finput(2,:),finput(3,:));
    else
        results=cellfun(featfunc,epochs);
    end
    featureset.values=[featureset.values,results'];
end

end

% =========================================================================
%  Additional functions
% =========================================================================

function finput=inputecreator(epochs,params)
% Merges the epochs data and function input parameters to a proper input
params=params';
B=repmat(params,1,size(epochs,2));
finput=B;

end