
% Add sub-folders containing functions
addpath('data','evaluation');
addpath(genpath('method'));

% Load a multi-label dataset
dataset = 'tmc2007';
load([dataset,'.mat']);

% Make experimental resutls repeatly
rng('default');

% Randomly select part of data
max_num = 6000;
if size(data,1) > max_num
    nRows = size(data,1); 
    nSample = max_num;
    rndIDX = randperm(nRows);
    index = rndIDX(1:nSample);
    data = data(index, :);
    target = target(:,index);
end

% % Perform n-fold cross validation and obtain evaluation results
% num_fold = 5; num_metric = 3; num_method = 3;
% num_cluster = 10; model = @CCridge;
% indices = crossvalind('Kfold',size(data,1),num_fold);
% Results = zeros(num_metric+1,num_fold,num_method);
% Final_mean = zeros(num_metric+1,num_method,num_cluster-1);
% Final_std = zeros(num_metric+1,num_method,num_cluster-1);

% Perform n-fold cross validation and obtain evaluation results
num_fold = 3; num_metric = 3; num_method = 3;
num_cluster = 12; model = @CCridge;
indices = crossvalind('Kfold',size(data,1),num_fold);
Results = zeros(num_metric+1,1,num_method);
Final_mean = zeros(num_metric+1,num_method,num_cluster-1);
Final_std = zeros(num_metric+1,num_method,num_cluster-1);

for k = 1:(num_cluster-1)
%     for i = 1:num_fold
        test = (indices == 1); train = ~test;
        
        if (k==1)
            % The CC method with Ridge Regression
            tic;
            [Pre_Labels,~] = CCridge(data(train,:),target(:,train'),data(test,:));
            Results(:,1,1) = toc;
            [ExactM,HamS,~,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
            Results(2:end,1,1) = [ExactM,HamS,MicroF1];
        end
        
        % The CBMLC method with Ridge Regression
        tic;
        [Pre_Labels,~] = CBMLC(data(train,:),target(:,train'),data(test,:),k+1,model);
        Results(:,1,2) = toc;
        [ExactM,HamS,~,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
        Results(2:end,1,2) = [ExactM,HamS,MicroF1];
        
        % The CLMLC method only with the first stage
        tic;
        [Pre_Labels,~] = CLMLC(data(train,:),target(:,train'),data(test,:),k+1,model);
        Results(:,1,3) = toc;
        [ExactM,HamS,~,MicroF1] = Evaluation(Pre_Labels,target(:,test'));
        Results(2:end,1,3) = [ExactM,HamS,MicroF1];
        
%     end
    
    meanResults = squeeze(mean(Results,2));
    stdResults = squeeze(std(Results,0,2) / sqrt(size(Results,2))); 
    Final_mean(:,:,k) = meanResults;
    Final_std(:,:,k) = stdResults;
end;

% Display the experimental results
dg = [0 0.4 0];
dr = [0.8 0 0];
db = [0 0.3 0.7];
dy = [0.6 0 0.6];	
dp = [0.502 0 0];

y_mean = zeros((num_metric+1),(num_cluster-1),num_method);
y_std = zeros((num_metric+1),(num_cluster-1),num_method);
for i = 1:num_method
    y_mean(:,:,i) = Final_mean(:,i,:);
    y_std(:,:,i) = Final_std(:,i,:);
end

x_axis = 2:num_cluster;
metric_str = {'Execution time','Exact-Match', 'Hamming-Score','Micro-F1'};
for i = 1:(num_metric+1)
    figure('Position', [50 50 1000 500]);
    plot(x_axis,y_mean(i,:,1),'-^', 'MarkerEdgeColor', db, 'Color', db, 'MarkerFaceColor', db, 'MarkerSize',14, 'LineWidth', 6);
    hold on;
    plot(x_axis,y_mean(i,:,2),'-o','MarkerEdgeColor', dg, 'Color', dg, 'MarkerFaceColor', dg, 'MarkerSize',14, 'LineWidth', 6);
    hold on;
    plot(x_axis,y_mean(i,:,3),'-s', 'MarkerEdgeColor', dr, 'Color', dr, 'MarkerFaceColor', dr,'MarkerSize',14, 'LineWidth', 6);
    hold on;
%     plot(x_axis,y_mean(i,:,4),'-d', 'MarkerEdgeColor', dp, 'Color', dp,  'LineWidth', 3);
%     hold on;
%     plot(x_axis,y_mean(i,:,5),'-*', 'MarkerEdgeColor', dy, 'Color', dy,  'LineWidth', 3);
%     hold on;
    grid on;
    
    xlabel('$k$','Interpreter','LaTex','FontSize', 40);
    ylabel(metric_str(i), 'FontSize', 34);
    if i == 1
        lgd = legend('CC','CBMLC','CLMLC','Location','northwest');
    else
        lgd = legend('CC','CBMLC','CLMLC');
    end
    set(lgd,  'fontsize', 28);
    set(gca,'fontsize',28)
end





