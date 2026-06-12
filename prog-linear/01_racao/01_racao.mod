// ======================================================
// Problema da Ração
// ======================================================

// ----------------------
// Conjuntos e parâmetros
// ----------------------

int nProdutos = ...;
int nRecursos = ...;

range Produtos = 1..nProdutos;
range Recursos = 1..nRecursos;

string nomeProduto[Produtos] = ...;
string nomeRecurso[Recursos] = ...;

float precoVenda[Produtos] = ...;
float custoRecurso[Recursos] = ...;
float disponibilidade[Recursos] = ...;


float consumo[Recursos][Produtos] = ...;

float lucroUnitario[p in Produtos] =
  precoVenda[p] - sum(r in Recursos) custoRecurso[r] * consumo[r][p];

// ----------------------
// Variáveis de decisão
// ----------------------

dvar float+ x[Produtos];

// ----------------------
// Função objetivo
// ----------------------

maximize
  sum(p in Produtos) lucroUnitario[p] * x[p];

// ----------------------
// Restrições
// ----------------------

subject to {

  
  forall(r in Recursos)
    sum(p in Produtos) consumo[r][p] * x[p] <= disponibilidade[r];

}

// ----------------------
// Impressao da solucao
// ----------------------

execute {
  writeln("==============================");
  writeln("PROBLEMA: Racao");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Valor objetivo / lucro maximo: ", cplex.getObjValue());

  writeln("");
  writeln("Lucro unitario:");
  for (var p in Produtos) {
    writeln(nomeProduto[p], " = ", lucroUnitario[p]);
  }

  writeln("");
  writeln("Solucao:");
  for (var p in Produtos) {
    writeln("Produzir ", nomeProduto[p], " = ", x[p]);
  }

  writeln("");
  writeln("Uso dos recursos:");
  for (var r in Recursos) {
    var uso = 0.0;

    for (var p in Produtos) {
      uso += consumo[r][p] * x[p];
    }

    writeln(nomeRecurso[r], ": usado = ", uso, " / disponivel = ", disponibilidade[r]);
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}