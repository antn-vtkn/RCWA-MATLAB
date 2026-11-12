classdef Field < matlab.mixin.Copyable % & handle
    % This object will record the data which will be used to caculate
    % the field inside the device
    % Functions will be used to caculate field inside the device
    properties 
        wavenumber=[]
        L=[]
        xydimension=[]
        W_V_ref
        W_V_trn
        W_V
        LAM
        Kx
        Ky
        k0
        URC
        ERC
        C_input
        IsFieldSet=0
%         IsDeviceSet=0
    end
    properties (SetAccess = protected)
        CoordXYZ
        GridX
        GridY
        GridXY
        LayerZ
        GridZ
        Ex
        Ey
        Ez
        Hx
        Hy
        Hz
        IsGridSet=0
        IsGridCalculated=0
        IsFieldCalculated=0
    end
    
    methods
        function ClearGrid(Field)
            [Field.CoordXYZ, Field.GridX, Field.GridY, Field.GridXY, Field.GridZ, Field.LayerZ]=deal([]);
            [Field.Ex, Field.Ey, Field.Ez, Field.Hx, Field.Hy, Field.Hz]=deal([]);
            [Field.IsGridSet, Field.IsGridCalculated, Field.IsFieldCalculated]=deal(0);
        end
        
        function F=Field()
            F.ClearGrid();
            F.IsFieldSet=0;
%             F.IsDeviceSet=0;
        end
        
        function GetPointField(Field,CoordinateXYZ)
            % This function get the parameters which will be caculated
            % later 
            QueryField(Field,CoordinateXYZ,[],[],[]);
        end
        
        function GetLayerField(Field,XYGrid,ZLayer)
            % This function get the layer parameters which will be caculated
            QueryField(Field,[],XYGrid,[],ZLayer);
        end
        
        function GetGridField(Field,XYGrid,Z_Grid)
            % This function get the grid parameters which will be caculated
            QueryField(Field,[],XYGrid,Z_Grid,[]);
        end

        function QueryField(Field,CoordinateXYZ,XYGrid,Z_Grid,ZLayer)
            gridRequest=~[isempty(CoordinateXYZ), isempty(Z_Grid), isempty(ZLayer)];
            sgr=sum(gridRequest~=0);
            if sgr~=1
                error(['Exactly one grid type must be specified! You provided ' num2str(sgr)]);
            end
                
            for ii=1:numel(Field)
                if Field(ii).IsGridSet
                    error('The grid is already set. Please ClearGrid() it first explicitely!');
                end
                
                if gridRequest(1) %QueryPointField(); It is not implemented at later stages by previous authors
                    if numel(CoordinateXYZ) == 3
                        Field(ii).CoordXYZ = CoordinateXYZ;
                    else
                        error('Check the number of the Coordinates')
                    end
                else %QueryLayerField() and QueryGridField()
                    if numel(XYGrid) == 2
                        XYGrid=[XYGrid();1;1];
                    end
                    if numel(XYGrid) == 4
                        Field(ii).GridXY = XYGrid;
                        Field(ii).LayerZ = ZLayer;
                        Field(ii).GridZ = Z_Grid; %only one of these two is not empty due to an if-clause above
                    else
                        error('Check the input grid numbers in the X and Y directions');
                    end
                end
                
                Field(ii).IsGridSet=1;
            end
        end
        
        function QueryFieldManually(field,Xgrid,Ygrid,Zgrid)
            if ~( isvector(Xgrid) && isvector(Ygrid) && isvector(Zgrid) )
                error('All the three grids must be vector arrays!');
            end
                
            for ii=1:numel(field)
                if field(ii).IsGridSet
                    error('The grid is already set. Please ClearGrid() it first explicitely!');
                end
                
                field(ii).GridX=Xgrid(:).';
                field(ii).GridY=Ygrid(:).';
                if isscalar(Zgrid)
                    field(ii).LayerZ=Zgrid;
                else
                    field(ii).GridZ=Zgrid(:).';
                end
                field(ii).IsGridSet=1;
                field(ii).IsGridCalculated=1;
            end
        end
        
        function s=IsDeviceSet(field)%scalar only
            s=numel(field.xydimension)==2;
        end
        
        function CalculateGrid(FieldArr)
            for ii=1:numel(FieldArr)
                Field=FieldArr(ii);       %Remember, this is a handle class!!!
                if ~Field.IsGridSet
                    error('Set the grid primitives first!')
                end
                if ~Field.IsDeviceSet
                    error('Provide the device dimensions to the Field structure first!')
                end
                
                Nx = Field.GridXY(1);
                Ny = Field.GridXY(2);
                NCx = Field.GridXY(3);%number of unit cells
                NCy = Field.GridXY(4);
                Lx = Field.xydimension(1);
                Ly = Field.xydimension(2);
                % initilize grid
                if Nx>0
                    xa = [0.5:Nx*abs(NCx)]/Nx*Lx;                      %x axis array
                else
                    xa = linspace(0,Lx*abs(NCx),-Nx*abs(NCx)+1);
                end
                if NCx<0
                    xa = xa - mean(xa);                    %center x axis at zero %WHY on earth?!
                end
                
                if Ny>0
                    ya = [0.5:Ny*abs(NCy)]/Ny*Ly;                      %y axis vector
                else
                    ya = linspace(0,Ly*abs(NCy),-Ny*abs(NCy)+1);
                end
                if NCy<0
                    ya = ya - mean(ya);                    %center y axis at zero %WHY on earth?!
                end
            
            % initilize grid
