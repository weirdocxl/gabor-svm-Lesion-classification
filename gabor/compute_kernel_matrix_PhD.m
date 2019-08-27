function kermat = compute_kernel_matrix_PhD(X,Y,kernel_type,kernel_args);
kermat = [];
if nargin <3
    disp('Wrong number of input parameters! The function requires at least three input arguments.')
    return;
elseif nargin >4
    disp('Wrong number of input parameters! The function takes no more than four input arguments.')
    return;
elseif nargin==3
    if ischar(kernel_type)~=1
        disp('The parameter "kernel_type" needs to be a STRING - a valid one!')
        return;
    end
    if strcmp(kernel_type,'poly')==1
        kernel_args = [0 2];
    elseif strcmp(kernel_type,'fpp')==1
        kernel_args = [0 .8];
    elseif strcmp(kernel_type,'tanh')==1
        kernel_args = 0;
    else
        disp('The entered kernel type was not recognized as a supported kernel type.')
        return;
    end
end
[a,b]=size(kernel_args);
if strcmp(kernel_type,'poly')==1
    if a==1 && b==2
        %ok
    elseif a==2 && b==1
        %ok
    else
        disp('The polynomial kernel requires the two arguments arranged into a 1x2 matrix. Switching to default values: kernel_args = [0 2].');
        kernel_args = [0 2];
    end
elseif strcmp(kernel_type,'fpp')==1
    if a==1 && b==2
        %ok
    elseif a==2 && b==1
        %ok
    else
       disp('The fractional power polynomial kernel requires the two arguments arranged into a 1x2 matrix. Switching to default values: kernel_args = [0 0.8].');
       kernel_args = [0 .8];
    end
elseif strcmp(kernel_type,'tanh')==1
    if a==1 && b==1
            %ok
    else
        disp('The sigmoidal kernel requires its argument to be a single numerical value. Switching to default: kernel_args = [0].');
        kernel_args = 0;
    end
else
    disp('The entered kernel name was not recognized as a supported kernel type.')
    return;
end

%% Compute kernel matrices
if strcmp(kernel_type,'poly')==1
    kermat = (X'*Y + kernel_args(1)).^(kernel_args(2));
elseif strcmp(kernel_type,'fpp')==1
    kermat = sign(X'*Y+kernel_args(1)).*((abs(X'*Y+kernel_args(1))).^(kernel_args(2)));
elseif strcmp(kernel_type,'tanh')==1
    kermat = tanh(X'*Y+kernel_args(1));
end
    

















