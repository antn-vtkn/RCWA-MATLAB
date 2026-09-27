classdef NamedObject <handle
    % Shape is a class to define pattern parameters of the structures on the
    % device
    properties
        name string
    end
    
    methods
        
        function N = NamedObject(name)
            if nargin, N.name=name; end
        end  
        
        function PrefixName(N,prefix)
            if ~isempty(prefix) && ~isempty(N.name) 
                prefix=[prefix ': '];
            end
            N.name=[prefix N.name];
        end
        
        function SuffixName(N,suffix)
            if ~isempty(suffix) && ~isempty(N.name) 
                suffix=[' -- ' suffix];
            end
            N.name=[N.name suffix];
        end

    end
end