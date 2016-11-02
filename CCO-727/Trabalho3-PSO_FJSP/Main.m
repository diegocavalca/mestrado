% Importando dados do benchmark
Tij = importdata('benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('benchmarks/op8x8.txt'); % Operacoes por job

% Variaveis do problema
[n,m] = size(Tij);

% Configuracoes PSO
swarmSize = 15; % tamanho da nuvem...
nIter = 10; % Iteracoes do algoritmo...
c1 = 1.4944;
c2 = 1.4944;
w = 0.9;

% Nuvem (populacao) e solucao inicial
X = ones(swarmSize, n);
f = V;


% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    % Maquinas factives para Oij
    fMach = find(Tij(i,:));
    % Atribuir maquinas para cada Oij (aleatorio)
    X(:,i) = fMach(randi(numel(fMach), swarmSize, 1));
end;

% Variaveis objetivo
pBest = zeros(swarmSize, n);
pBestCost = Inf(1, swarmSize);
gBest = zeros(1, n);
gBestCost = Inf;

% AVALIACAO INICIAL dos individuos (roteamentos)
for i=1:swarmSize;
  
  % Inidividuo (Roteamento)
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

% PASSO 3
for iter=1:nIter;

  % Atualizar particulas...
  for i=1:swarmSize;
  
    r1 = rand(particulas, 1);
    r2 = rand(particulas, 1);
    %v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + ...
    %  c2 * bsxfun(@times, r2, (bsxfun(@minus, melhores_globais, x)));
    v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + c2 * bsxfun(@times, r2, aux_melhores - x);
  
  end;
  
  
end;


% SEQUENCIAMENTO - (inicial) operacoes das maquinas pra cada solucao (linha de X)...
%M = Scheduler(X(1,:), m);

% Avaliacao da solucao inicial
%[makespan, schedule, scheduleOpsLabels] = Fitness(M, Tij, Oij, m, n);


%Gantt(schedule, scheduleOpsLabels, makespan, m);


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
