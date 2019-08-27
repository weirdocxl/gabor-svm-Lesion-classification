
function filtered_image = filter_image_with_Gabor_bank1(image,filter_bank,down_sampling_factor);
%N层小波变换并且提取小波系数
filtered_image = [];
    %检查图像和滤波器尺寸
    [a,b]=size(image);
    [c,d]=size(filter_bank.spatial{1,1});  %96*96
    if a==2*c && d==2*b
        disp('The dimension of the input image and Gabor filters do not match! Damn! Terminating!')
        return;
    end  
%%计算输出尺寸
[a,b]=size(image);%48*48
dim_spec_down_sampl = round(sqrt(down_sampling_factor));%sqrt(64)=8
new_size = [floor(a/dim_spec_down_sampl) floor(b/dim_spec_down_sampl)];%6*6
%%对图像在频域进行滤波
image_tmp = zeros(2*a,2*b);
image_tmp(1:a,1:b)=image;
image = fft2(image_tmp);
figure
for i=1:filter_bank.scales
    for j=1:filter_bank.orient
      %滤波
        Imgabout = ifft2((filter_bank.freq{i,j}.*image));
        
        gabout = abs(Imgabout(a+1:2*a,b+1:2*b));  
        aaaa=reshape(1:1:40,8,5)';
        
        subplot(5,8,aaaa(i,j));
        
        imshow((gabout))
       
        y1=imresize(gabout,new_size,'bilinear');  
        
        y2=(y1(:)-mean(y1(:)))/std(y1(:)); 
        y3=y2(:);
        
        filtered_image=[filtered_image;y3];     
        
    end
    
end














