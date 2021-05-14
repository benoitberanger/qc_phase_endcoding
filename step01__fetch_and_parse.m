clear
clc

main_dir = '/network/lustre/dtlake01/xnat/archive';

prototol_list_prisma = {
    'ACUITY'
    'ARTCONNECT'
    'ASPIRE_MSA'
    'ATTACK'
    'CREAM_HD'
    'GAIN'
    'GENERATION_HD1'
    'ICEBERG'
    'LEOPOLD_SHIVA'
    'MINO_AMN'
    'PPMI2_0'
%     'PROSPAX'
%     'PULSE'
    'TRIAL_21'
    };

prototol_list_verio = {
    'TMS_CCS'
    'STOP_I_SEP'
    'AFFINITY'
    'PASADENA'
%     'FAIRPARK_II'
    'QUIT_COC'
    'GRADUATION'
    'PADOVA'
    };

data = []; % will contain everything
c = 0; % counter


%% Fill proto name and all its paths found in xnat archive

% fill proto name
for p = 1 : length(prototol_list_prisma)
    c = c + 1 ;
    data(c).name = prototol_list_prisma{p};
    data(c).mri = 'Prisma';
    
end
for v = 1 : length(prototol_list_verio)
    c = c + 1 ;
    data(c).name = prototol_list_verio{v};
    data(c).mri = 'Verio';
end

% fetch path
skip = [];
for p = 1 : length(data)
    data(p).path = gdir(main_dir, data(p).name);
    data(p).path = fullfile(data(p).path, 'arc001');
    if isempty(data(p).path)
        skip = [skip p];
    end
end

% Strip empty ones
data(skip) = [];


%% Fetch exam path

for p = 1 : length(data)
    data(p).exam = gdir(data(p).path,'^20');
    data(p).exam = remove_regexi(data(p).exam, 'pilot(e)?|phantom(e)?|test(e)?|fantom(e)?');
    data(p).exam = fullfile(data(p).exam, 'SCANS');
end


%% Fetch series

for p = 1 : length(data)
    fprintf('fetching series %d/%d : %s \n', p, length(data), data(p).name)
    for e = 1 : length(data(p).exam)
        data(p).serie{e} = gdir(data(p).exam{e},'.*','NIFTI');
    end
end


%% Fetch json

for p = 1 : length(data)
    fprintf('fetching json %d/%d : %s \n', p, length(data), data(p).name)
    for e = 1 : length(data(p).exam)
        data(p).json_dcm2niix{e} = gfile(data(p).serie{e},    '^v_.*json$');
        data(p).json_dcmstack{e} = gfile(data(p).serie{e},'^stack_.*json$');
    end
end


%% Read parse json


for p = 1 : length(data)
    fprintf('parsing json %d/%d : %s \n', p, length(data), data(p).name)
    for e = 1 : length(data(p).exam)
        
        % get operator
        if ~isempty(data(p).json_dcmstack{e})
            res = get_string_from_json(deblank( data(p).json_dcmstack{e}{1}(1,:) ), {'OperatorsName'}, {'char'});
            data(p).operator{e} = res{1};
        end
        
        % parse dcm2niix file
        for j = 1 : length(data(p).json_dcm2niix{e})
            data(p).content{e}{j} = spm_jsonread( deblank( data(p).json_dcm2niix{e}{j}(1,:) ) );
        end
    end
end


%% Save result

save data data
fprintf('data saved\n')

