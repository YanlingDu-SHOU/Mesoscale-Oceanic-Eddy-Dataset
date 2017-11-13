clear all; close all; clc; 
addpath('D:\Matlab\PCANet_demo_pyramid\Utils');
addpath('D:\Matlab\PCANet_demo_pyramid\Liblinear');

%TrnSize = 136; 
ImgSize_m = 280;
ImgSize_n = 280;


DataPath = 'D:\Matlab\Eddy';

TrnLabels = [];
TrnData = [];

load(fullfile(DataPath,['Trn_data_1117.mat']));
TrnData = [TrnData, trn_data'];
TrnLabels = [TrnLabels; trn_label];
%end
load(fullfile(DataPath,'test_data_1117.mat'));
TestData = test_data';
TestLabels = test_label;

ImgFormat = 'gray'; %'gray'

TrnLabels = double(TrnLabels);
TestLabels = double(TestLabels);

nTestImg = length(TestLabels);

PCANet.NumStages = 2;
PCANet.PatchSize = [5 5];
PCANet.NumFilters = [18 8];
PCANet.HistBlockSize = [8 8];
PCANet.BlkOverLapRatio = 0.5;
PCANet.Pyramid =  [3 2 1];
 
fprintf('\n ====== PCANet Parameters ======= \n')
PCANet

%% PCANet Training with 10000 samples
fprintf('\n ====== PCANet Training ======= \n')
TrnData_ImgCell = mat2imgcell(double(TrnData),ImgSize_m,ImgSize_n,ImgFormat); % convert columns in TrnData to cells 
tic; 
[ftrain, V, BlkIdx] = PCANet_train(TrnData_ImgCell,PCANet,1); % BlkIdx serves the purpose of learning block-wise DR projection matrix; e.g., WPCA
PCANet_TrnTime = toc;


%% PCA hashing over histograms
c = 2; 
fprintf('\n ====== Training Linear SVM Classifier ======= \n')
display(['now testing c = ' num2str(c) '...'])
tic;
models = train(TrnLabels, ftrain', ['-s 1 -c ' num2str(c) ' -q']); % we use linear SVM classifier (C = 10), calling liblinear library
LinearSVM_TrnTime = toc;


%% PCANet Feature Extraction and Testing 

TestData_ImgCell = mat2imgcell(TestData,ImgSize_m,ImgSize_n,ImgFormat); % convert columns in TestData to cells 
clear TestData; 

fprintf('\n ====== PCANet Testing ======= \n')

nCorrRecog = 0;
RecHistory = zeros(nTestImg,1);

tic; 
for idx = 1:1:nTestImg
    ftest = PCANet_FeaExt(TestData_ImgCell(idx),V,PCANet); % extract a test feature using trained PCANet model 

    [xLabel_est, accuracy, decision_values] = predict(TestLabels(idx),...
        sparse(ftest'), models, '-q');
    
    if xLabel_est == TestLabels(idx)
        RecHistory(idx) = 1;
        nCorrRecog = nCorrRecog + 1;
    end
    
    %if 0==mod(idx,nTestImg/1000); 
        fprintf('Accuracy up to %d tests is %.2f%%; taking %.2f secs per testing sample on average. \n',...
            [idx 100*nCorrRecog/idx toc/idx]); 
    %end 
    
    TestData_ImgCell{idx} = [];
    
end
Averaged_TimeperTest = toc/nTestImg;
Accuracy = nCorrRecog/nTestImg; 
ErRate = 1 - Accuracy;

%% Results display
fprintf('\n ===== Results of PCANet, followed by a linear SVM classifier =====');
fprintf('\n     PCANet training time: %.2f secs.', PCANet_TrnTime);
fprintf('\n     Linear SVM training time: %.2f secs.', LinearSVM_TrnTime);
fprintf('\n     Testing error rate: %.2f%%', 100*ErRate);
fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);