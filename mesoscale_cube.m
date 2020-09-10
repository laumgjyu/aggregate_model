clear
clc
model_width=50;% ������Ͷ�ſռ�Ŀ�
model_length=55;% ������Ͷ�ſռ�ĳ�
model_height=50;% ������Ͷ�ſռ�ĸ�
model_geometry=model_width * model_height * model_length;% ������Ͷ�ſռ�����������Ͷ�ŵĿռ���һ��������
aggregate_ratio=0.45;% ���ϵ����ռģ�ͼ���������ı���
model_geometry_for_aggregate=aggregate_ratio * model_geometry;
aggregate_diameter=[5 10 15 20];%�ֹ��������ֲ�
max_aggregate_diameter=max(aggregate_diameter);%�ֹ����������
aggregate_volu=100*sqrt(aggregate_diameter/max_aggregate_diameter);%��������ȷ���ֹ��������
aggregate_volu_ratio=diff(aggregate_volu)/sum(diff(aggregate_volu));%ȷ��5-10,10-15,15-20������������Χ�����

for j = 1:1:length(aggregate_volu_ratio);
    aggregate_sum_volu=0;% ��ǰ������Χ�����ɵĸ������������
    num=0;% ��ǰ������Χ�����ɵķ��������Ĺ��ϵ���Ŀ
    while aggregate_sum_volu < model_geometry_for_aggregate*aggregate_volu_ratio(j);%����5-10mm����
          num=num+1;
          r(j,num)=aggregate_diameter(j)/2+rand(1)*(aggregate_diameter(j+1)-aggregate_diameter(j))/2;% ���㵱ǰ������Χ�·��������ĵ�num�����ϵ�����뾶
          r_volu=4/3*pi*r(j,num)^3;
          aggregate_sum_volu=aggregate_sum_volu+r_volu;
    end
end

aggregate_database=r(:); %��r�����е���ƴ�ӳ�Ϊһ��������
aggregate_database=sort(aggregate_database,'descend');
aggregate_database(aggregate_database==0)=[];  %��aggregate_database��Ϊ0����ɾ�������ɹ���Ͷ�ſ⣬Ͷ�ſ�����Ϊ����Ҫ�������

% Ѱ�ҵ�һ�����ϵ�Ͷ��λ��
flag=0;
while flag<1
    rand_num=rand(3,1);
    if model_width*(1-rand_num(1))>aggregate_database(1)&& model_width*rand_num(1)>aggregate_database(1)&& model_height*(1-rand_num(2))+3>aggregate_database(1)&&model_height*rand_num(2)>aggregate_database(1)...
        &&model_length*(1-rand_num(3))>aggregate_database(1)&&model_length*rand_num(3)>aggregate_database(1);
       flag=1;
       aggregate_position=[model_width*rand_num(1) model_height*rand_num(2) model_length*rand_num(3) aggregate_database(1)];% Ͷ�ŵ�һ������
    end
end

hwait=waitbar(0,'��ȴ�>>>>>>>>');

%Ѱ��ʣ����ϵ�Ͷ��λ��
for i=2:1:length(aggregate_database)
    flag=0; %�����ж��Ƿ�Ѱ�ҵ�
    endflag=0; %�����ж�Ѱ�Ҷ��ٴ�δ������
    while flag<1
        k=0;
        endflag=endflag+1;
        rand_num=rand(3,1);
        aggregate_position_temp =[model_width*rand_num(1) model_height*rand_num(2) model_length*rand_num(3)];
        
        if model_width*(1-rand_num(1))>aggregate_database(i)&& model_width*rand_num(1)>aggregate_database(i)&&model_length*(1-rand_num(3))>aggregate_database(i)&&model_length*rand_num(3)>aggregate_database(i)...
           &&model_height*(1-rand_num(2))+3>aggregate_database(i)&&model_height*rand_num(2)>aggregate_database(i)
           % ��ǰ����Ͷ��λ����model��
           for m=1:1:size(aggregate_position,1)
               temp(m)=sqrt(sum((aggregate_position_temp-aggregate_position(m,1:3)).^2));
               if temp(m)<aggregate_database(m)+aggregate_position(m,4)
                  % ��ǰ����Ͷ��λ�û������������غϣ�����ѭ������ѡ��ǰ����λ��
                  break;
               end
               k=k+1; % ��ǰ����λ�÷���Ҫ������+1
           end
        end
        
        if k==size(aggregate_position,1)
            % �ҵ�һ���µĿ�Ͷ�Ź��ϣ����б���
            aggregate_position=[aggregate_position;aggregate_position_temp aggregate_database(i)];
            flag=1;
        elseif endflag==10000
            break;
        else
            continue;
        end
        
    end  
    
   process_ratio=i/length(aggregate_database);
   str=['����������',num2str(i),'/',num2str(length(aggregate_database))];
   waitbar(process_ratio,hwait,str);
end
close(hwait);

[x,y,z]=sphere(20);   
for m=1:1:size(aggregate_position,1)
    surf(aggregate_position(m,1)+aggregate_position(m,4)*x,aggregate_position(m,2)+aggregate_position(m,4)*y,aggregate_position(m,3)+aggregate_position(m,4)*z);
    hold on
    pause(0.22);
end