classdef Plane_model
    %UNTITLED4 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        scalar;
        approxmodel;
    end
    
    methods
        function obj = Plane_model(SP)
            Nu = length(SP);
            Nl = length(SP{1});
            [~,l_M] = size(SP{1}.lobjs);
            D = size(SP{1}.udecs,2);
            
            P =[];
            FNo = zeros(Nu,Nl);
            for i = 1:Nu
                [FNo(i,:),~] = NDSort(SP{i}.lobjs,1);
                P = [P,SP{i}(FNo(i,:)==1)];
            end
            %P = cat(2,SP{:});
            %P = P(P.adds == 1);
            exponent = max(floor(real(log10(P.lobjs))));
            scalar = 10.^exponent;
            
            approxmodel = cell(1,l_M);            
            
            X = zeros(Nu,D);
            Y = zeros(Nu,l_M);
            
            for i = 1 : Nu    %��С���˷����ƽ�淽��        
               X(i,:) = SP{i}(1).udec;
               lobjs = SP{i}(FNo(i,:)==1).lobjs;
%                [~,I] = min(lobjs);
               lobjs = lobjs./scalar;
               A = [lobjs(:,1:l_M-1),ones(size(lobjs,1),1)];
               b = lobjs(:,end);
               parameters = pinv(A'*A)*A'*b;
               Y(i,:) = (parameters(end)./[-parameters(1:l_M-1);1])';          
            end
            [X,I,~] = unique(X,'rows');
            Y = Y(I,:);
                
            THETA   = 5.*ones(1,size(X,2));
            for i = 1:l_M              
                 approxmodel{i} = dacefit(X,Y(:,i),...
                    'regpoly0','corrgauss',...
                    squeeze(THETA),...
                    1e-5.*ones(1,D),...
                    100.*ones(1,D));                
            end           
            
            obj.scalar = scalar;
            obj.approxmodel = approxmodel;
        end
        
        function cv = LL_discriminator(obj,P) 
            % the degree of constraint violation
            %   �˴���ʾ��ϸ˵��
            
            xu = P.udecs;
            lobjs = P.lobjs./obj.scalar;
            %Ԥ�ⳬƽ��ؾ�
            l_M = length(obj.approxmodel);
            intercept = zeros(size(xu,1),l_M);
            MSE = intercept;
            
            
            for i = 1:l_M 
                [intercept(:,i),~,MSE(:,i)] = predictor(xu,obj.approxmodel{i});
            end
            intercept = intercept + 3*sqrt(MSE);
            
            %���㳬ƽ�淽��z=ax+by+c ����
            c = intercept(:,end);
            ab= -c./intercept(:,1:l_M-1);
            
            %����Լ��Υ���̶�
            cv = lobjs(:,end)-(sum(lobjs(:,1:l_M-1).*ab,2)+c);
            
        end
        
    end
end

