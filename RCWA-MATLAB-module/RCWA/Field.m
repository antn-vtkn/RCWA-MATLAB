classdef Field < matlab.mixin.Copyable % & handle
    % This object will record the data which will be used to caculate
    % the field inside the device
    % Functions will be used to caculate field inside the device
    properties 
        wavenumber
        L
        xydimension
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
    end
    
    methods
        function GetPointField(Field,CoordinateXYZ)
            % This function get the parameters which will be caculated
            % later 
            if numel(CoordinateXYZ) == 3
              for ii=1:numel(Field)
                Field(ii).CoordXYZ(1:3) = CoordinateXYZ(1:3);%what is this indexing for?
              end
            else
                error('Check the number of the Coordinate')
            end
        end
        
        function GetLayerField(Field,XYGrid,ZLayer)
            % This function get the layer parameters which will be caculated
            if numel(XYGrid) == 2
              for ii=1:numel(Field)
                Field(ii).GridXY(1:2) = XYGrid(1:2);%what is this indexing for?
                Field(ii).LayerZ     = ZLayer;
              end
            else
                error('Check the number in the X and Y direction');
            end
        end
        
        function GetGridField(Field,XYGrid,Z_Grid)
            % This function get the grid parameters which will be caculated
            if numel(XYGrid) == 2
              for ii=1:numel(Field)
                Field(ii).GridXY(1:2) = XYGrid(1:2);%what is this indexing for?
                Field(ii).GridZ = Z_Grid;
              end
            else
                error('Check the number in the X and Y direction')
            end
        end
        
        function CaculateLayerField(FieldArr)
            % This function caculate the field in grid
          for ii=1:numel(FieldArr)
            Field=FieldArr(ii);       %Remember, this is a handle class!!!
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
            Nx = Field.GridXY(1);
            Ny = Field.GridXY(2);
            Lx = Field.xydimension(1);
            Ly = Field.xydimension(2);
            % initilize grid
            dx = Lx/Nx;                        %grid resolution along x
            dy = Ly/Ny;                        %grid resolution along y
            xa = [0:Nx-1]*dx;                      %x axis array
            xa = xa - mean(xa);                    %center x axis at zero
            ya = [0:Ny-1]*dy;                      %y axis vector
            ya = ya - mean(ya);                    %center y axis at zero
            % initilize E and H
%             IniZ = zeros(Nx,Ny);
%             Field.Ex = IniZ;
%             Field.Ey = IniZ;
%             Field.Ez = IniZ;
%             Field.Hx = IniZ;
%             Field.Hy = IniZ;
%             Field.Hz = IniZ;
            
%             for m = 1:numel(ya)
%                 for n = 1:numel(xa)
%                     Phase = exp(-1i*(diag(Field.Kx)*xa(n)+diag(Field.Ky)*ya(m)));
%                     Field.Ex(n,m) = sum(S_x.*Phase);
%                     Field.Ey(n,m) = sum(S_y.*Phase);
%                     Field.Ez(n,m) = sum(S_z.*Phase);
%                     Field.Hx(n,m) = sum(U_x.*Phase);
%                     Field.Hy(n,m) = sum(U_y.*Phase);
%                     Field.Hz(n,m) = sum(U_z.*Phase);
%                 end
%             end
            Phase = exp(-1i*( full(diag(Field.Kx)).*xa + full(diag(Field.Ky)).*shiftdim(ya,-1) ));
            Field.Ex = shiftdim(sum(S_x.*Phase,1),1);
            Field.Ey = shiftdim(sum(S_y.*Phase,1),1);
            Field.Ez = shiftdim(sum(S_z.*Phase,1),1);
            Field.Hx = shiftdim(sum(U_x.*Phase,1),1);
            Field.Hy = shiftdim(sum(U_y.*Phase,1),1);
            Field.Hz = shiftdim(sum(U_z.*Phase,1),1);
            Field.GridX=xa;
            Field.GridY=ya;
         end
        end
        
        function CaculateGridField(FieldArr)
          for ii=1:numel(FieldArr)
            Field=FieldArr(ii);       %Remember, this is a handle class!!!
            % This function caculate field in a grid
            % since here we take count of the first reflective layer the
            % device will start from the second layer 
            % initilize num_position_Layer
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
%             S_U = cell(1,num_layer);
%             S_x = cell(1,num_layer);
%             S_y = cell(1,num_layer);
%             S_z = cell(1,num_layer);
%             U_x = cell(1,num_layer);
%             U_y = cell(1,num_layer);
%             U_z = cell(1,num_layer);
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
            Nx = Field.GridXY(1);
            Ny = Field.GridXY(2);
            Lx = Field.xydimension(1);
            Ly = Field.xydimension(2);
            % initilize grid
            xa = linspace(-Lx/2,Lx/2,Nx+1);
            ya = linspace(-Ly/2,Ly/2,Ny+1);
