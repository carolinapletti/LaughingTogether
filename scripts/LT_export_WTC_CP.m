%%%% work in progress!!!%%%

%%%%%%%%%%%%%%%%%% LT Project - Export script for group data %%%%%%%%%%%%%%%%%%%%%%%
% this script opens and exports wavelet transform coherence data and saves
% them in an appropriate format for future analyses (as a single .csv file
% in case of averaged WTCs, as a series of .csv files - one per participant pair
% - in case of WTC matrixes with one value per time point and channel).

%the final dataframe should look like this in case of WTC values aggregated through time points and periods:
%channel1 channel2 channel3 ... Subject Interval Group

%the final dataframe should look like this in case of WTC values aggregated through time points:
%channel1 channel2 channel3 ... Subject Interval Group

%WORK IN PROGRESS!!!!
%the final dataframes should look like this in case of non-aggregated WTC values:
%channel1 channel2 channel3 ... Subject Interval Group (one file per
%participant)

clear all

% loop through _C files in interaction

srcDir = 'X:\hoehl\projects\LT\LT_adults\Carolina_analyses\fNIRS\data_prep\data\';                        %data location

grDir = {'IC', 'IL', 'NIC', 'NIL'};

%the part looping through both laugther and interaction does not work yet!
subDir = {'interaction'};

for i = 1:length(grDir)
    for j = 1:length(subDir)
        srcPath = strcat(srcDir, grDir{i}, '\', subDir{j}, '\preprocessed\Coherence_ROIs\');
        sourceList    = dir([srcPath, '*.mat']);
        sourceList    = struct2cell(sourceList);
        sourceList    = sourceList(1,:);
        numOfSources  = length(sourceList);
        numOfPart       = zeros(1, numOfSources);
  
        prefix = grDir{i};
    
        for k=1:1:numOfSources
       
            numOfPart(k)  = sscanf(sourceList{k}, ...
                        strcat(prefix,'_%d_C.mat'));
        end

        for id = numOfPart
            id
            filename = strcat(srcPath, prefix, sprintf('_%02d', id),'.mat');
            % load coherence data
            load(filename);             
            
            % copy info from each file in big dataframe.
                        
            Pair = id;
            Group = string(prefix);
            Condition = string(subDir{j});
            %per ognuno dei due intervalli
            for int = 1:2
                Interval = int;
                IFGr = coherences.avgAll{1,int}{1,1}(1,3);
                IFGl = coherences.avgAll{1,int}{1,6}(1,3);
                TPJr = coherences.avgAll{1,int}{1,11}(1,3);
                TPJl = coherences.avgAll{1,int}{1,16}(1,3);
                
                if ~exist('data', 'var')
                    data = table(IFGr, IFGl, TPJr, TPJl, ...,
                         Condition, Pair, Interval, Group);
                else
                    pairData = table(IFGr, IFGl, TPJr, TPJl, ...,
                         Condition, Pair, Interval, Group);
                    data = [data; pairData];
                end
            end
        end
    end
end


desFile = 'X:\hoehl\projects\LT\LT_adults\Carolina_analyses\fNIRS\data_prep\data\IC_IL_Data_ROI.csv';
writetable(data,desFile,'Delimiter',',','QuoteStrings',true)
fprintf('\nDone!\n');