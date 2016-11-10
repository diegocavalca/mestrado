function [ M, makespan, R ] = SA( S, Scheduler, Fitness, Neighbor )

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
    [costS, ~, ~] = Fitness(S, Tij, Oij, m, n);
    
    iterations = 0;
    tK = t0;
    while tK > tEnd
        for i=1:10 % Exec maxima por temp
            
            %1. Gerar nova solucao S_
            S_ = Neighbor(S, m);
            [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);

            %se der deadlock, for�a uma nova sequencia��o
            while costS_ == 0 %|| costS_ >= costS
                S_ = Neighbor(S, m);
                [costS_, ~, ~] = Fitness(S_, Tij, Oij, m, n);          
            end;   
            
            %3. Avaliar S_
            deltaF_ = costS_ - costS;
            if (deltaF_ < 0) || (exp(-deltaF_/tK) > rand(1));
                % Atualizar S
                S = S_;
                costS = costS_;
                
            end;
            %disp(S{1});
            iterations = iterations + 1;
        end;
        
        tK = B * tK;
        %disp(costS);
        
    end;  
    
    %disp(iterations);
    
    % Retornos
    M = S;
    makespan = costS;
    %disp(makespan);
    
    % Processar roteamento resultante a partir do sequenciamento S
    R = zeros(1, n);
    for i=1:size(M,2);
        for j=1:size(M{i},2);
            R(M{i}(j)) = i;
        end;
    end;

end