%             [xxa,yya] = meshgrid(xa,ya);

                Field.GridX=xa(:).';
                Field.GridY=ya(:).';
                Field.IsGridCalculated=1;
            end
        end
        
        function CaculateField(FieldArr)
            for ii=1:numel(FieldArr)
                field=FieldArr(ii);       %Remember, this is a handle class!!!
                if ~(field.IsGridCalculated||field.IsDeviceSet)
                    error('XYZ-grid is not filled and device size is unset.')
                end
                
                CheckPrerequisitesOfMonochromaticField(field);
                if ~isempty(field.CoordXYZ)
                    field.CaculatePointField
                elseif ~isempty(field.LayerZ)
                    field.CaculateLayerField
                elseif ~isempty(field.GridZ)
                    field.CaculateGridField;
                else
                    error('Grid is not defined -- can''t calculate field!')
                end
            end
        end
        
        function CheckPrerequisitesOfMonochromaticField(field)
            if ~field.IsFieldSet
                error('Field structure is not ready; run RCWArun() first!')
            end
            if ~field.IsGridCalculated
                CalculateGrid(field);
            end
        end
                
        function CaculateLayerField(FieldArr)
            % This function caculate the field in grid
          for ii=1:numel(FieldArr)
            Field=FieldArr(ii);       %Remember, this is a handle class!!!
            CheckPrerequisitesOfMonochromaticField(Field);
            [numLayer,Z_position] = FindLayer(Field,Field.LayerZ);
            NH = length(Field.Kx);
            Z = zeros(2*NH,2*NH);
