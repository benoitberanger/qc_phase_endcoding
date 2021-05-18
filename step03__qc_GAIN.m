clear
clc

load data_GAIN

seq_of_interest = {
    '_cmrr_mbep2d_bold'
    '_ep2d_bold'
    '_ep2d_pace'
    '_gre_field_map'
    };

show_operator = 0;


%% main loop

allseq = {};

for e = 1 : length(data.content) % each exam
    
    if show_operator
        if isfield(data.content{e}{1},'Operator')
            data.operator{e} = data.content{e}{1}.Operator;
        end
    end
    
    info = struct('SeriesDescription','', 'SequenceName','', 'PhaseEncodingDirection','', 'Type', '');
    counter = 0;
    
    for s = 1 : length(data.content{e}) % each serie
        %% shortcut
        
        content = data.content{e}{s};
        if isnumeric(content) && isnan(content)
            continue
        end
        
        
        %% get seq name
        
        if isfield(content,'PulseSequenceDetails')
            seq = content.PulseSequenceDetails;
            seq = regexprep(seq, '%.*%', '');
        elseif isfield(content,'SequenceName')
            seq = content.SequenceName;
        else
            content.PatientID
            warning('seq ?')
        end
        allseq{end+1} = seq;
        
        
        %% 1 table per exam
        
        if contains(seq, seq_of_interest)
            
            if contains(seq, {'diff','resolve'} )
                
                % special case : DWI: keep only magnitude (original)
                if ~isfield(content,'DiffusionScheme')
                    continue
                elseif isfield(content,'RawImage') && content.RawImage==0
                    continue
                end
                
            elseif contains(seq, 'bold' )
                
                % special case : for BOLD, eliminate series that comes from online stats analysis
                if any(strcmp('MOCO', content.ImageType))
                    continue
                elseif contains('DERIVED', content.ImageType)
                    continue
                    
                end
                
            end
            
            counter = counter + 1;
            
            info(counter).SeriesDescription      =                content.SeriesDescription       ;
            info(counter).SequenceName           = seq;
            info(counter).PhaseEncodingDirection = ijk_to_APRLIF( content.PhaseEncodingDirection );
            info(counter).Type                   =                content.ImageType{3}            ;
            
        end
        
        
    end % serie
    
    
    if isempty( info(1).SeriesDescription )
        
        data.info_struct{e} = [];
        data.info_table {e} = [];
        data.info_char  {e} = [];
        
    else
        
        % Sort
        all_series_desc = {info.SeriesDescription};
        [~,order] = sort(all_series_desc);
        info = info(order);
        
        % Keep only unique
        all_param = cell(size(info));
        for idx = 1 : length(info)
            all_param{idx} = str2char(info(idx));
        end
        [~,idx2unique] = unique(all_param,'stable');
        info = info(idx2unique);
        
        data.info_struct{e} = info;
        data.info_table {e} = struct2table( info );
        data.info_char  {e} = structarray2char( info );
        
    end
    
    
end % exam


%% Eliminate exam without seq_of_interest

no_seq_of_interest = cellfun('isempty',data.info_struct');
fields_ = {'exam', 'serie', 'json_dcm2niix', 'json_dcmstack', 'operator', 'content', 'info_struct', 'info_char', 'info_table'};
for f = fields_
    data.(char(f))(no_seq_of_interest) = [];
end


%% Regroup

[~,idx2group,group2idx] =  unique( data.info_char );


%% Display

fprintf('=============================================================================================================================\n')
fprintf('protocol : %s \n', data.name)
fprintf('=============================================================================================================================\n')

%     data.info_table{idx2group}
%     cell2table([data.exam num2cell(group2idx)])

[~,order] = sort(histcounts(group2idx),'descend'); % this is the order of groups where there is the more exam

fprintf('\n')

for o = 1 : length(order)
    
    bin = order(o)==group2idx;
    fprintf('N = %d/%d (%d%%) \n', sum(bin), length(bin), round(100*sum(bin)/length(bin)));
    
    disp(data.info_table{find(bin,1,'first')})
    if show_operator
        t = cell2table([data.exam(bin) data.operator(bin)']);
        t.Properties.VariableNames = {'exam','operator'};
    else
        t = cell2table(data.exam(bin));
        t.Properties.VariableNames = {'exam'};
    end
    disp(t)
    
    fprintf('\n')
    fprintf('-------------------------------------------------------------------------------------------------------------------\n')
end

fprintf('\n\n\n')


