% Instante 0
load 'distances.mat';
%% Inicializacao
% Nuvem...
rows = 51;
swarmSize = 50;
X(1,:) = 1:rows;
for i=2:swarmSize;
   X(i,:) = randperm(rows,rows);
end;



% Avaliar particulas...
figure;
for i=1:50;
    cost = Fitness(X(i,:), distances);
    hold on;
    plot(cost,cost,'*');
end;