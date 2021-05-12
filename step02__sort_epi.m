clear
clc

load data

seq_of_interest = {
    '_cmrr_mbep2d_bold'
    '_cmrr_mbep2d_diff'
    '_ep2d_bold'
    '_ep2d_diff'
    '_ep2d_pace'
    '_resolve'
    };


%% main loop

allseq = {};
for p = 1%1 : length(data)
    
    for e = 1 : length(data(p).content) % each exam
        
        if isfield(data(p).content{e}{1},'Operator')
            data(p).operator{e} = data(p).content{e}{1}.Operator;
        end
        
        info = struct('SeriesDescription','', 'SequenceName','', 'PhaseEncodingDirection','');
        counter = 0;
        
        for s = 1 : length(data(p).content{e}) % each serie
            %% shortcut
            
            content = data(p).content{e}{s};
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
                
                if contains(seq, 'diff')
                    
                    % special case : DWI: keep only magnitude (original)
                    if ~isfield(content,'DiffusionScheme')
                        continue
                    elseif isfield(content,'RawImage') && content.RawImage==0
                        continue
                    end
                    
                end
                
                counter = counter + 1;
                
                info(counter).SeriesDescription = content.SeriesDescription;
                info(counter).SequenceName = seq;
                info(counter).PhaseEncodingDirection = ijk_to_APRLIF( content.PhaseEncodingDirection );
                
            end
            
            
        end % serie
        
        
        if isempty( info(1).SeriesDescription )
           
            data(p).info_struct{e} = [];
            data(p).info_table {e} = [];
            data(p).info_char  {e} = [];
            
        else
            
            data(p).info_struct{e} = info;
            data(p).info_table {e} = struct2table( info );
            data(p).info_char  {e} = structarray2char( info );
            
        end
        
        
    end % exam
    
    
    %% Eliminate exam without seq_of_interest
    
    no_seq_of_interest = cellfun('isempty',data(p).info_struct');
    fields_ = {'exam', 'serie', 'json_dcm2niix', 'json_dcmstack', 'operator', 'content', 'info_struct', 'info_char', 'info_table'};
    for f = fields_
        data(p).(char(f))(no_seq_of_interest) = [];
    end
    
    %% Regroup
    
    [C,IA,IC] =  unique( data(p).info_char );
    %     C'
        data(p).info_table{IA}
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all seq name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% _AALScout
% _cmrr_mbep2d_bold
% _cmrr_mbep2d_diff
% _ep2d_bold
% _ep2d_diff
% _ep2d_pace
% _ep_seg_fid
% _gre
% _gre_field_mapping
% _haste
% _icm_gre
% _medic
% _resolve
% _space_997
% _spcR_100
% _spcR_88
% _tfl
% _tfl3d1_16ns
% _tfl3d1_ns
% _tse
% _tse_vfl
% _tse_vfl_cs_WIP1061
% wip-spc-t2p+dir-
% wip-spc-t2p+ir-2
