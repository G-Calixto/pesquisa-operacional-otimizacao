# Bin Packing ILS

Este projeto implementa um algoritmo heurístico para o problema de **Bin Packing** usando **Iterated Local Search (ILS)**.

A ideia do problema é simples: dado um conjunto de itens com pesos e bins com capacidade fixa, o objetivo é distribuir todos os itens usando o menor número possível de bins.

## Como compilar

No Windows com `g++`, rode no terminal dentro da pasta do projeto:

```bash
g++ -std=c++17 -O2 -Wall -Wextra -pedantic binpacking_ils.cpp -o binpacking_ils.exe
```

Se quiser usar `clang++`, o comando é equivalente:

```bash
clang++ -std=c++17 -O2 -Wall -Wextra -pedantic binpacking_ils.cpp -o binpacking_ils.exe
```

## Como executar

O programa espera este formato:

```bash
./binpacking_ils.exe <arquivo_instancia.txt> <tempo_limite_segundos> [semente]
```

Exemplo:

```bash
./binpacking_ils.exe input.txt 5 123
```

Se a semente não for informada, o programa usa um valor aleatório baseado no relógio do sistema.

## Formato da entrada

O arquivo da instância deve ter:

1. `n` = número de itens
2. `capacidade` = capacidade de cada bin
3. `n` pesos, um para cada item

Exemplo:

```txt
11 1.0
0.2 0.5 0.4 0.7 0.1 0.3 0.8 0.6 0.9 0.4 0.3
```

## Como o algoritmo funciona

O fluxo geral é este:

1. Lê a instância e valida os dados.
2. Gera uma solução inicial com **First Fit Decreasing**.
3. Aplica uma busca local para tentar melhorar a solução.
4. Faz uma perturbação na melhor solução encontrada.
5. Repete o ciclo até acabar o tempo limite.
6. Imprime a solução final.

## Funções importantes


### `firstFitDecreasing`
Cria a solução inicial.

O algoritmo:

- ordena os itens do maior para o menor;
- tenta colocar cada item no primeiro bin que tiver espaço;
- se nenhum bin comportar, abre um novo bin.

Essa etapa dá uma solução inicial rápida e razoável.

### `evaluate`
Calcula a qualidade da solução.

A métrica principal é:

- menos bins é melhor;
- em caso de empate, bins mais cheios são preferidos.

### `shiftFirstImprovement`
Tenta melhorar a solução movendo um item de um bin para outro.

Essa função é útil porque pode esvaziar bins inteiros, o que ajuda a reduzir o número total de bins.

### `swapFirstImprovement`
Se o shift não encontrar melhoria, essa função tenta trocar itens entre bins diferentes.

Ela serve para reorganizar a distribuição quando uma simples movimentação não resolve.

### `localSearch`
Executa a busca local chamando primeiro:

- `shiftFirstImprovement`
- depois `swapFirstImprovement`

Ela continua enquanto ainda houver melhorias e o tempo limite permitir.

### `perturb`
Aplica uma perturbação na melhor solução atual.

O que ela faz:

- identifica bins menos cheios;
- remove alguns deles;
- recoloca os itens usando `insertBestFit`.

Essa etapa evita que o algoritmo fique preso em um ótimo local.

### `iteratedLocalSearch`
É o coração do programa.

Fluxo:

1. cria uma solução inicial;
2. melhora com busca local;
3. guarda a melhor solução;
4. perturba a melhor solução;
5. roda busca local de novo;
6. repete até acabar o tempo.

### `printSolution`
Mostra a solução encontrada no terminal.

Ela imprime:

- os bins;
- a carga de cada bin;
- os itens em cada bin;
- o número total de bins;
- um limite inferior simples baseado em `ceil(soma/capacidade)`.

## Saída esperada

Ao final, o programa mostra a melhor solução encontrada e os bins usados.

