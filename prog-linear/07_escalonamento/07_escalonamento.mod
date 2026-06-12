// problema do escalonamento
// queremos contratar o menor numero de enfermeiras mantendo a demanda de todos os dias

int nDias = ...;

range Dias = 1..nDias;

string nomeDia[Dias] = ...;
int demanda[Dias] = ...;

int diasTrabalhados = ...;

// x[d] = enfermeiras que começam a trabalhar no dia d
dvar int+ x[Dias];

// total de enfermeiras contratadas
minimize
  sum(d in Dias) x[d];

subject to {

  // cada dia precisa ter enfermeiras suficientes
  // usamos mod para tratar a semana como circular
  forall(d in Dias)
    sum(i in Dias :
      ((d - i + nDias) mod nDias) < diasTrabalhados
    ) x[i] >= demanda[d];

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Escalonamento");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Numero minimo de enfermeiras: ", cplex.getObjValue());

  writeln("");
  writeln("Enfermeiras iniciando em cada dia:");
  for (var d in Dias) {
    if (x[d] > 0.000001) {
      writeln(nomeDia[d], " = ", x[d]);
    }
  }

  writeln("");
  writeln("Conferencia da demanda:");
  for (var d in Dias) {
    var totalNoDia = 0;

    for (var i in Dias) {
      if (((d - i + nDias) % nDias) < diasTrabalhados) {
        totalNoDia += x[i];
      }
    }

    writeln(nomeDia[d], ": trabalhando = ", totalNoDia,
            " / demanda = ", demanda[d]);
  }

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}