%             [xxa,yya] = meshgrid(xa,ya);
%             dx = Lx/Nx;                        %grid resolution along x
%             dy = Ly/Ny;                        %grid resolution along y
%             xa = [0:Nx-1]*dx;                      %x axis array
%             xa = xa - mean(xa);                    %center x axis at zero
%             ya = [0:Ny-1]*dy;                      %y axis vector
%             ya = ya - mean(ya);                    %center y axis at zero
            % initilize E and H
            IniZ = zeros(Nx+1,Ny+1,num_layer);
%             Ex_ = IniZ;
%             Ey_ = IniZ;
%             Ez_ = IniZ;
%             Hx_ = IniZ;
%             Hy_ = IniZ;
%             Hz_ = IniZ;        
%             Kx_ = full(diag(Field.Kx));
%             Ky_ = full(diag(Field.Ky));
            Phase = exp(-1i*( full(diag(Field.Kx)).*xa + full(diag(Field.Ky)).*shiftdim(ya,-1) ));
            % cauclate E and H field         
            Field.Ex = shiftdim(sum(S_x_.*Phase,1),1);
            Field.Ey = shiftdim(sum(S_y_.*Phase,1),1);
            Field.Ez = shiftdim(sum(S_z_.*Phase,1),1);
            Field.Hx = shiftdim(sum(U_x_.*Phase,1),1);
            Field.Hy = shiftdim(sum(U_y_.*Phase,1),1);
            Field.Hz = shiftdim(sum(U_z_.*Phase,1),1);
            Field.GridX=xa;
            Field.GridY=ya;
