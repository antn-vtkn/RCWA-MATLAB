% 从结果中获取电磁场
% 只选取特定的波长即可

% addpath(genpath('.'));
RCWAupdatePATH


eps_layer=12;
radius=0.2;
width=1;
d=0.5;

% 注意原文章的横坐标的归一化方式！
lambda=1000;
epssup=1;epssdn=1;
num_xy=521;
numz=1;
num_har=7;

mid_layer=Material('Mid',[eps_layer,1]);
Air = Material('Air',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[0,0],[1,0]);
Dev = Device([width,width],[num_xy,num_xy],[num_har,num_har]);
Dev.optimizeUconst=01;
Dev.optimizeEconst=01;
AddLayer(Dev,mid_layer,d,1);
AddPattern(Dev,'Cylinder',[width/2,width/2],radius,1,Air);

% Activate the field recorder
ConstructField(Simul);% 用于记录场
XYGrid=[20 10];
XYGrid=[200 100];
%% To obtain the field in specific plane
% Thefield grid
field=Field();
ZLayer=0.1;
GetLayerField(field,XYGrid,ZLayer);
RCWARun(Simul,S,Dev,field,0);
ShowLayerField(field);

%% To obatin the field in xyz grid
field2=Field();
Z_Grid=linspace(0,0.5,10);
GetGridField(field2,XYGrid,Z_Grid);
RCWARun(Simul,S,Dev,field2,0);
ShowGridField(field2);