%             C1 = Field.W_V{1,1}\Field.W_V_ref*Field.C_input;          % define input C at the first layer
            S_U = Field.W_V_ref*Field.C_input;                       % defint the input C in the first layer 
            if numLayer ~= 1
                for n = 1 : numLayer-1
                    Middle = diag(Field.LAM{1,n})*Field.k0*Field.L(n);
                    Elamda1 = diag(exp(-Middle));       % cacualte diangal lamda
                    Elamda2 = diag(exp( Middle)); 
                    Elamda_Diag = [Elamda1,Z;Z,Elamda2];
                    C = Field.W_V{1,n}\S_U;          % define input C at the each layer
                    S_U = Field.W_V{1,n}*Elamda_Diag*C;    % input for the first layer
                end
            end
            Middle =diag(Field.LAM{1,numLayer})*Field.k0*Z_position;
            Elamda1 = diag(exp(-Middle));
            Elamda2 = diag(exp(Middle));
            Elamda_Diag = [Elamda1,Z;Z,Elamda2];
            C = Field.W_V{1,numLayer}\S_U;
            S_U = Field.W_V{1,numLayer}*Elamda_Diag*C;
            S_x = S_U(1:NH,1);
            S_y = S_U(NH+1:2*NH,1);
            U_x = S_U(2*NH+1:3*NH,1);
            U_y = S_U(3*NH+1:4*NH,1);
            clear S_U
            S_z = 1i*Field.URC(:,:,numLayer)\(Field.Kx*U_y - Field.Ky*U_x);
            U_z = 1i*Field.ERC(:,:,numLayer)\(Field.Kx*S_y - Field.Ky*S_x);
            
            % cacuate E and H at this layer
            Phase = exp(-1i*Field.k0*( full(diag(Field.Kx)).*Field.GridX + full(diag(Field.Ky)).*shiftdim(Field.GridY,-1) ));
            Field.Ex = shiftdim(sum(S_x.*Phase,1),1);
            Field.Ey = shiftdim(sum(S_y.*Phase,1),1);
            Field.Ez = shiftdim(sum(S_z.*Phase,1),1);
            Field.Hx = shiftdim(sum(U_x.*Phase,1),1);
            Field.Hy = shiftdim(sum(U_y.*Phase,1),1);
            Field.Hz = shiftdim(sum(U_z.*Phase,1),1);
         end
        end
        
        function CaculateGridField(FieldArr)
          for ii=1:numel(FieldArr)
            % This function caculate field in a grid
            % since here we take count of the first reflective layer the
            % device will start from the second layer 
            % initilize num_position_Layer
            Field=FieldArr(ii);       %Remember, this is a handle class!!!
            CheckPrerequisitesOfMonochromaticField(Field);
            num_layer = numel(Field.GridZ);
            num_position_Layer = zeros(num_layer,2);
            for i = 1:num_layer
                [num_position_Layer(i,1),num_position_Layer(i,2)] = FindLayer(Field,Field.GridZ(i));
            end
            NH = length(Field.Kx);
            Z = zeros(2*NH,2*NH);
            S_U_C = Field.W_V_ref*Field.C_input;                       % defint the input C in the first layer
            % initilize S_U
            C_input_layer = cell(1,max(num_position_Layer(:,1)));
            % caculate the input C for each layer
            C_input_layer{1,1} = S_U_C;
            % caculate input in every layer in which will caculate the field
            for n = 1 : max(num_position_Layer(:,1))-1 
                Middle = diag(Field.LAM{1,n})*Field.k0*Field.L(n);
                Elamda1 = diag(exp(-Middle));       % cacualte diangal lamda
                Elamda2 = diag(exp( Middle));
                Elamda_Diag = [Elamda1,Z;Z,Elamda2];
                C = Field.W_V{1,n}\C_input_layer{1,n};          % define input C at the each layer
                C_input_layer{1,n+1} = Field.W_V{1,n}*Elamda_Diag*C;    % input for the first layer
            end
            
            %initilize each layer
            [S_x_,S_y_,S_z_,U_x_,U_y_,U_z_]=deal(zeros(NH,1,1,num_layer));
            % caculate field in each layer
            for m = 1 : num_layer
                caculated_layer = num_position_Layer(m,1);
                Middle = diag(Field.LAM{1,caculated_layer})*Field.k0*num_position_Layer(m,2);
                Elamda1 = diag(exp(-Middle));       % cacualte diangal lamda
                Elamda2 = diag(exp( Middle));
                Elamda_Diag = [Elamda1,Z;Z,Elamda2];
                C = Field.W_V{1,caculated_layer}\C_input_layer{1,caculated_layer};          % define input C at the each layer
                S_U = Field.W_V{1,caculated_layer}*Elamda_Diag*C;    % input for the first layer
                S_x = S_U(1:NH,1);
                S_y = S_U(NH+1:2*NH,1);
                U_x = S_U(2*NH+1:3*NH,1);
                U_y = S_U(3*NH+1:4*NH,1);
                S_z_(:,1,1,m) = 1i*Field.URC(:,:,caculated_layer)\(Field.Kx*U_y - Field.Ky*U_x);
                U_z_(:,1,1,m) = 1i*Field.ERC(:,:,caculated_layer)\(Field.Kx*S_y - Field.Ky*S_x);
                S_x_(:,1,1,m)=S_x;
                S_y_(:,1,1,m)=S_y;
                U_x_(:,1,1,m)=U_x;
                U_y_(:,1,1,m)=U_y;
            end
            clear S_U  C_input_layer;
            clear S_x S_y U_x U_y
            
            % cacuate E and H at this layer
            Phase = exp(-1i*Field.k0*( full(diag(Field.Kx)).*Field.GridX + full(diag(Field.Ky)).*shiftdim(Field.GridY,-1) ));
            % cauclate E and H field         
            Field.Ex = shiftdim(sum(S_x_.*Phase,1),1);
            Field.Ey = shiftdim(sum(S_y_.*Phase,1),1);
            Field.Ez = shiftdim(sum(S_z_.*Phase,1),1);
            Field.Hx = shiftdim(sum(U_x_.*Phase,1),1);
            Field.Hy = shiftdim(sum(U_y_.*Phase,1),1);
            Field.Hz = shiftdim(sum(U_z_.*Phase,1),1);
