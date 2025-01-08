%%%% work in progress!!!%%%

%%%%%%%%%%%%%%%%%% LT Project - Export script for group data %%%%%%%%%%%%%%%%%%%%%%%
% this script opens and exports aggregated wavelet transform coherence data and saves
% them in an appropriate format for future analyses (as a .csv file).

%the final dataframe should look like this in case of WTC values aggregated through time points and periods:
%channel1 channel2 channel3 ... Subject Interval Group (one line per
%participant)

%the final dataframe should look like this in case of WTC values aggregated through time points:
%channel1 channel2 channel3 ... Period Subject Interval Group (one line per
%each combination of participant and period)

%the function "LT_config_paths" needs to be in the Matlab current folder for this script to run! 

%author: Carolina Pletti (carolina.pletti@gmail.com)

clear all

%---------------------------------------------------------

% create empty structure that will contain all necessary parameters

cfg = [];
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segments = {'laughter', 'interaction','interaction_long'}; %segment of the experiment to be analyzed. Options: laughter, interaction, interaction_long


%decide what you want the analysis to do
sel_export = false;

while sel_export == false
    fprintf('\nPlease select one option:\n');
    fprintf('[1] - Export coherences averaged through time and frequencies\n');
    fprintf('[2] - Export coherences averaged through time\n');
    fprintf('[3] - Quit\n');

    x = input('Option: ');

    switch x
        case 1
            sel_export = true;
            cfg.avg = 'all';
        case 2
            sel_export = true;
            cfg.avg = 'time';
        case 3
            fprintf('\nProcess aborted.\n');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
    end
end


% --------------------------------------------------------------------
%set all paths for loading and saving data, add folder with functions to the path. Change paths in the config_paths
%function and following part of the script based on necessity 

sel = false;

while sel == false
    fprintf('\nPlease select one option:\n');
    fprintf('[1] - Carolina''s workspace at the uni\n');
    fprintf('[2] - Carolina''s workspace at home\n');
    fprintf('[3] - None of the above\n');

    x = input('Option: ');

    switch x
        case 1
            sel = true;
            cfg = LT_config_paths(cfg, 1);
        case 2
            sel = true;
            cfg = LT_config_paths(cfg, 0)
        case 3
            sel = true;
            fprintf('please change this script and the config_path function so that the paths match with where you store data, toolboxes and scripts!');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
        return
    end
end


%set the loop that run the functions through all data
%create a list of all sources, for all groups
cfg.sources = [];

for g = cfg.groups
    cfg.currentGroup = g{:};
    cfg.rawGrDir = strcat(cfg.rawDir,cfg.currentGroup,'\');

    %identify all file in the group subdirectory
    sourceList    = dir([cfg.rawGrDir, '*_*']);
    sourceList    = struct2cell(sourceList);
    sourceList    = sourceList(1,:);
    cfg.sources = [cfg.sources, sourceList];

end

numOfSources = length(cfg.sources);
cfg.dataDir = cfg.desDir;

for s = cfg.segments
    cfg.currentSegment = s{:};
    for id = 1:numOfSources
        %retrieve unmodified cfg info
        cfg_part = cfg;
        cfg_part.currentPair = cfg_part.sources{id};
        group_pair = strsplit(cfg_part.currentPair, '_');
        cfg_part.currentGroup = group_pair{1};

        cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.currentSegment, '\preprocessed\Coherence_ROIs');
        fprintf('processing participant %s \n', cfg_part.currentPair)
        filename = sprintf('%s\\%s.mat',cfg_part.srcDir, cfg_part.currentPair);
        % load coherence data
        try
            load(filename);             
        catch
            fprintf('no coherence file avaliable for pair %s \n', cfg_part.currentPair)
            continue
        end
        
        labels = {'IFGr', 'IFGl', 'TPJr', 'TPJl'};
        num_labels = length(labels);
        
        if contains(cfg.avg, 'all')
            coherence_data = coherences.avgAll;
            % Preallocate array for coherence values
            coherence_values = zeros(1, num_labels^2);
        elseif contains(cfg.avg, 'time')
            coherence_data = coherences.avgTime;
            % Preallocate array for coherence values
            coherence_values = zeros(length(coherence_data{1,1}{1,1}), num_labels^2);
            periods = zeros(length(coherence_data{1,1}{1,1}),1);
        end

        for int = 1:length(coherence_data)
            coherence_interval = coherence_data{1, int};
            variable_names = cell(1, num_labels^2);

            % Extract coherence values and variable names using loops
            idx = 1;
            for i = 1:num_labels
                for j = 1:num_labels
                    if contains(cfg.avg, 'all')
                        coherence_values(idx) = coherence_interval{1, idx}(3);
                    elseif contains(cfg.avg, 'time')
                        coherence_values(:,idx) = coherence_interval{1, idx}(:,4);
                        periods(:,idx) = coherence_interval{1, idx}(:,1);
                    end
                    variable_names{idx} = strcat(labels{i}, '_', labels{j});
                    idx = idx + 1;
                end
            end


            pairData = array2table(coherence_values, 'VariableNames', variable_names);
            pairData.Interval = int;
            pairData.Pair = string(group_pair{2});
            pairData.Group = string(cfg_part.currentGroup);
            pairData.Segment = string(cfg_part.currentSegment);
            if contains(cfg.avg, 'time')
                pairData.Period = periods;
            end

            % Initialize or append to the data table
            if ~exist('data', 'var')
                data = pairData;
            else
                data = [data; pairData];
            end
        end
    end
    desFile = sprintf('%s\\Data_ROI_%s_%s.csv', cfg.desDir, cfg.currentSegment, cfg.avg);
    writetable(data,desFile,'Delimiter',',','QuoteStrings',true)
    clear data
end

