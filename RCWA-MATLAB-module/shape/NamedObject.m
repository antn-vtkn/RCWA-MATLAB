classdef NamedObject <handle
    % Shape is a class to define pattern parameters of the structures on the
    % device
    properties
        name="@#$"
    end
    
    methods
        
        function N = NamedObject(name)
            if ~nargin, name="";  end
            N.name=name;
        end  
        
        function PrefixName(N,prefix)
            if strlength(prefix) && strlength(N.name) 
                prefix=strcat(prefix,': ');
            end
            N.name=strcat(prefix,N.name);
        end
        
        function SuffixName(N,suffix)
            if strlength(suffix) && strlength(N.name) 
                suffix=strcat(' -- ',suffix);
            end
            N.name=strcat(N.name,suffix);
        end

    end
end