%             clear Ex_ Ey_ Ez_ Hx_ Hy_ Hz_ IniZ
          end
        end
            

        
        function [numLayer,Z_position] = FindLayer(Field,depth)
            % This function will find in which layer the number is
            if ~isscalar(Field)
                error('Can''t work with arrays, please specify a single element');
            end
            if depth < 0
                error('Depth should be a positive number')
            elseif depth > sum(Field.L)
                error('Depth should not pass the depth of the device')
            end
            z_depth_device = Field.L(1);
            numLayer = 1;
            Z_position = depth;
            while depth > z_depth_device
                numLayer = numLayer + 1;
                Z_position = depth - z_depth_device;
                z_depth_device = z_depth_device + Field.L(numLayer);
            end
            
        end
        
        function ShowLayerField(FieldArr,varargin)
            % Purpose: this function show field in certain layer
            narginchk(1,3)
            isindexed=nargin>1 && isnumeric(varargin{end});
            if isindexed
                Field=FieldArr(varargin{end});
            else
                Field=FieldArr;
            end
            if ~isscalar(Field)
                error('Can''t work with arrays, please specify a single element');
            end
            
            if nargin-isindexed == 1
                m=2; n=3;
                FieldComps={'EH','xyz'};
            elseif nargin-isindexed == 2
                FieldComps=varargin{1};
                switch FieldComps
                    case {'Ex','Ey','Ez','Hx','Hy','Hz'}
                        m=1; n=1;
                        FieldComps={FieldComps(1) FieldComps(2)};
                    case {'E','H'}
                        m=1; n=3;
                        FieldComps={FieldComps 'xyz'};
                    otherwise
                        error('Wrong field designation')
                end
            else
                error('Wrong number of inputs')
            end
            
            [c1,c2]=deal([]);
            figure
            for im=1:m
                for in=1:n
                    subplot(m,n,(im-1)*n+in);
                    plotRCWAlayerField(Field,[FieldComps{1}(im) FieldComps{2}(in)]);
                    [c1,c2]=bounds([c1,c2,get(gca,'Clim')]);
                    if m==1 && n>1, axis square; end
                end
            end
            if c1*c2<0, c2=min(abs([c1,c2])); c1=-c2; end
            for im=1:m
                for in=1:n
                    subplot(m,n,(im-1)*n+in);
                    set(gca,'Clim',[c1,c2]);
                end
            end
        end
        
        function h=plotRCWAlayerField(Field,component,funcIndex)
            narginchk(2,3)
            if nargin==2, funcIndex=nan; end
            V=realField(Field,component,funcIndex);
