clear
clc
model_width=50;% 骨料所投放空间的宽
model_length=55;% 骨料所投放空间的长
model_height=50;% 骨料所投放空间的高
model_geometry=model_width * model_height * model_length;% 骨料所投放空间的体积，骨料投放的空间是一个立方体
aggregate_ratio=0.45;% 骨料的体积占模型几何总体积的比例
model_geometry_for_aggregate=aggregate_ratio * model_geometry;
aggregate_diameter=[5 10 15 20];%粗骨料粒径分布
max_aggregate_diameter=max(aggregate_diameter);%粗骨料最大粒径
aggregate_volu=100*sqrt(aggregate_diameter/max_aggregate_diameter);%富勒曲线确定粗骨料体积比
aggregate_volu_ratio=diff(aggregate_volu)/sum(diff(aggregate_volu));%确定5-10,10-15,15-20各骨料粒径范围体积比

for j = 1:1:length(aggregate_volu_ratio);
    aggregate_sum_volu=0;% 当前粒径范围下生成的各个骨料总体积
    num=0;% 当前粒径范围下生成的符合条件的骨料的数目
    while aggregate_sum_volu < model_geometry_for_aggregate*aggregate_volu_ratio(j);%生成5-10mm骨料
          num=num+1;
          r(j,num)=aggregate_diameter(j)/2+rand(1)*(aggregate_diameter(j+1)-aggregate_diameter(j))/2;% 计算当前粒径范围下符合条件的第num个骨料的随机半径
          r_volu=4/3*pi*r(j,num)^3;
          aggregate_sum_volu=aggregate_sum_volu+r_volu;
    end
end

aggregate_database=r(:); %将r中所有的列拼接成为一个列向量
aggregate_database=sort(aggregate_database,'descend');
aggregate_database(aggregate_database==0)=[];  %将aggregate_database中为0的行删除，生成骨料投放库，投放库中卫为符合要求的粒径

% 寻找第一个骨料的投放位置
flag=0;
while flag<1
    rand_num=rand(3,1);
    if model_width*(1-rand_num(1))>aggregate_database(1)&& model_width*rand_num(1)>aggregate_database(1)&& model_height*(1-rand_num(2))+3>aggregate_database(1)&&model_height*rand_num(2)>aggregate_database(1)...
        &&model_length*(1-rand_num(3))>aggregate_database(1)&&model_length*rand_num(3)>aggregate_database(1);
       flag=1;
       aggregate_position=[model_width*rand_num(1) model_height*rand_num(2) model_length*rand_num(3) aggregate_database(1)];% 投放第一个骨料
    end
end

hwait=waitbar(0,'请等待>>>>>>>>');

%寻找剩余骨料的投放位置
for i=2:1:length(aggregate_database)
    flag=0; %用于判断是否寻找到
    endflag=0; %用于判断寻找多少次未果结束
    while flag<1
        k=0;
        endflag=endflag+1;
        rand_num=rand(3,1);
        aggregate_position_temp =[model_width*rand_num(1) model_height*rand_num(2) model_length*rand_num(3)];
        
        if model_width*(1-rand_num(1))>aggregate_database(i)&& model_width*rand_num(1)>aggregate_database(i)&&model_length*(1-rand_num(3))>aggregate_database(i)&&model_length*rand_num(3)>aggregate_database(i)...
           &&model_height*(1-rand_num(2))+3>aggregate_database(i)&&model_height*rand_num(2)>aggregate_database(i)
           % 当前骨料投放位置在model内
           for m=1:1:size(aggregate_position,1)
               temp(m)=sqrt(sum((aggregate_position_temp-aggregate_position(m,1:3)).^2));
               if temp(m)<aggregate_database(m)+aggregate_position(m,4)
                  % 当前骨料投放位置会与其他骨料重合，跳出循环重新选择当前骨料位置
                  break;
               end
               k=k+1; % 当前骨料位置符合要求，数量+1
           end
        end
        
        if k==size(aggregate_position,1)
            % 找到一个新的可投放骨料，进行保存
            aggregate_position=[aggregate_position;aggregate_position_temp aggregate_database(i)];
            flag=1;
        elseif endflag==10000
            break;
        else
            continue;
        end
        
    end  
    
   process_ratio=i/length(aggregate_database);
   str=['正在运行中',num2str(i),'/',num2str(length(aggregate_database))];
   waitbar(process_ratio,hwait,str);
end
close(hwait);

[x,y,z]=sphere(20);   
for m=1:1:size(aggregate_position,1)
    surf(aggregate_position(m,1)+aggregate_position(m,4)*x,aggregate_position(m,2)+aggregate_position(m,4)*y,aggregate_position(m,3)+aggregate_position(m,4)*z);
    hold on
    pause(0.22);
end