%% 清空环境变量以及加载数据
clc
clear
close all
warning off 
format long
format compact
%% 网络结构建立
%读取数据
load img_tz %纹理特征

%%
%由于特征维数过高，每个gabbor特征有1440维，不利于训练网络，因此我们用PCA进行降维
[pca1,pca2,pca3]=pca(input);
proportion=0;
i=1;
while(proportion < 95)
    proportion = proportion + pca3(i);
    i = i+1;
end
input=pca2(:,1:10);
%随机提取训练样本，预测样本
rand('seed',0)
[m n]=sort(rand(1,size(input,1)));
m=150;
train_wine=input(n(1:m),:);
train_wine_labels=output(n(1:m),:);
test_wine=input(n(m+1:end),:);
test_wine_labels=output(n(m+1:end),:);

%% 
%%%%% 选择最佳的SVM参数c&g-利用粒子群算法进行选择
% 粒子群参数初始化
pso_option = struct('c1',0.9,'c2',0.9,...
    'maxgen',200,'sizepop',50, ...
    'k',0.6,'wV',0.8,'wP',0.8, ...
    'popcmax',10^2,'popcmin',10^(-2),...
    'popgmax',10^2,'popgmin',10^(-2));
%%
[bestacc,bestc,bestg,trace] = psoSVMcgForClass(train_wine_labels,train_wine,test_wine_labels,test_wine,pso_option);
GlobalParams=[bestc bestg];

figure
plot(trace(:,1),'p-','LineWidth',1.5);hold on
plot(trace(:,2),'*-','LineWidth',1.5)
xlabel('迭代次数')
legend('当前最优适应度值','当前平均适应度值')
ylabel('适应度(分类错误率)')
line1 = '适应度曲线Accuracy[PSO寻优]';
line2 = ['终止代数=', ...
    num2str(pso_option.maxgen),',种群数量pop=', ...
    num2str(pso_option.sizepop),')'];
line3 = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
    ' CVAccuracy=',num2str((1-trace(end,1))*100),'%'];
title({line1;line2;line3},'FontSize',12);



%%
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
model = svmtrain(train_wine_labels,train_wine,cmd);
[predict1] = svmpredict(train_wine_labels,train_wine,model);
[train_wine_labels n]=sort(train_wine_labels);

figure;
hold on;
stem(train_wine_labels,'o');
plot(predict1(n),'r*');
xlabel('训练集样本','FontSize',12);
ylabel('类别标签','FontSize',12);
legend('实际训练集分类','预测训练集分类');
title('训练集分类结果','FontSize',12);
grid on;

%% SVM网络预测
[predict_label,accuracy] = svmpredict(test_wine_labels,test_wine,model);
% 打印测试集分类准确率
total = length(test_wine_labels);
right = sum(predict_label == test_wine_labels);


%% 结果分析
[test_wine_labels n]=sort(test_wine_labels);

figure;
hold on;
stem(test_wine_labels,'o');
plot(predict_label(n),'r*');
xlabel('测试集样本','FontSize',12);
ylabel('类别标签','FontSize',12);
legend('实际测试集分类','预测测试集分类');
title('测试集分类结果','FontSize',12);
grid on;