function [classestimates,scores]=classifybmssc(svm,featureset)
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
% Classifies the target

if 1
   fprintf('Classifying: support vector machine...\n')
end

classestimates=cell(numel(featureset),1);
scores=cell(numel(featureset),1);

% Create lagged featurematrixes
lag=5; % Take current epoch features and previous #lag epochs
featureset=lagfeaturematrix(featureset,lag);

% Iterate patient
for i=1:numel(featureset)
    
    myfeatures=featureset(1).values;%(:,allI);
    [classestimates{i},scores{i}] = predict(svm,myfeatures);

end

if 1
    fprintf('\n...done.\n');
end


end




% =========================================================================
% Addiional functions
% =========================================================================


% Multiplies the feature matrix by adding lagged samples
function featureset=lagfeaturematrix(featureset,lag)
% This adds features from previous N epochs (lag) to a current epoch as extra
% features. Thus the feature matrix gets multiplied. With lag=0 returns the
% same matrix as given as imput

% Generate new names
if lag>0
    newnames=repmat(featureset(1).names,lag+1,1);
    for i=1:lag
        newnames(i+1,:)=cellfun(@strcat,newnames(i+1,:),...
            repmat({['_lag',num2str(i)]},1,numel(featureset(1).names)),'UniformOutput',false);
    end
    newnames=reshape(newnames,1,(1+lag)*numel(featureset(1).names));
end

% Iterate patients
for i=1:numel(featureset)
    % Fill the new feature matrix
    if lag>0 % Only if we include previos epochs
        tempF=[nan(lag,size(featureset(i).values,2));featureset(i).values]; % NaN buffered matrix
        F=featureset(i).values;
        for j=1:lag % Iterate features and stack the shifted matrices
            F=[F;tempF(lag-j+1:end-j,:)];
        end
        [N,M]=size(featureset(i).values);
        F=reshape(F,N,M*(lag+1)); % Reshape so that epoch count (rows) correct and lagged features are close to each other
        featureset(i).values=F;
        featureset(i).names=newnames;
    end
    % Fill the missing values
    featureset(i).values=fillmissing(featureset(i).values,'next');
    featureset(i).values=fillmissing(featureset(i).values,'previous');

end

end




% Plotting features as histograms
% function plotfeatures(featurearray,featnames,targetclass)
% % Plots the histogram pdf estimates for each feature
% for i=1:42
%     fi=floor((i-1)/10);
%     si=i-fi*10;
%     figure(fi+1)
%     subplot(5,2,si)
%     histogram(featurearray(targetclass==0,i),'Normalization','pdf')
%     hold on
%     histogram(featurearray(targetclass==1,i),'Normalization','pdf')
%     hold off
%     title(featnames{i})
% end
% end