%             for i = 1:num_layer
%                 Ex_(:,:,i) = shiftdim(sum(S_x{i}.*Phase,1),1);
%                 Ey_(:,:,i) = shiftdim(sum(S_y{i}.*Phase,1),1);
%                 Ez_(:,:,i) = shiftdim(sum(S_z{i}.*Phase,1),1);
%                 Hx_(:,:,i) = shiftdim(sum(U_x{i}.*Phase,1),1);
%                 Hy_(:,:,i) = shiftdim(sum(U_y{i}.*Phase,1),1);
%                 Hz_(:,:,i) = shiftdim(sum(U_z{i}.*Phase,1),1);
% %                 for m = 1:numel(ya)
% %                     for n = 1:numel(xa)
% %                         Phase = exp(-1i*(Kx_*xa(n)+Ky_*ya(m)));
% %                         Ex_(n,m,i) = sum(S_x{i}.*Phase);
% %                         Ey_(n,m,i) = sum(S_y{i}.*Phase);
% %                         Ez_(n,m,i) = sum(S_z{i}.*Phase);
% %                         Hx_(n,m,i) = sum(U_x{i}.*Phase);
% %                         Hy_(n,m,i) = sum(U_y{i}.*Phase);
% %                         Hz_(n,m,i) = sum(U_z{i}.*Phase);
% %                     end
% %                 end
%             end
%             Field.Ex = Ex_;
%             Field.Ey = Ey_;
%             Field.Ez = Ez_;
%             Field.Hx = Hx_;
%             Field.Hy = Hy_;
%             Field.Hz = Hz_;
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
            z_depth = depth;
            z_depth_device = Field.L(1);
            numLayer = 1;
            Z_position = z_depth;
            while z_depth > z_depth_device
                numLayer = numLayer + 1;
                Z_position = z_depth - z_depth_device;
                z_depth_device = z_depth_device + Field.L(numLayer);
            end
            
        end
        
        function ShowLayerField(FieldArr,varargin)
            % Purpose: this function show field in certain layer
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
                figure
                subplot(231)
                plotRCWAlayerField(Field,'Ex');
                subplot(232)
                plotRCWAlayerField(Field,'Ey');
                subplot(233)
                plotRCWAlayerField(Field,'Ez');
                subplot(234)
                plotRCWAlayerField(Field,'Hx');
                subplot(235)
                plotRCWAlayerField(Field,'Hy');
                subplot(236)
                plotRCWAlayerField(Field,'Hz');
            elseif nargin-isindexed == 2
                switch varargin{1}
                    case {'Ex','Ey','Ez','Hx','Hy','Hz'}
                        figure
                        plotRCWAlayerField(Field,varargin{1});
                    case {'E','H'}
                        figure
                        subplot(131)
                        plotRCWAlayerField(Field, [varargin{1},'x']);
                        axis square;
                        subplot(132)
                        plotRCWAlayerField(Field, [varargin{1},'y']);
                        axis square;
                        subplot(133)
                        plotRCWAlayerField(Field, [varargin{1},'z']);
                        axis square;
                    otherwise
                        error('Wrong field designation')
                end
            else
                error('Wrong number of inputs')
            end
    
        end
        
        function h=plotRCWAlayerField(Field,field)
            if 0 %old style
                h=imagesc(real(Field.(field)));
            elseif 0
                h=imagesc(Field.GridY,Field.GridX,real(Field.(field)));
                ylabel('x'); xlabel('y');
            else
                if 01 %we recommend either this style or the next one
                    h=imagesc(Field.GridX,Field.GridY,real(Field.(field)).');
                    set(gca,'YDir','normal');
                else
                    h=pcolor(Field.GridX,Field.GridY,real(Field.(field)).');
                end
                xlabel('x'); ylabel('y');
            end
            title([field ' at z layer ', num2str(Field.LayerZ)]);
%             axis square;
        end
        
        function ShowGridField(FieldArr,varargin)
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
                figure
                subplot(231)
                plotRCWAgridField(Field,'Ex');
                subplot(232)
                plotRCWAgridField(Field,'Ey');
                subplot(233)
                plotRCWAgridField(Field,'Ez');
                subplot(234)
                plotRCWAgridField(Field,'Hx');
                subplot(235)
                plotRCWAgridField(Field,'Hy');
                subplot(236)
                plotRCWAgridField(Field,'Hz');
            elseif nargin-isindexed == 2
                switch varargin{1}
                    case {'Ex','Ey','Ez','Hx','Hy','Hz'}
                        figure
                        plotRCWAgridField(Field,varargin{1});
                    case {'E','H'}
                        figure
                        subplot(131)
                        plotRCWAgridField(Field, [varargin{1},'x']);
                        axis square;
                        subplot(132)
                        plotRCWAgridField(Field, [varargin{1},'y']);
                        axis square;
                        subplot(133)
                        plotRCWAgridField(Field, [varargin{1},'z']);
                        axis square;
                    otherwise
                        error('Wrong field designation')
                end
            else
                error('Wrong number of inputs')
            end     
        end
        
        function h=plotRCWAgridField(Field,field)
            if 0 %old style
                h = slice(real(Field.(field)),[],[],1:size(Field.(field),3));
            else
                h = slice(Field.GridX,Field.GridY,Field.GridZ, permute(real(Field.(field)),[2,1,3]) ,[],[],Field.GridZ);
                xlabel('x'); ylabel('y'); zlabel('z');
            end
            set(h, 'EdgeColor','none', 'FaceColor','interp');
            alpha(0.5);
            title([field ' at grid from ', num2str(Field.GridZ(1)), ' to ',num2str(Field.GridZ(end))]);
%             axis square;
        end
        
    end
end








