function out  = structarray2char( in )

out = '';

for idx = 1 : numel( in )
    out = [out str2char(in(idx))];
end

end % function
