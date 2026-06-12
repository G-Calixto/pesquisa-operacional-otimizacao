// problema do transporte
// decidir quanto mandar de cada fabrica para cada deposito

int nFabricas = ...;
int nDepositos = ...;

range Fabricas = 1..nFabricas;
range Depositos = 1..nDepositos;

string nomeFabrica[Fabricas] = ...;
string nomeDeposito[Depositos] = ...;

float oferta[Fabricas] = ...;
float demanda[Depositos] = ...;

// custo[i][j] = custo de mandar da fabrica i para o deposito j
float custo[Fabricas][Depositos] = ...;

// x[i][j] = quantidade enviada da fabrica i para o deposito j
dvar float+ x[Fabricas][Depositos];

// custo total de transporte
minimize
  sum(i in Fabricas, j in Depositos)
    custo[i][j] * x[i][j];

subject to {

  // tudo que cada fabrica tem deve ser enviado
  forall(i in Fabricas)
    sum(j in Depositos) x[i][j] == oferta[i];

  // cada deposito precisa receber sua demanda
  forall(j in Depositos)
    sum(i in Fabricas) x[i][j] == demanda[j];
}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Transporte");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Custo minimo: ", cplex.getObjValue());

  writeln("");
  writeln("Rotas usadas:");
  for (var i in Fabricas) {
    for (var j in Depositos) {
      if (x[i][j] > 0.000001) {
        writeln(nomeFabrica[i], " -> ", nomeDeposito[j], " = ", x[i][j]);
      }
    }
  }

  writeln("");
  writeln("Conferencia das fabricas:");
  for (var i in Fabricas) {
    var totalEnviado = 0.0;

    for (var j in Depositos) {
      totalEnviado += x[i][j];
    }

    writeln(nomeFabrica[i], ": enviado = ", totalEnviado,
            " / oferta = ", oferta[i]);
  }

  writeln("");
  writeln("Conferencia dos depositos:");
  for (var j in Depositos) {
    var totalRecebido = 0.0;

    for (var i in Fabricas) {
      totalRecebido += x[i][j];
    }

    writeln(nomeDeposito[j], ": recebido = ", totalRecebido,
            " / demanda = ", demanda[j]);
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}