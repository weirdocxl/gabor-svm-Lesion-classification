%% 清空环境变量以及加载数据
clc
clear
close all
warning off 
format long
format compact
%% 利用支持向量机进行分类，先添加libsvm相关工具,即把libsvm-3.12 添加路径（以包含子文件夹方式）
%% 详情见MATLAB神经网络43个案例分析
%% 网络结构建立
%读取数据
load img_tz %纹理特征

%%
%由于特征维数过高，每个gabbor特征有1440维，不利于训练网络，因此我们用PCA进行降维
[pca1,pca2,pca3]=pca(input);
input=pca2(:,1:10);%这个函数是matlab自带的pca降维工具
% 这样就将gabor提取到的1440维降到了10维

%随机提取150组样本作为训练样本，剩下的作为测试样本--要换训练集样本数 修改m即可
rand('seed',0)
[m n]=sort(rand(1,size(input,1)));
m=150;
train_wine=input(n(1:m),:);
train_wine_labels=output(n(1:m),:);
test_wine=input(n(m+1:end),:);
test_wine_labels=output(n(m+1:end),:);

%% 支持向量机
% 参数设置
bestc=41.7265;
bestg=0.0106;
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
% 训练SVM模型
model = svmtrain(train_wine_labels,train_wine,cmd);
[predict1] = svmpredict(train_wine_labels,train_wine,model);
%
[train_wine_labels n]=sort(train_wine_labels);%对结果进行排序，使得画出来的结果图只管一点

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