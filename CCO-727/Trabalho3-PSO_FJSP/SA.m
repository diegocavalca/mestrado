function [ M, makespan, R, O ] = SA( S, Scheduler, Fitness, Neighbor )

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
    S = Scheduler(S, m); 
    M = S;
    [makespan, ~, ~] = Fitness(M, Tij, Oij, m, n);
    
    iterations = 0;
    tK = t0;
    while tK > tEnd
        for i=1:10 % Exec maxima por temp
            
            % Reavaliando S
            [costS, ~, ~] = Fitness(S, Tij, Oij, m, n);
            
            %1. Gerar nova solucao S_
            S_ = Neighbor(S, m);
            [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);

            % Se der deadlock, gere uma nova solucao S_
            while costS_ == 0 %|| costS_ >= costS
                S_ = Neighbor(S, m);
                [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);          
            end;   
            
            %fprintf('tK=%.2f, i=%.0f, costS=%.0f, costS_=%.0f, makespan=%.0f\n', tK,i,costS, costS_, makespan);
            
            %3. Avaliar S_
            deltaF_ = costS_ - costS;
            
            if min([1 exp(-deltaF_/tK)]) > rand(1);
                S = S_;
            end;
            if costS_ < makespan;
                makespan = costS_;
                M = S_;
            end;

%             if deltaF_ <= 0;
%                 % Atualizar S
%                 S = S_;
%                 if costS_ < makespan;
%                     makespan = costS_;
%                     M = S_;
%                 end;
%             else
%                 if exp(-deltaF_/tK) > rand(1);
%                     % Atualizar S
%                     S = S_;
%                     %costS = costS_;  
%                 end;
%             end;
            %disp(S{1});
            iterations = iterations + 1;
        end;
        
        tK = B * tK;
        %disp(costS);
        
    end;  
    
    %disp(iterations);
    
    % Retornos
    %M = S;
    %makespan = costS;
    %disp(makespan);
    
    % Processar roteamento R resultante a partir do sequenciamento S
    % e order de processamento individual O
    R = zeros(1, n);
    O = R;
    for i=1:size(M,2);
        for j=1:size(M{i}, 2);
            R(M{i}(j)) = i;
            O(M{i}(j)) = j;
        end;
    end;
    
    %disp(O);
    
    % [mBest, costBest, rBest] = SA(gBestX,@Scheduler,@Fitness,@Neighbor);

end

