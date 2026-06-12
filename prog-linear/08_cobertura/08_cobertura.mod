// problema de cobertura
// escolher os bairros onde vamos construir escolas
// todo bairro precisa estar coberto por pelo menos uma escola

int nBairros = ...;

range Bairros = 1..nBairros;

string nomeBairro[Bairros] = ...;

// cobre[i][j] = 1 se escola no bairro j cobre o bairro i
int cobre[Bairros][Bairros] = ...;

// x[j] = 1 se construir escola no bairro j
dvar boolean x[Bairros];

// minimizar a quantidade de escolas
minimize
  sum(j in Bairros) x[j];

subject to {

  // cada bairro i precisa ser atendido por pelo menos uma escola
  forall(i in Bairros)
    sum(j in Bairros) cobre[i][j] * x[j] >= 1;

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Cobertura");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Numero minimo de escolas: ", cplex.getObjValue());

  writeln("");
  writeln("Bairros escolhidos:");
  for (var j in Bairros) {
    if (x[j] > 0.5) {
      writeln(nomeBairro[j]);
    }
  }

  writeln("");
  writeln("Conferencia da cobertura:");
  for (var i in Bairros) {
    var total = 0.0;

    for (var j in Bairros) {
      total += cobre[i][j] * x[j];
    }

    writeln(nomeBairro[i], ": cobertura = ", total);
  }

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}