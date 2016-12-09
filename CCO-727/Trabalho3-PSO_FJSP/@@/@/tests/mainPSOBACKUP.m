n_iteracoes = 1000;
% maquinas identicas 
m = 8;
% número de jobs
n = 27;
% tempo de processamento de cada job, independente da máquina (não flexível)
tempo_jobs =       [5 3 5 3 3 0 10 9;%A    
                   10 0 5 8 3 9 9 6;   
                   0 10 0 5 6 2 4 5; 
                   5 7 3 9 8 0 9 0;   %B 
                   0 8 5 2 6 7 10 9;    
                   0 10 0 5 6 4 1 7;    
                   10 8 9 6 4 7 0 0;    
                   10 0 0 7 6 5 2 4; %C 
                   0 10 6 4 8 9 10 0;    
                   1 4 5 6 0 10 0 7;    
                   3 1 6 5 9 7 8 4; %D
                   12 11 7 8 10 5 6 9;
                   4 6 2 10 3 9 5 7;
                   3 6 7 8 9 0 10 0;
                   10 0 7 4 9 8 6 0;
                   0 9 8 7 4 2 7 0;
                   11 9 0 6 7 5 3 6;
                   6 7 1 4 6 9 0 10;
                   11 0 9 9 9 7 6 4;
                   10 5 9 10 11 0 10 0;
                   5 4 2 6 7 0 10 0;
                   0 9 0 9 11 9 10 5;
                   0 8 9 3 8 6 0 10;
                   2 8 5 9 0 4 0 10;
                   7 4 7 8 9 0 10 0;
                   9 9 0 8 5 6 7 1;
                   9 0 3 7 1 5 8 0;
                   ];
alternativa_produtos = [3 4 3 3 4 3 3 4];
[tempos, melhorSolucao] = PSO_func(tempo_jobs, m, n, 100, n_iteracoes, @fitness, alternativa_produtos);
tempoMelhorSolucao = fitness(melhorSolucao, tempo_jobs, m, n, alternativa_produtos);
%if  tempoMelhorSolucao == 154
%    disp('16x6m: ótimo global encontrado!');
%    disp(tempoMelhorSolucao);
%else
%    disp('16x6m: ótimo local!');
%    disp(tempoMelhorSolucao);
%end