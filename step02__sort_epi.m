clearvars -except data
clc

if ~exist('data','var')
    load data
end

seq_of_interest = {
    '_cmrr_mbep2d_bold'
    '_cmrr_mbep2d_diff'
    '_ep2d_bold'
    '_ep2d_diff'
    '_ep2d_pace'
    '_resolve'
    };


allseq = {};
for p = 1 : length(data)
    
    info = cell(0,3);
    counter = 0;
    
    for e = 1 : length(data(p).content) % each exam
        
        if isfield(data(p).content{e}{1},'Operator')
            data(p).operator{e} = data(p).content{e}{1}.Operator;
        end
        
        info = cell(0,3);
        counter = 0;
        
        for s = 1 : length(data(p).content{e}) % each serie
            %% shortcut
            
            content = data(p).content{e}{s};
            
            
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
                
                % special case : DWI: keep only magnitude (original)
                if ~isfield(content,'DiffusionScheme')
                    continue
                elseif isfield(content,'RawImage') && content.RawImage==0
                    continue
                end
                
                counter = counter + 1;
                
                info{counter,1} = content.SeriesDescription;
                info{counter,2} = seq;
                info{counter,3} = ijk_to_APRLIF( content.PhaseEncodingDirection );
                
            end
            
            
        end % serie
        
        if ~isempty(info)
            info = cell2table(info,'VariableNames',{'SeriesDescription','SequenceName','PhaseEncodingDirection'});
            data(p).info{e} = info;
        end
        
    end % exam
    
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
