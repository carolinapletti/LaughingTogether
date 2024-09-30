%%%%%%%%%%%%%%%%%% LT Project - Main script %%%%%%%%%%%%%%%%%%%%%%%
% this script takes raw fNIRS data in the NIRX specific format, converts them so they can be preprocessed using Homer2 functions, extracts
% segments of interest based on markers in the data, cleans and
% preprocesses the data, calculates synchrony between pairs of participants
% using wavelet transform coherence, and calculates synchrony between
% surrogate pairs obtained through random permutation

%for this to work, Homer2 and the wavelet coherence toolbox should be added to the
%Matlab path

% 1 - convert raw data to homer2 nirs format
% 2 - segment data into laughter and interaction intervals
% 3 - preprocess (movement artifact cleaning, filtering, bad channel
%   removal, conversion of data into changes of concentrations of HbO and HbR)
% 4 - calculate wavelet transform coherence for pairs of participants
% 5 - create surrogate pairs and calculate wavelet transform coherence. Use
%   permutation to create 1000 random pairs per participant and then average
%   all the results for each participant
% 6 - export results

clear all

% create empty structure that will contain all necessary parameters for
% preprocessing

cfg = [];
cfg.overwrite = 0; %set to 1 if you want to overwrite all data (converted data will not be overwritten, all other steps will)
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segments = {'laughter', 'interaction'}; %segments of the experiment to be analyzed. Options: laughter, interaction

%set all paths. Change paths based on necessity
uni = 1 %this is specific for Carolina's workspaces at home and at the Uni

if uni == 1
    % raw data folder
    cfg.rawDir = 'X:\hoehl\projects\LT\LT adults\NIRX\Data\'

    % destination folder
    cfg.desDir = 'X:\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\Data\'

    % -------------------------------------------------------------------------
    % Load SD file
    % -------------------------------------------------------------------------
    cfg.SDFile = 'X:\hoehl\projects\LT\LT adults\NIRX\LT.SD';
    
    %add path with functions
    addpath('X:\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\new_scripts\functions');
    
    %add Homer2 to the path using its own function
    cd ('Z:\Documents\homer2')
    setpaths
    cd('X:\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\new_scripts')
    
    %add the wavelet coherence toolbox to the path
    addpath('Z:\Documents\wavelet-coherence-master')

else
    % raw data folder
    cfg.rawDir = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT adults\NIRX\Data\'

    % destination folder
    cfg.desDir = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\Data\';

    % -------------------------------------------------------------------------
    % Load SD file
    % -------------------------------------------------------------------------
    cfg.SDFile = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT adults\NIRX\LT.SD';
    
    %add path with functions
    addpath('\\share.univie.ac.at\A474\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\new_scripts\functions');
    
    %add Homer2 to the path using its own function
    cd ('Z:\Documents\homer2')
    setpaths
    cd('\\share.univie.ac.at\A474\hoehl\projects\LT\LT adults\Carolina analyses - DONT MODIFY ANYTHING HERE\fNIRS\data_prep\new_scripts')
    
    %add the wavelet coherence toolbox to the path
    addpath('Z:\Documents\wavelet-coherence-master')
end

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
        i
        %retrieve unmodified cfg info
        cfg_part = cfg;
        cfg_part.currentPair = sourceList{i};
        cfg_part.problems = {};
        
        %convert data
        
        cfg_part = LT_convert(cfg_part);

        
        %now loop through for every relevant segment of the task (laughter, inter3action)
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








