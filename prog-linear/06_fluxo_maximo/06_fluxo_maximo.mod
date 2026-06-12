// problema do fluxo maximo
// aqui queremos mandar o maior fluxo possivel de s ate t

{string} Nos = ...;

string origem = ...;
string destino = ...;

tuple Arco {
  string de;
  string para;
  int cap;
}

{Arco} Arcos = ...;

// x[a] = fluxo que passa no arco a
dvar float+ x[Arcos];

// fluxo total que sai da origem e chega no destino
dvar float+ fluxoTotal;

// queremos maximizar o fluxo enviado
maximize
  fluxoTotal;

subject to {

  // o fluxo total precisa sair da origem
  fluxoTotal == sum(a in Arcos : a.de == origem) x[a];

  // e tambem precisa chegar no destino
  fluxoTotal == sum(a in Arcos : a.para == destino) x[a];

  // cada arco tem sua capacidade maxima
  forall(a in Arcos)
    x[a] <= a.cap;

  // nos intermediarios nao acumulam fluxo
  // tudo que entra tambem precisa sair
  forall(n in Nos : n != origem && n != destino)
    sum(a in Arcos : a.para == n) x[a]
    ==
    sum(a in Arcos : a.de == n) x[a];
}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Fluxo Maximo");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Fluxo maximo: ", cplex.getObjValue());

  writeln("");
  writeln("Arcos usados:");
  for (var a in Arcos) {
    if (x[a] > 0.000001) {
      writeln(a.de, " -> ", a.para, " = ", x[a], " / cap = ", a.cap);
    }
  }

  writeln("");
  writeln("Conferencia dos nos intermediarios:");
  for (var n in Nos) {
    if (n != origem && n != destino) {
      var entrada = 0.0;
      var saida = 0.0;

      for (var a in Arcos) {
        if (a.para == n) {
          entrada += x[a];
        }

        if (a.de == n) {
          saida += x[a];
        }
      }

      writeln(n, ": entra = ", entrada, " / sai = ", saida);
    }
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}