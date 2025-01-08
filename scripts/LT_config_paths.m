function cfg = LT_config_paths(cfg, uni)

    %this function sets in the "cfg" variables all the paths where to find
    %the data and save the data for the fNIRS analyses, and adds Homer2 and all
    %necessary functions to the Matlab path
    %Adapt this function as necessary based on your own workplace!
    
    %cfg: structure containing info about the data (none of the info is
    %used in this function yet, but the function modifies the structure)
    %uni: 0 (Carolina's workplace at home) or 1 (Carolina's workplace
    %at the uni)
    
    %output:
    %the following fields are added to the cfg structure:
    %cfg.rawDir: raw data folder
    %cfg.desDir: destination folder
    %cfg.SDFile: path to the SD file
    
    %author: Carolina Pletti (carolina.pletti@gmail.com)

    if uni == 1

        %project folder is here:
        project_folder = 'X:\hoehl\projects\LT\LT_adults\';

        %Homer2 is here:
        toolbox_folder = 'Z:\Documents\matlab_toolboxes\';

    else
        %project folder is here:
        project_folder = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT_adults\';

        %Homer2 is here:
        toolbox_folder = '\\fs.univie.ac.at\plettic85\Documents\matlab_toolboxes\';
    end

    %data and scripts are here:
    data_prep_folder = [project_folder 'Carolina_analyses\fNIRS\data_prep\'];

    cfg.rawDir = [project_folder 'NIRX\Data\']; % raw data folder
    cfg.desDir = [data_prep_folder 'data\']; % destination folder
    cfg.SDFile = [project_folder 'NIRX\LT.SD']; % SD file
    
    
    addpath([data_prep_folder 'scripts\functions']); %add path with functions
    
    % if we are calling this function from "LT_main", 
    % add Homer2 to the path using its own function
    if ~isfield(cfg, 'permnum') && ~isfield(cfg, 'avg') %the field "permnum" and the field "avg" shouldn't exist if we are calling this from "LT_main"
        cd ([toolbox_folder 'homer2'])
        setpaths
        cd([data_prep_folder 'scripts\'])
    end

end