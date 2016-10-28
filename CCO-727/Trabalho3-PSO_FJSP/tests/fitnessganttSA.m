function [solucao,gantt,gantt_op] = fitnessganttSA(tempo_jobs, m, alternativa_produtos, k)
  %roteiro = [2 5 6     3 4 7 5     7 4 1   2 6 3   1 7 6 7      3 8 2      3 8 4   1 2 8 3];
  
  %cria um vetor para as os tempos das máquinas e tempos dos jobs, a cada
  %nova atualização de tempo é tomado como base para acréscimo o tempo que
  %for maior, ou o da máquina ou o do job
  solucoes = zeros(1, m);
  solucoes_job = cell(1, length(alternativa_produtos));
  
  %inicializa o vetor de tempos dos jobs com 0's
  for i=1:length(alternativa_produtos)
    solucoes_job{i} = zeros(1,cumsum(alternativa_produtos(i)));
  end
  
  %inicializa os estágios das máquinas e dos jobs, estágios são cruciais
  %para o controle da precedência das operações.
  stage = ones(1,length(alternativa_produtos));
  %maior_estagio = max(cellfun(@(x) length(x(:)),k));
  stage_m = ones(1,m);
  iterator = 0;
  gantt = zeros(m,max(cumsum(alternativa_produtos(1:length(alternativa_produtos)))));
  gantt_op = cell(m,max(cumsum(alternativa_produtos(1:length(alternativa_produtos)))));
    %enquanto nao for percorrido todos os estágios dos jobs e não houver
    %deadlock (iterator somar 8 quer dizer que ele passou por todas as máquinas mas nenhuma fez um job)
    while sum(stage) < sum(alternativa_produtos+1) && iterator < m
      iterator = 0;
      for i = 1:m
          if stage_m(i) <= length(k{i})
              index = k{i}(stage_m(i));
              %coloca em uma variavel auxiliar a resposta logica se o índice 'index'
              %é menor ou igual os valores que estao dentro das alterativas das operações somadas
              %ex: 1 <= 2? resp 1 ; 1 <= 4? resp 1 -> aux = [1 1] 
              aux = index <= cumsum(alternativa_produtos);
              %achar o indice do primeiro true (1), para saber que operação
              %está em andamento
              job = find(aux==1,1,'first');
              if job > 1
                operacao = index - max(cumsum(alternativa_produtos(1:job-1)));
              else
                operacao = index;
              end

              if stage(job) == operacao
                if isempty(find(gantt(i,:),1,'last')) 
                    ultimo_indice = 1;
                else
                    ultimo_indice = find(gantt(i,:),1,'last')+1;
                end
                operacao_base = ultimo_indice;
                %acrescenta tempo de processamento atual ao vetor das máquinas a partir do maior
                %corrente, ou o vetor de máquinas ou de jobs
                gantt(i,operacao_base) = max([solucoes(i) max(solucoes_job{job})]);
                solucoes(i) = max([solucoes(i) max(solucoes_job{job})]) + tempo_jobs(index,i);
                %acrescenta tempo de processamento da máquina à operação atual do job e todas as posteriores
                
                solucoes_job{job}(operacao:cumsum(alternativa_produtos(job))) = solucoes(i);
                gantt(i,operacao_base + 1) = solucoes(i);
                
                gantt_op{i,stage_m(i)} = ['J' num2str(job) ',' num2str(operacao)]; 
                
             
                stage(job) = stage(job)+1;
                stage_m(i) = stage_m(i)+1;
              else
                iterator = iterator + 1;
              end
          else
              iterator = iterator + 1;
          end
          
      end
    end
    %se houve deadlock retorna 0 senao o makespan
    if sum(stage) < sum(alternativa_produtos+1)
    solucao = 0;
    else
    solucao = max(solucoes);
    end
 
end
