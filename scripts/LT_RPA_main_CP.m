%%%%%%%%%%%%%%%%%% LT Project - RPA main script %%%%%%%%%%%%%%%%%%%%%%%
% this script takes preprocessed fNIRS data (see LT_main_CP for information
% about preprocessing steps), calculates wavelet transform coherence
% between x random pairs per each pair (value can be set in permnum), and calculates the average
% between these random pairs so that for each pair we have a randomly
% created control pair

%the function "LT_config_paths" needs to be in the Matlab current folder for this script to run! 

%author: Carolina Pletti (carolina.pletti@gmail.com)

clear all

%---------------------------------------------------------

% create empty structure that will contain all necessary parameters

cfg = [];
cfg.overwrite = 0; %set to 1 if you want to overwrite all data (converted data will not be overwritten, all other steps will)
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segment = 'interaction_long'; %segment of the experiment to be analyzed. Options: laughter, interaction, interaction_long
cfg.permnum = 100; %how many random pairs should be calculated?


% --------------------------------------------------------------------
%set all paths for loading and saving data, add folder with functions and Homer2 to the path. Change paths in the config_paths
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



%decide what you want the analysis to do
sel_ROI = false;

while sel_ROI == false
    fprintf('\nPlease select one option:\n');
    fprintf('[1] - Calculate coherence by channel\n');
    fprintf('[2] - Calculate coherence by ROI\n');
    fprintf('[3] - Quit\n');

    x = input('Option: ');

    switch x
        case 1
            sel_ROI = true;
            cfg.ROI = 0;
        case 2
            sel_ROI = true;
            cfg.ROI = 1;
        case 3
            fprintf('\nProcess aborted.\n');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
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

%loop through all file and calculate 100 wavelet transform coherence
%between randomly extracted pairs

numOfSources = length(cfg.sources);
cfg.dataDir = cfg.desDir;

for i = 1:numOfSources
    %retrieve unmodified cfg info
    cfg_part = cfg;
    cfg_part.currentPair = cfg_part.sources{i};
    cfg_part.problems = {};
    temp = strsplit(cfg_part.currentPair, '_');
    cfg_part.currentGroup = temp{1};
    cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.segment, '\preprocessed\');
        
    %random permutation wavelet transform coherence
    cfg_part = LT_RPA(cfg_part);
            
    %cfg_part.srcDir = cfg.srcDir;
end 
        
%         %save participant's cfg file, which contains a log of all the steps
%         %that were ran
%         try
%             out_path = strcat(cfg.srcDir, cfg_part.currentPair, '.mat');
%             fprintf(strcat('The cfg file of pair ', string(cfg_part.currentPair),' will be saved in/n'));
%             fprintf('%s ...\n', out_path);
%             save(out_path, 'cfg_part');
%             fprintf('Data stored!\n\n');
%         catch
%             fprintf('Couldnt save data ');
%         end
%         
%     end
% end