%             V=real(V);
            if 0 %old style
                h=imagesc(V);
            elseif 0
                h=imagesc(Field.GridY,Field.GridX,V);
                ylabel('x'); xlabel('y');
            else
                if 01 %we recommend either this style or the next one
                    h=imagesc(Field.GridX,Field.GridY,V.');
                    set(gca,'YDir','normal');
                else
                    h=pcolor(Field.GridX,Field.GridY,V.');
                end
                xlabel('x'); ylabel('y');
            end
            title([component ' at z layer ', num2str(Field.LayerZ)]);
%             axis square;
        end
        
        function ShowGridField(FieldArr,varargin)
            narginchk(1,3)
            isindexed=nargin>1 && isnumeric(varargin{end});
            if isindexed
                Field=FieldArr(varargin{end});
            else
                Field=FieldArr;
            end
            if ~isscalar(Field)
                error('Can''t work with arrays, please specify a single element');
            end
            
            if nargin-isindexed == 1
                m=2; n=3;
                FieldComps={'EH','xyz'};
            elseif nargin-isindexed == 2
                FieldComps=varargin{1};
                switch FieldComps
                    case {'Ex','Ey','Ez','Hx','Hy','Hz'}
                        m=1; n=1;
                        FieldComps={FieldComps(1) FieldComps(2)};
                    case {'E','H'}
                        m=1; n=3;
                        FieldComps={FieldComps 'xyz'};
                    otherwise
                        error('Wrong field designation')
                end
            else
                error('Wrong number of inputs')
            end
            
            [c1,c2]=deal([]);
            figure
            for im=1:m
                for in=1:n
                    subplot(m,n,(im-1)*n+in);
                    plotRCWAgridField(Field,[FieldComps{1}(im) FieldComps{2}(in)]);
                    [c1,c2]=bounds([c1,c2,get(gca,'Clim')]);
                    if m==1 && n>1, axis square; end
                end
            end
            if c1*c2<0, c2=min(abs([c1,c2])); c1=-c2; end
            for im=1:m
                for in=1:n
                    subplot(m,n,(im-1)*n+in);
                    set(gca,'Clim',[c1,c2]);
                end
            end
        end
        
        function h=plotRCWAgridField(Field,component,funcIndex)
            narginchk(2,3)
            if nargin==2, funcIndex=nan; end
            V=realField(Field,component,funcIndex);
%             V=real(V);
            if 0 %old style
                h = slice(V,[],[],1:size(V,3));
            else
                h = slice(Field.GridX,Field.GridY,Field.GridZ, permute(V,[2,1,3]) ,[],[],Field.GridZ);
                xlabel('x'); ylabel('y'); zlabel('z');
            end
            set(h, 'EdgeColor','none', 'FaceColor','interp');
            alpha(0.5);
            title([component ' at grid from ', num2str(Field.GridZ(1)), ' to ',num2str(Field.GridZ(end))]);
%             axis square;
        end
        
        function V=realField(Field,component,funcIndex)
            narginchk(2,3)
            if nargin==1 || isempty(funcIndex) || isnan(funcIndex)
                funcIndex=3; 
            end
            V=Field.(component);
            switch funcIndex
                case 1
                    V=real(V);
                case 2
                    V=imag(V);
                case 3
                    V=abs(V);
                case 4
                    V=angle(V);
                case 0
                    V=V.*conj(V);
                otherwise
                    fgfdgsdfgsdfgsdgsdfgfd
                    error('Wrong function index');
            end
        end
        
    end
end








