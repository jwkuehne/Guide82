eval(['mag_symbol=get(f5' num2str(mag_marker) ',''marker'');']);
if strcmp(mag_symbol,'+')==1
    eval(['set(f5' num2str(mag_marker) ',''marker'',''o'')']); % toggle between + and o
else
    eval(['set(f5' num2str(mag_marker) ',''marker'',''+'')']); % toggle between + and o
end

mag_parabola;