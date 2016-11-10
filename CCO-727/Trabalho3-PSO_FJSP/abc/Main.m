% Importando dados do benchmark
global Tij;
global Oij;
Tij = importdata('../benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('../benchmarks/op8x8.txt'); % Operacoes por job

% Variaveis do problema
global n;
global m;
[n,m] = size(Tij);


global nIter;
nIter = 5;

global swarmSize;
swarmSize = 100;

global W;

global wMax;
wMax = 1.2;

global wMin;
wMin = 0.4;

global c1;
c1 = 2;

global c2;
c2 = c1;

global t0;
t0 = 3;

global tEnd;
tEnd = 0.01;

global B;
B = 0.9;

V = zeros(swarmSize, n);
vMin = 1;
vMax = m;

% Nuvem (populacao) e solucao inicial
X = ones(swarmSize, n);
P = X;
%f = V;

% ORGANIZANDO MAQUINAS - Melhores tempos tem prioridade 1, maior tem
% prioridade M, sendo M > 0, senao a maquina M nao eh factivel para Oij
global Mij;
Mij = MachinesPrior(Tij);

% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    
%     % Maquinas factiveis na ordem de melhor >> pior, 
%     %selecionadas de modo estocastico (detalhes na funcao
%     [machines, ~] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij);
%     probs = ones(1, length(machines))*1/length(machines);
%     
%     % Maquinas factiveis resultantes
%     machines = randsample(machines, swarmSize, true, probs);
%     % Indices de prioridade das maquinas factives
%     [~, priorities] = ismember(machines, Mij(i, :));
    % Maquinas factiveis na ordem de melhor >> pior, 
    [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, 1);

    X(:, i) = machines;
    P(:, i) = priorities;
    
end;

% Variaveis objetivo
pBest = zeros(swarmSize, n);
pBestCost = Inf(1, swarmSize);
gBest = zeros(1, n);
gBestCost = Inf;

% AVALIACAO INICIAL dos individuos (roteamentos)
for i=1:swarmSize;
   
% %     % Simulated Annealing (Avaliacao da particula)
% %     [M, makespan, X(i, :)] = SA(X(i, :), @Scheduler, @Fitness, @gerar_vizinho);
% % 
% %     % FITNESS
% %     pBestCost(i) = makespan;
% %     pBest(i, :) = X(i, :);
  
  % Individuo (Roteamento)
  R = X(i, :);
  
  % SEQUENCIAMENTO a partir do roteamento R
  M = Scheduler(R, m); 
  
  % FITNESS
  [makespan, schedule, scheduleOpsLabels] = Fitness(M, Tij, Oij, m, n);
  pBestCost(i) = makespan;
  pBest(i, :) = R;

end;

% Melhor global (inicial)
[gBestCost, idx] = min(pBestCost);
gBest = pBest(idx, :);

    cPr = 0.2;
    w = 0.9; % Fator de inercia 
    alpha = 0.8; % Fator individual - c1
    beta = alpha; % Fator social - c2
    
% PASSO 3
%nIter = 5;
for iter=1:nIter;
  
  %status = round(iter*100/(nIter*swarmSize))/2;
  fprintf('Completed: %d/%d (gBest: %d)...\n', iter, nIter, gBestCost);
  
  % Nova nuvem...
  W = wMax - ( (wMax - wMin)/nIter ) * iter;

  % Avaliar particulas
  for i=1:swarmSize;
      
    % Movimento da nuvem... 
    [X(i,:), xCost] = LocalSearch(X(i,:), W); % M1
    [X(i,:), xCost, gBest, gBestCost] = PathRelinking (X(i,:), xCost, gBest, gBestScore, beta, cPr); %gBest - M3
    [X(i,:), xCost, pBest(i,:), pBestCost(i)] = PathRelinking (X(i,:), xCost, pBest(i,:), pBestCost(i), alpha, cPr); %pBest - M2  

    % Simulated Annealing (Avaliacao da particula)
    %[M, makespan, X(i, :)] = SA(X(i, :), @Scheduler, @Fitness, @gerar_vizinho);
    
    makespan = Fitness(Scheduler(X(i,:), m), Tij, Oij, m, n);

    % FITNESS
    pBestCost(i) = makespan;
    pBest(i, :) = X(i, :);
    
    if(makespan < pBestCost(i));
        pBestCost(i) = makespan;
        pBest(i, :) = X(i, :);
    end;
    if(makespan < gBestCost);
        gBestCost = makespan;
        gBest = X(i, :);
    end;
      
%       % FITNESS
%       R = X(i, :);
%       M = Scheduler(R, m); 
%         
%         %         % PairExchange
%         %         for p=1:size(M,2);
%         %             N{p} = fliplr(M{p});
%         %         end;
%         %         [makespan, ~, ~] = Fitness(N, Tij, Oij, m, n);
%         %         if(makespan==0); [makespan, ~, ~] = Fitness(M, Tij, Oij, m, n); end;
%         
%       if(makespan < pBestCost(i));
%           pBestCost(i) = makespan;
%           pBest(i, :) = R;
%       end;
%       if(makespan < gBestCost);
%           gBestCost = makespan;
%           gBest = R;
%       end;
      
  end;
  
%   
%   % Atualizar particulas...
%   for i=2:swarmSize;
%   
%     % Fator de inercia
%     w = wMax - ( (wMax - wMin)/nIter ) * iter;
%     r1 = rand(swarmSize, 1);
%     r2 = rand(swarmSize, 1);
%     %v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + ...
%     %  c2 * bsxfun(@times, r2, (bsxfun(@minus, melhores_globais, x)));
%     x = ParticlePosition(X(i,:), Mij);
%     
%     % Velocidade
%     v = w*v + c1*r1*(pBest(i,:) - x) + c2*r2*(gBest - x);
%     
%     % Posicao
%     x_aux = round(x + v);
%     x_aux(x_aux < vMin) = vMin;
%     x_aux(x_aux > vMax) = vMax;
%     
%     % Avaliacao...  
%     M = Scheduler(x_aux, m); % SEQUENCIAMENTO a partir do roteamento R
%     [makespan, ~, ~] = Fitness(M, Tij, Oij, m, n);
%     if(pBestCost(i)>makespan)
%         pBestCost(i)=makespan;
%         pBest(i,:)=x_aux;
%     end
%     if(gBestCost>makespan)
%         gBestCost=makespan;
%         gBest=x_aux;
%     end;
% 
%   end;
  %clc;
end;

% SEQUENCIAMENTO - (inicial) operacoes das maquinas pra cada solucao (linha de X)...
%M = Scheduler(X(1,:), m);
% Avaliacao da solucao inicial
%[makespan, schedule, scheduleOpsLabels] = Fitness(M, Tij, Oij, m, n);
%Gantt(schedule, scheduleOpsLabels, makespan, m);

% Plotando gBest
[makespan, schedule, scheduleOpsLabels] = Fitness(Scheduler(gBest, m), Tij, Oij, m, n);
Gantt(schedule, scheduleOpsLabels, makespan, m);

%M = cell(swarmSize, m);
%for i=1:swarmSize;
%    for mach=1:m;
%        % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
%        fOper = find( X(i,:) == mach );
%        M{i,mach} = fOper;
%    end;    
%end;

% FITNESS - 


% Aplicar busca local para definir programacao (sequencia de operacoes na
% maquina)

% Calcular aptidao sobre a programacao resultante
