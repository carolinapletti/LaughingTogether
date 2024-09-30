function convertData (desFile, wl1File, wl2File, hdrFile, SD)
wl1 = load(wl1File);                                                        % load .wl1 file
wl2 = load(wl2File);                                                        % load .wl2 file

d = [wl1 wl2];                                                              % d matrix from .wl1 and .wl2 files

fid = fopen(hdrFile);
tmp = textscan(fid,'%s','delimiter','\n');                                  % this just reads every line
hdr_str = tmp{1};
fclose(fid);

keyword = 'Sources=';                                                       % find number of sources
tmp = hdr_str{strncmp(hdr_str, keyword, length(keyword))};
NIRxSources = str2double(tmp(length(keyword)+1:end));

keyword = 'Detectors=';                                                     % find number of detectors
tmp = hdr_str{strncmp(hdr_str, keyword, length(keyword))};
NIRxDetectors = str2double(tmp(length(keyword)+1:end));

if NIRxSources < SD.nSrcs || NIRxDetectors < SD.nDets                       % Compare number of sources and detectors to SD file
   error('The number of sources and detectors in the NIRx files does not match your SD file...');
end

keyword = 'SamplingRate=';                                                  % find Sample rate
tmp = hdr_str{strncmp(hdr_str, keyword, 13)};
fs = str2double(tmp(length(keyword)+1:end));

% find Active Source-Detector pairs
keyword = 'S-D-Mask="#';
ind = find(strncmp(hdr_str, keyword, length(keyword))) + 1;
ind2 = find(strncmp(hdr_str(ind+1:end), '#', 1)) - 1;
ind2 = ind + ind2(1);
sd_ind = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
sd_ind = sd_ind';
sd_ind = logical([sd_ind(:);sd_ind(:)]);
d = d(:, sd_ind);

% find NaN values in the recorded data -> channels should be pruned as 'bad'
for i=1:size(d,2)
    if nonzeros(isnan(d(:,i)))
        SD.MeasListAct(i) = 0;
    end
end

% find event markers and build s vector
keyword = 'Events="#';
ind = find(strncmp(hdr_str, keyword, length(keyword))) + 1;
ind2 = find(strncmp(hdr_str(ind:end), '#', 1)) - 1;
ind2 = ind + ind2(1);
if ind2 > ind
    events = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
    events = events(:,2:3);
    markertypes = unique(events(:,1));
    s = zeros(length(d),length(markertypes));
    for i = 1:length(markertypes)
        s(events(events(:,1) == markertypes(i), 2), i) = 1;
    end
else
    s = zeros(length(d));
end

% create t, aux varibles
aux = ones(length(d),1);                                                    %#ok<NASGU>
t = 0:1/fs:length(d)/fs - 1/fs;
t = t';                                                                     %#ok<NASGU>

fprintf('Saving NIRS file: %s...\n', desFile);
save(desFile, 'd', 's', 't', 'aux', 'SD');
fprintf('Data stored!\n\n');

end
