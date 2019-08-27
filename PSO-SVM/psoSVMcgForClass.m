function [bestCVaccuarcy,bestc,bestg,trace] = psoSVMcgForClass(train_wine_labels,train_wine,test_wine_labels,test_wine,pso_option)
if nargin == 4
    pso_option = struct('c1',0.9,'c2',0.9,'maxgen',100,'sizepop',10, ...
        'k',0.6,'wV',0.8,'wP',0.8,'v',5, ...
        'popcmax',10^2,'popcmin',10^(-2),'popgmax',10^2,'popgmin',10^(-2));
end
% c1:初始为1.5,pso参数局部搜索能力
% c2:初始为1.7,pso参数全局搜索能力
% maxgen:初始为200,最大进化数量
% sizepop:初始为20,种群最大数量
% k:初始为0.6(k belongs to [0.1,1.0]),速率和x的关系(V = kX)
% wV:初始为1(wV best belongs to [0.8,1.2]),速率更新公式中速度前面的弹性系数
% wP:初始为1,种群更新公式中速度前面的弹性系数
% v:初始为3,SVM Cross Validation参数
% popcmax:初始为100,SVM 参数c的变化的最大值.
% popcmin:初始为0.1,SVM 参数c的变化的最小值.
% popgmax:初始为1000,SVM 参数g的变化的最大值.
% popgmin:初始为0.01,SVM 参数c的变化的最小值.

Vcmax = pso_option.k*pso_option.popcmax;
Vcmin = -Vcmax ;
Vgmax = pso_option.k*pso_option.popgmax;
Vgmin = -Vgmax ;

eps = 10^(-3);

% 产生初始粒子和速度
for i=1:pso_option.sizepop
    
    % 随机产生种群和速度
    pop(i,1) = (pso_option.popcmax-pso_option.popcmin)*rand+pso_option.popcmin;
    pop(i,2) = (pso_option.popgmax-pso_option.popgmin)*rand+pso_option.popgmin;
    V(i,1)=Vcmax*rands(1,1);
    V(i,2)=Vgmax*rands(1,1);
    % 计算初始适应度
    fitness(i) =fun(pop(i,:),train_wine_labels,train_wine,test_wine_labels,test_wine)
end

% 找极值和极值点
local_fitness=fitness;    % 个体极值初始化
local_x=pop;              % 个体极值点

[global_fitness     bestindex]=min(fitness); % 全局极值
global_x=pop(bestindex,:);                   % 全局极小值对应的全局极值点

% 每一代种群的平均适应度
avgfitness_gen = zeros(1,pso_option.maxgen);

% 迭代寻优
for i=1:pso_option.maxgen
    
    for j=1:pso_option.sizepop
        
        %速度更新
        V(j,:) = pso_option.wV*V(j,:) + pso_option.c1*rand*(local_x(j,:) - pop(j,:)) + pso_option.c2*rand*(global_x - pop(j,:));
        if V(j,1) > Vcmax
            V(j,1) = Vcmax;
        end
        if V(j,1) < Vcmin
            V(j,1) = Vcmin;
        end
        if V(j,2) > Vgmax
            V(j,2) = Vgmax;
        end
        if V(j,2) < Vgmin
            V(j,2) = Vgmin;
        end
        
        %种群更新
        pop(j,:)=pop(j,:) + pso_option.wP*V(j,:);
        
        if pop(j,1) > pso_option.popcmax
            pop(j,1) =(pso_option.popcmax-pso_option.popcmin)*rand + pso_option.popcmin;
        end
        if pop(j,1) < pso_option.popcmin
            pop(j,1) = (pso_option.popcmax-pso_option.popcmin)*rand + pso_option.popcmin;
        end
        if pop(j,2) > pso_option.popgmax
            pop(j,2) =  (pso_option.popgmax-pso_option.popgmin)*rand + pso_option.popgmin;
        end
        if pop(j,2) < pso_option.popgmin
            pop(j,2) =  (pso_option.popgmax-pso_option.popgmin)*rand + pso_option.popgmin;
        end
        
        % 自适应粒子变异
        if rand>0.5
            k=ceil(2*rand);
            if k == 1
                pop(j,k) =(pso_option.popcmax-pso_option.popcmin)*rand + pso_option.popcmin;
            end
            if k == 2
                pop(j,k) = (pso_option.popgmax-pso_option.popgmin)*rand + pso_option.popgmin;
            end
        end
        
        %适应度值
        fitness(j) = fun(pop(j,:),train_wine_labels,train_wine,test_wine_labels,test_wine);
        
        
        %个体最优更新
        if fitness(j) <local_fitness(j)
            local_x(j,:) = pop(j,:);
            local_fitness(j) = fitness(j);
        end
        
        if abs( fitness(j)-local_fitness(j) )<=eps && pop(j,1) > local_x(j,1)
            local_x(j,:) = pop(j,:);
            local_fitness(j) = fitness(j);
        end
        
        %群体最优更新
        if fitness(j) < global_fitness
            global_x = pop(j,:);
            global_fitness = fitness(j);
        end
        
        
    end
    
    avgfitness_gen(i) = sum(fitness)/pso_option.sizepop;%平均适应度
    fit_gen(i) = global_fitness;%最佳适应度
end
% 结果
bestc = global_x(1);
bestg = global_x(2);
bestCVaccuarcy = -fit_gen(pso_option.maxgen);
trace=[fit_gen ;avgfitness_gen]';