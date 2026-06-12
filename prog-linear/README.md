# Modelos de Programação Linear e Inteira com CPLEX

Esta pasta contém os modelos da Questão 2 do trabalho de Pesquisa Operacional. Cada problema foi separado em uma pasta própria para facilitar a execução e a conferência dos resultados.

Em cada pasta, a organização básica é:

- arquivo `.mod`: modelo em OPL;
- arquivo `.dat`: dados da instância;
- arquivo `.ops`: configurações do CPLEX;
- `resultado.txt`: saída obtida na execução.

Os modelos contínuos foram registrados com o valor objetivo e, quando o próprio resultado indicava que best bound, gap e nós explorados não se aplicavam, esses campos foram deixados como `N/A`. Nos modelos inteiros e binários, o log do CPLEX foi usado para registrar tempo, gap, melhor solução inteira e best bound quando esses dados apareceram.

Nos arquivos de resultado, alguns modelos mostram `Status CPLEX: 1`. Esse status foi interpretado como solução ótima porque o próprio CPLEX indicou solução ótima nos logs ou a execução retornou o resultado final ótimo do modelo.

## Como abrir e executar

1. Abrir o IBM ILOG CPLEX Optimization Studio.
2. Importar ou abrir a pasta do problema desejado dentro de `prog-linear/`.
3. Conferir se o `.mod`, o `.dat` e o `.ops` estão associados ao projeto.
4. Executar o modelo pelo CPLEX Studio.
5. Comparar a saída obtida com o arquivo `resultado.txt` salvo na pasta.

## Tabela de resultados

| Pasta | Problema | Tipo | Status | Objetivo/Resultado | Tempo | Gap |
| --- | --- | --- | --- | ---: | ---: | ---: |
| `01_racao` | Ração | PL contínua | Optimal | 74444.444444444 | N/A | N/A |
| `02_dieta` | Dieta | PL contínua | Optimal | 179 | N/A | N/A |
| `03_plantio` | Plantio | PL contínua | Optimal | 4361904.761904762 | N/A | N/A |
| `04_tintas` | Tintas | PL contínua | Optimal | 1458.333333333 | N/A | N/A |
| `05_transporte` | Transporte | PL contínua | Optimal | 1920 | N/A | N/A |
| `06_fluxo_maximo` | Fluxo máximo | PL contínua/rede | Optimal | 9 | N/A | N/A |
| `07_escalonamento` | Escalonamento | PLI | Optimal | 17 | 0,03 sec | 0% |
| `08_cobertura` | Cobertura | Binário | Optimal | 2 | 0,00 sec | 0% |
| `09_mochila` | Mochila | Binário | Optimal | 95 | 0,02 sec | 0% |
| `10_padroes` | Padrões | PLI | Optimal | 9240 | 0,03 sec | 0% |
| `11_facilidades` | Facilidades | Binário | Optimal | 96 | 0,00 sec | 0% |
| `12_frequencias` | Frequência | Binário/grafos | Optimal | 3 | 0,02 sec | 0% |
| `13_clique_maxima` | Clique máxima | Binário/grafos | Optimal | 4 | 0,00 sec | 0% |

## Observações

- Os valores da tabela foram conferidos a partir dos arquivos `resultado.txt` de cada pasta.
- Para os modelos contínuos, gap, best bound e nós explorados foram marcados como `N/A`, pois não eram métricas relevantes para esses casos.
- Para os modelos inteiros/binários, o tempo e o gap vieram dos trechos de log do CPLEX presentes nos resultados.
