function [solucao, gantt, gantt_op] = Fitness (M, Times, Oij, m, n)

  % Auxiliares...
  %m = length(Oij);
  %Mj = zeros(1,8);
  %Mm = zeros(1,8);
  
  % Totalizando Operacoes para todos os Jobs
  opsJobs = cumsum(Oij);
  
  %cria um vetor para as os tempos das máquinas e tempos dos jobs, a cada
  %nova atualização de tempo é tomado como base para acréscimo o tempo que
  %for maior, ou o da máquina ou o do job
  solucoes = zeros(1, m);
  solucoes_job = cell(1, m);
  
  %inicializa o vetor de tempos dos jobs com 0's
  for i=1:m;
    solucoes_job{i} = zeros(1, max(opsJobs));
  end;
  
  % Controles de operacoes (O) e maquinas (M) para alocacao da producao
  stageO = ones(1, m);
  stageM = ones(1, m);
  iterator = 0;
  gantt = zeros(m, max(opsJobs));
  gantt_op = cell(m, max(opsJobs));
    
%enquanto nao for percorrido todos os estágios dos jobs e não houver
%deadlock (iterator somar 8 quer dizer que ele passou por todas as máquinas mas nenhuma fez um job)
while sum(stageO) < sum(Oij) && iterator < m;
    
  iterator = 0;
    
  % Avaliar maquinas...
  for mach=1:m;

    % Operacoes atribuidas para a maquina 'mach' (Roteamento)
    ops = M{mach};

    % Verificar se a maquina recebe mais operacoes
    if stageM(mach) <= length(ops);


        %stageO = ones(1, m); 

        %for c=1:length(ops);

          % Indice da operacao da maquina
          %opIdx = ops(c);           
          opIdx = ops(stageM(mach));

          % Tempo da operacao na maquina...
          time = Times(opIdx, mach);

          % Selecionar job
          job = find(opsJobs >= opIdx, 1, 'first'); 

          % Selecionar operacao - de acordo com os jobs e seus indices
          % (disponivel em opsJobs, caso job > 1)
          if(job>1)
            op = opIdx - opsJobs(job-1); 
          else
            op = opIdx;        
          end;

          % Verificar se Oij eh factivel para Mi...
          if op==stageO(job);

            % ...
            if isempty(find(gantt(mach,:),1,'last')) 
                ultimo_indice = 1;
            else
                ultimo_indice = find(gantt(mach,:),1,'last')+1;
            end;
            operacao_base = ultimo_indice;
            %acrescenta tempo de processamento atual ao vetor das máquinas a partir do maior
            %corrente, ou o vetor de máquinas ou de jobs
            gantt(mach,operacao_base) = max([solucoes(mach) max(solucoes_job{job})]);
            solucoes(mach) = max([solucoes(mach) max(solucoes_job{job})]) + time;
            %acrescenta tempo de processamento da máquina à operação atual do job e todas as posteriores

            solucoes_job{job}(op:cumsum(Oij(job))) = solucoes(mach);
            gantt(mach,operacao_base + 1) = solucoes(mach);

            gantt_op{mach,stageM(mach)} = ['J' num2str(job) ',' num2str(op)]; 
            % ...

            stageO(job) = stageO(job) + 1;
            stageM(mach) = stageM(mach)+1;
          else
            iterator = iterator + 1;
          end;

          %fprintf('Op(%d,%d) - M(%d): %d \n', round(job), round(op), round(mach), round(time));

        %end;

    else
      iterator = iterator + 1;
    end;

   end;

    % Se houve deadlock retorna 0 senao o makespan
    if sum(stageO) < sum(Oij)+1
        solucao = 0;
    else
        solucao = max(solucoes);
    end;
  
%%  schedule = zeros(length(M), 2*length(X));
%%  disp(schedule);
  
%%  % Avaliar operacoes...
%%  opIdx = 1;
%%  for job=1:length(Oij);
%%      for op=1:Oij(job);
%%        
%%        % Maquina atribuida p/ operacao...
%%        machine = X(opIdx);
%%        
%%        % Tempo...
%%        time = Times(opIdx, machine);
%%        fprintf('Op(%d,%d) - M(%d): %d \n', round(job), round(op), round(machine), round(time));
%%        
%%        schedule(machine, opIdx+1) =  schedule(machine, opIdx) + time;
%%        
%%        opIdx = opIdx + 1;
%%        
%%      end;            
%%  end;
%%  
%%  disp(schedule);

%%  for op=1:length(X);
%%    
%%    % Maquina para a operacao...    
%%    machine = X(op);
%%    % Custo para a operacao na maquina...
%%    time = Times(op, machine);
%%    disp(time);
%%    
%%  end;
  
  
  %valor = 0;
  
end
