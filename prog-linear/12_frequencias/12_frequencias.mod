// problema de frequencia
// vamos distribuir frequencias para as antenas sem dar interferencia

int nAntenas = ...;
int nFrequencias = ...;

range Antenas = 1..nAntenas;
range Frequencias = 1..nFrequencias;

string nomeAntena[Antenas] = ...;
string nomeFreq[Frequencias] = ...;

// interfere[i][j] = 1 se as antenas i e j interferem
int interfere[Antenas][Antenas] = ...;

// x[a][f] = 1 se a antena a usa a frequencia f
dvar boolean x[Antenas][Frequencias];

// y[f] = 1 se a frequencia f foi usada
dvar boolean y[Frequencias];

// queremos usar o menor numero de frequencias
minimize
  sum(f in Frequencias) y[f];

subject to {

  // cada antena recebe exatamente uma frequencia
  forall(a in Antenas)
    sum(f in Frequencias) x[a][f] == 1;

  // se duas antenas interferem, elas nao podem usar a mesma frequencia
  forall(a1 in Antenas, a2 in Antenas, f in Frequencias :
         a1 < a2 && interfere[a1][a2] == 1)
    x[a1][f] + x[a2][f] <= 1;

  // se uma antena usa uma frequencia, entao essa frequencia foi usada
  forall(a in Antenas, f in Frequencias)
    x[a][f] <= y[f];

  // so para ajudar o CPLEX a usar as frequencias em ordem
  forall(f in 1..nFrequencias-1)
    y[f] >= y[f+1];

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Frequencia");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Numero minimo de frequencias: ", cplex.getObjValue());

  writeln("");
  writeln("Frequencias usadas:");
  for (var f in Frequencias) {
    if (y[f] > 0.5) {
      writeln(nomeFreq[f]);
    }
  }

  writeln("");
  writeln("Frequencia escolhida para cada antena:");
  for (var a in Antenas) {
    for (var f in Frequencias) {
      if (x[a][f] > 0.5) {
        writeln(nomeAntena[a], " -> ", nomeFreq[f]);
      }
    }
  }

  writeln("");
  writeln("Conferencia das interferencias:");
  for (var a1 in Antenas) {
    for (var a2 in Antenas) {
      if (a1 < a2 && interfere[a1][a2] == 1) {
        var freqA1 = "";
        var freqA2 = "";

        for (var f in Frequencias) {
          if (x[a1][f] > 0.5) {
            freqA1 = nomeFreq[f];
          }

          if (x[a2][f] > 0.5) {
            freqA2 = nomeFreq[f];
          }
        }

        writeln(nomeAntena[a1], " e ", nomeAntena[a2],
                ": ", freqA1, " / ", freqA2);
      }
    }
  }

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}