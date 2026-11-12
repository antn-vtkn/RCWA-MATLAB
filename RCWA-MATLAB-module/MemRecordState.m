function varargout = MemRecordState()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
narginchk(0,0)
nargoutchk(1,3)

if strcmp(computer,'PCWIN64')
    mmr=memory;
    m(1,1)=mmr.MaxPossibleArrayBytes;
    m(2,1)=mmr.MemAvailableAllArrays;
    m(3,1)=mmr.MemUsedMATLAB;
else
    m=nan(3,1);
end

switch nargout
    case 1
        varargout{1}=m;
    case 3
        for ii=1:3
        varargout{ii}=m(ii);
        end
    otherwise
        error('MemRecordState() requires 1 or 3 output arguments')
end

end



% % % [tmp pid] = system('pgrep MATLAB');
% % % [tmp mem_usage] = system(['cat /proc/' strtrim(pid) '/status | grep VmSize']);
% % % 
% % % [tmp mem_usage] = system(['cat /proc/$(pgrep MATLAB)/status | grep VmSize']);
% % % fprintf("%i MB\n", round(str2num(strtrim(extractAfter(extractBefore(mem_usage, ' kB'), ':'))) / 1000));
    
    
% % % I'm using a MAC with Catalina OS. Normally I use this command:
% % % profile -memory on
% % % you can view the results after your code executes using
% % % profview
