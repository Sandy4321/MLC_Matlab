
% Add sub-folders containing functions
addpath('data','evaluation');
addpath(genpath('method'));

% Load a multi-label dataset
dataset = 'emotions';
load([dataset,'.mat']);

% Perform n-fold cross validation and obtain evaluation results
num_fold = 3; num_metric = 4; num_method = 10;
indices = crossvalind('Kfold',size(data,1),num_fold);
Results = zeros(num_metric+1,num_fold,num_method);
for i = 1:num_fold
    disp(['Fold ',num2str(i)]);
    test = (indices == i); train = ~test; 
%     % The BR method with Ridge Regression
%     tic;
%     [Pre_Labels,~] = BRridge(data(train,:),target(:,train'),data(test,:));
%     Results(1,i,1) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,1) = [ExactM,HamS,MacroF1,MicroF1];
%     % The CC method with Ridge Regression
%     tic;
%     [Pre_Labels,~] = CCridge(data(train,:),target(:,train'),data(test,:));
%     Results(1,i,2) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,2) = [ExactM,HamS,MacroF1,MicroF1];
%     % The ensemble MLC method
%     tic; percent = [0.5,0.8,0.8];
%     [Pre_Labels,~] = EnMLC(data(train,:),target(:,train'),data(test,:),percent,20,@CCridge);
%     Results(1,i,3) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,3) = [ExactM,HamS,MacroF1,MicroF1];
%     % The CBMLC method with Ridge Regression
%     tic; num_cluster = 2;
%     [Pre_Labels,~] = CBMLC(data(train,:),target(:,train'),data(test,:),num_cluster,@EnMLC);
%     Results(1,i,4) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,4) = [ExactM,HamS,MacroF1,MicroF1];
%     % The CLMLC method with Ridge Regression
%     tic; num_cluster = 2;
%     [Pre_Labels,~] = CLMLCv1(data(train,:),target(:,train'),data(test,:),num_cluster,@EnMLC);
%     Results(1,i,5) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,5) = [ExactM,HamS,MacroF1,MicroF1];
%     % The BR method with PCA
%     tic; alg = 'PCA';
%     [Pre_Labels,~] = BR_DR(data(train,:),target(:,train'),data(test,:),alg);
%     Results(1,i,6) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,6) = [ExactM,HamS,MacroF1,MicroF1];
%     % The BR method with OPLS
%     tic; alg = 'OPLS';
%     [Pre_Labels,~] = BR_DR(data(train,:),target(:,train'),data(test,:),alg);
%     Results(1,i,7) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,7) = [ExactM,HamS,MacroF1,MicroF1];
%     % The BR method with HLS
%     tic; alg = 'HSL';
%     [Pre_Labels,~] = BR_DR(data(train,:),target(:,train'),data(test,:),alg);
%     Results(1,i,8) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,8) = [ExactM,HamS,MacroF1,MicroF1];
    % BR with SVM
    tic;
    [Pre_Labels,~] = BRsvm(data(train,:),target(:,train'),data(test,:),target(:,test'));
    Results(1,i,9) = toc;
    [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
    Results(2:end,i,9) = [ExactM,HamS,MacroF1,MicroF1];
    % CC with SVM
    tic;
    [Pre_Labels,~] = CCsvm(data(train,:),target(:,train'),data(test,:),target(:,test'));
    Results(1,i,10) = toc;
    [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
    Results(2:end,i,10) = [ExactM,HamS,MacroF1,MicroF1];

%     % CPLST - Label Space Dimension Reduction
%     tic; M = 5;
%     Pre_Labels = CPLST(data(train,:),target(:,train'),data(test,:),M);
%     Results(1,i,5) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,5) = [ExactM,HamS,MacroF1,MicroF1];
%     % PLST - Label Space Dimension Reduction
%     tic; M = 5;
%     Pre_Labels = PLST(data(train,:),target(:,train'),data(test,:),M);
%     Results(1,i,6) = toc;
%     [ExactM,HamS,MacroF1,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
%     Results(2:end,i,6) = [ExactM,HamS,MacroF1,MicroF1];
end
ignore = [3:8];  Results(:,:,ignore) = [];
meanResults = squeeze(mean(Results,2));
stdResults = squeeze(std(Results,0,2) / sqrt(size(Results,2)));

% Save the evaluation results
filename=strcat('results/',dataset,'.mat');
save(filename,'meanResults','stdResults','-mat');

% Show the experimental results
disp(meanResults);
figure('Position', [300 300 800 500]);
bar(meanResults);
str1 = {'Execution time';'Exact match';'Hamming Score';'Macro F1';'Micro F1'};
set(gca, 'XTickLabel',str1);
xlabel('Metric','FontSize', 14); ylabel('Performance','FontSize', 14);
str2 = {'BR','CC','EnMLC','CBMLC','CLMLC','BRPCA','BROPLS','BRHSL'}; str2(ignore) = [];
legend(str2,'Location','NorthWest');





