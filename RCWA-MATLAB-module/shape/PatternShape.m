classdef PatternShape <handle & matlab.mixin.Heterogeneous
    % Shape is a class to define pattern parameters of the structures on the
    % device
    properties (Constant)
        EligibleShapes2D={'Cylinder','Ellipse','Rectangle','Triangle'}
        EligibleShapes2DextAdd={'Pyramid'}
        EligibleShapes3D={'PyramidExt'}
        CursedShapes2D={'Triangle'}
        SingleDimShapes2D={'Cylinder'};
        RadialDefinedShapes2D={'Cylinder','Ellipse'};
    end
    properties
        center=nan
        nlayer=nan
        size=nan
        material Material
    end
    
    methods
        
        function Shape = PatternShape(center,sizexy,nlayer,material)
            narginchk(4,4);
            if numel(center) == 2
                Shape.center = center;
            else
                error('center must be 2 element vector')
            end
            Shape.nlayer = nlayer;
            Shape.size=sizexy;
            Shape.material=material;
        end  
        
    end
    
    methods (Sealed, Static)
        
        function List=EligibleShapes2Dext
            List=[PatternShape.EligibleShapes2D,PatternShape.EligibleShapes2DextAdd];
        end
        
    end
    
    methods(Abstract)
       
        BuildPattern(Pyramid,Dev,varargin)

    end
end