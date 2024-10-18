%%%%%%%%%%%%%%%%%% LT Project - Main script %%%%%%%%%%%%%%%%%%%%%%%
% this script takes raw fNIRS data in the NIRX specific format, converts them so they can be preprocessed using Homer2 functions, extracts
% segments of interest based on markers in the data, cleans and
% preprocesses the data, and calculates synchrony between pairs of participants
% using wavelet transform coherence

%for this to work, Homer2 should be added to the
%Matlab path. See and modify lines below as necessary.

clear all

% create empty structure that will contain all necessary parameters for
% preprocessing

cfg = [];
cfg.overwrite = 0; %set to 1 if you want to overwrite all data (converted data will not be overwritten, all other steps will)
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segments = {'laughter', 'interaction'}; %segments of the experiment to be analyzed. Options: laughter, interaction

% --------------------------------------------------------------------

%set all paths. Change paths in the following part of the script based on necessity

uni = 0;

if uni == 1
    
    %project folder is here:
    project_folder = 'X:\hoehl\projects\LT\LT_adults\';
    
    %data and scripts are here:
    data_prep_folder = [project_folder 'Carolina_analyses\fNIRS\data_prep\'];
    
    %toolboxes are here:
    toolboxes_folder = 'Z:\Documents\';
    
else
    %project folder is here:
    project_folder = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT_adults\';

    %data and scripts are here:
    data_prep_folder = [project_folder 'Carolina_analyses\fNIRS\data_prep\'];
    
    %toolboxes are here:
    toolboxes_folder = 'Z:\Documents\';
end

cfg.rawDir = [project_folder 'NIRX\Data\']; % raw data folder
cfg.desDir = [data_prep_folder 'data\']; % destination folder
cfg.SDFile = [project_folder 'NIRX\LT.SD']; % SD file
addpath([data_prep_folder 'scripts\functions']); %add path with functions

%add Homer2 to the path using its own function
cd ([toolboxes_folder 'homer2'])
setpaths
cd([data_prep_folder 'scripts\'])


%---------------------------------------------------------

%decide what you want the analysis to do
sel = false;

while sel == false
    fprintf('\nPlease select one option:\n');
    fprintf('[1] - Divide interaction in two intervals\n');
    fprintf('[2] - Don''t divide interaction\n');
    fprintf('[3] - Do both\n');
    fprintf('[4] - Quit\n');

    x = input('Option: ');

    switch x
        case 1
            sel = true;
            cfg.divide = 1;
        case 2
            sel = true;
            cfg.divide = 0;
            cfg.segments = {'laughter', 'interaction_long'};
        case 3
            sel = true;
            cfg.divide = 2;
            cfg.segments = {'laughter', 'interaction', 'interaction_long'};
        case 4
            fprintf('\nProcess aborted.\n');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
    end
end


%set the loop that run the functions through all data
for g = cfg.groups
    cfg.currentGroup = g{:};
    cfg.srcDir = strcat(cfg.rawDir,cfg.currentGroup,'\');

    %identify all file in the group subdirectory
    sourceList    = dir([cfg.srcDir, '*_*']);
    sourceList    = struct2cell(sourceList);
    sourceList    = sourceList(1,:);
    numOfSources  = length(sourceList);
    
    for i = 1:numOfSources
        %retrieve unmodified cfg info
        cfg_part = cfg;
        cfg_part.currentPair = sourceList{i};
        cfg_part.problems = {};
        
        %convert data
        
        cfg_part = LT_convert(cfg_part);

        
        %now loop through for every relevant segment of the task (laughter, interaction, interaction no cut)
        for s = cfg_part.segments
            cfg_part.currentSegment = s{:};
            
            %segment data
            cfg_part = LT_segment(cfg_part);
            
            %preprocess data
            cfg_part = LT_preprocess(cfg_part);
            
            %wavelet transform coherence
            cfg_part = LT_WTC(cfg_part);
            
        end    
    end
end








