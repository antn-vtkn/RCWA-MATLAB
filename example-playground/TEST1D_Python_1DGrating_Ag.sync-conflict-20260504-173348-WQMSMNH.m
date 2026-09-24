% 为了保证计算结果的准确性，和一些文献的结果进行对比
% 这里和Python的结果进行对比：来自github仓库，https://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis
% 用来对比的源Python代码地址：https://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis/blob/master/RCWA_1D_examples/1D_Grating_Gaylord_TE.py

addpath(genpath('.'));

% eps_layer=3.48^2;
width=0.3*0.7;
period=0.7;
d_groove=0.26;
d_coating=0.2;
% lambda=linspace(500,2300,401);
epssup=1;epssdn=1;
num_xy=1021;
numz=1;
num_har=2*2*2*2*50+1;
num_xy=2*num_har-1;
mid_layer=Material('Ag');
substrate=Material('silicon');%the lattice is different; unable to process properly as of now
lambda=real(mid_layer.er(:,1))*1e3;%mkm to nm
%% 
Air = Material('test',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[0,0],[0*1,01]);
Dev = Device([period,period*8],[num_xy,1],[num_har,1]);
AddLayer(Dev,Air,d_groove,numz);
AddPattern(Dev,'Rectangle',[period/2,period*8/2],[width width],1,mid_layer);
AddLayer(Dev,mid_layer,d_coating,1);
AddLayer(Dev,substrate,10*d_groove,1);
% Run Simulations
RecordDiffOrder(Simul);
RCWARun(Simul,S,Dev)
PlotRT(Simul)

saveas(gcf,'./figures/TEST1D_Python_1DGrating_Ag.png');

%%
threshold=1e-3;
figure; 
plot(Simul.source.wavelength/Simul.nanometers,squeeze(Simul.Ref_order(any(Simul.Ref_order>threshold,3),:,:))');  %out of 1
% plot(Simul.source.wavelength/Simul.nanometers,squeeze(Simul.Ref_order(any(Simul.Ref_order~=0,3),:,:))');
legend;
hold on; 
% figure;
plot(Simul.source.wavelength/Simul.nanometers,squeeze(Simul.Trn_order(any(Simul.Trn_order>threshold,3),:,:))');  %out of 1
% plot(Simul.source.wavelength/Simul.nanometers,squeeze(Simul.Trn_order(any(Simul.Trn_order~=0,3),:,:))'); 
legend;

