function [ S, makespan, R ] = SA( X, Scheduler, Fitness )

    % S = Sequenciamento solucao

    % Variaveis 
    global Tij;
    global Oij;
    global n;
    global m;
    global t0;
    global tEnd;
    global B;

    % SOLUCAO - SEQUENCIAMENTO a partir do roteamento X
    S = Scheduler(X, m); 
    [costS, ~, ~] = Fitness(S, Tij, Oij, m, n);
    makespan = costS;
    
    tK = t0;
    while tK > tEnd
        
        %1. Gerar nova solucao S
        validate = false;
        while validate == false;
            
            S_ = S;
            randM = randi(length(S)); % maquina aleatoria
            if( length(S_{randM})> 1);
                
                % Inverter par de operacao aleatorio
                idxChange = round(2+rand(1,1)*(length(S_{randM})-2));
                S_{randM}([idxChange-1 idxChange]) = S{randM}([idxChange idxChange-1]);

                %2. Calcular Fitness da nova solucao S_
                [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);            
                if costS_ > 0;
                    validate = true;
                end;
            end;
        end;
%         % PairExchange
%         for i=1:size(S,2);
%             S_{i} = fliplr(S{i});
%             if size(S{i},2)> 1;
%                 for j=2:size(S{i},2);
%                     S_{i}([j j-1]) = S{i}([j j-1]);
%                 end;
%             end;
%             %S_{i} = fliplr(S{i});
%             %if length(S{i})> 1;
%                 %S_{i}([1 2]) = S{i}([2 1]);
%             %end;
%         end;
        
%         %2. Calcular Fitness da nova solucao S_
%         [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);
        
        %3. Avaliar S{
        deltaF_ = costS_ - costS;
        if (deltaF_ <= 0) || (exp(-deltaF_/tK) > rand(1));
            % Atualizar X
            S = S_;
            makespan = costS_;
        end;
        
        tK = B * tK-1;
    end;  
    
    % Processar roteamento resultante a partir do sequenciamento S
    R = zeros(1, n);
    for i=1:size(S,2);
        for j=1:size(S{i},2);
            R(S{i}(j)) = i;
        end;
    end;

end

