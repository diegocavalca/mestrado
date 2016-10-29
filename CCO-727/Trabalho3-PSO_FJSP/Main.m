% Importando dados do benchmark
Tij = importdata('benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('benchmarks/op8x8.txt'); % Operacoes por job

% Variaveis do problema
[n,m] = size(Tij);

% Configuracoes PSO
swarmSize = 15; % tamanho da nuvem...
nIter = 10; % Iteracoes do algoritmo...

% Nuvem (populacao) e solucao inicial
X = ones(swarmSize, n);

% ROTEAMENTO - Define as operacoes para quais maquinas (respeitando)
for i=1:n;
    % Maquinas factives para Oij
    fMach = find(Tij(i,:));
    % Atribuir maquinas para cada Oij (aleatorio)
    X(:,i) = fMach(randi(numel(fMach), swarmSize, 1));
end;

% SEQUENCIAMENTO - operacoes das maquinas pra cada solucao (linha de X)...
M = cell(1, m);
for mach=1:m;
    % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
    fOper = find( X(1,:) == mach );
    M{1,mach} = fOper;
end;    

% Avaliacao da solução inicial
[solucao, gantt, gantt_op] = Fitness(M, Tij, Oij, m, n);

% PSO
%[tempos, melhorSolucao] = PSO(Tij, m, n, swarmSize, nIter, Oij);

% Melhor solucao encontrada pelo PSO
%[solucao, gantt, gantt_op] = Fitness(melhorSolucao, Tij, Oij, m, n);

Gantt;
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
