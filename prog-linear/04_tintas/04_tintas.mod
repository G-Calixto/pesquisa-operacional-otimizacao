// problema das tintas
// vamos decidir quanto usar de cada produto em cada tipo de tinta

int nProdutos = ...;
int nTintas = ...;

range Produtos = 1..nProdutos;
range Tintas = 1..nTintas;

string nomeProduto[Produtos] = ...;
string nomeTinta[Tintas] = ...;

// custo de cada produto por litro
float custo[Produtos] = ...;

// composicao de cada produto
float percSEC[Produtos] = ...;
float percCOR[Produtos] = ...;

// demanda de cada tinta
float demanda[Tintas] = ...;

// exigencias minimas de cada tinta
float minSEC[Tintas] = ...;
float minCOR[Tintas] = ...;

// x[p][t] = litros do produto p usados na tinta t
dvar float+ x[Produtos][Tintas];

// custo total
minimize
  sum(p in Produtos, t in Tintas)
    custo[p] * x[p][t];

subject to {

  // cada tinta precisa ser produzida na quantidade pedida
  forall(t in Tintas)
    sum(p in Produtos) x[p][t] == demanda[t];

  // minimo de componente SEC em cada tinta
  forall(t in Tintas)
    sum(p in Produtos) percSEC[p] * x[p][t] >= minSEC[t] * demanda[t];

  // minimo de componente COR em cada tinta
  forall(t in Tintas)
    sum(p in Produtos) percCOR[p] * x[p][t] >= minCOR[t] * demanda[t];
}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Tintas");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Custo minimo: ", cplex.getObjValue());

  writeln("");
  writeln("Quantidade usada de cada produto:");
  for (var t in Tintas) {
    writeln("");
    writeln(nomeTinta[t], ":");

    for (var p in Produtos) {
      if (x[p][t] > 0.000001) {
        writeln("  ", nomeProduto[p], " = ", x[p][t], " litros");
      }
    }
  }

  writeln("");
  writeln("Conferencia da composicao:");
  for (var t in Tintas) {
    var totalSEC = 0.0;
    var totalCOR = 0.0;
    var totalVolume = 0.0;

    for (var p in Produtos) {
      totalSEC += percSEC[p] * x[p][t];
      totalCOR += percCOR[p] * x[p][t];
      totalVolume += x[p][t];
    }

    writeln("");
    writeln(nomeTinta[t], ":");
    writeln("  volume = ", totalVolume, " / demanda = ", demanda[t]);
    writeln("  SEC = ", totalSEC, " / minimo = ", minSEC[t] * demanda[t]);
    writeln("  COR = ", totalCOR, " / minimo = ", minCOR[t] * demanda[t]);
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}