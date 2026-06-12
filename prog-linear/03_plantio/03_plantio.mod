// problema do plantio
// decidir quanto plantar de cada cultura em cada fazenda

int nFazendas = ...;
int nCulturas = ...;

range Fazendas = 1..nFazendas;
range Culturas = 1..nCulturas;

string nomeFazenda[Fazendas] = ...;
string nomeCultura[Culturas] = ...;

// dados das fazendas
float areaDisponivel[Fazendas] = ...;
float aguaDisponivel[Fazendas] = ...;

// dados das culturas
float areaMaxima[Culturas] = ...;
float aguaPorArea[Culturas] = ...;
float lucroPorArea[Culturas] = ...;

// x[f][c] = area da cultura c plantada na fazenda f
dvar float+ x[Fazendas][Culturas];

// proporcao de area usada em todas as fazendas
dvar float+ prop;

// queremos maximizar o lucro total
maximize
  sum(f in Fazendas, c in Culturas)
    lucroPorArea[c] * x[f][c];

subject to {

  // a proporcao de area plantada deve ser a mesma em todas as fazendas
  forall(f in Fazendas)
    sum(c in Culturas) x[f][c] == areaDisponivel[f] * prop;

  // nao pode usar mais agua do que cada fazenda tem
  forall(f in Fazendas)
    sum(c in Culturas) aguaPorArea[c] * x[f][c] <= aguaDisponivel[f];

  // cada cultura tem um limite maximo de area plantada no total
  forall(c in Culturas)
    sum(f in Fazendas) x[f][c] <= areaMaxima[c];

  // a proporcao nao pode passar de 100% da area
  prop <= 1;
}

execute {
  writeln("==============================");
  writeln("PROBLEMA: Plantio");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Lucro maximo: ", cplex.getObjValue());

  writeln("");
  writeln("Proporcao de area usada em cada fazenda: ", prop);

  writeln("");
  writeln("Area plantada por fazenda e cultura:");
  for (var f in Fazendas) {
    writeln("");
    writeln(nomeFazenda[f], ":");

    for (var c in Culturas) {
      if (x[f][c] > 0.000001) {
        writeln("  ", nomeCultura[c], " = ", x[f][c]);
      }
    }
  }

  writeln("");
  writeln("Uso de area por fazenda:");
  for (var f in Fazendas) {
    var areaUsada = 0.0;

    for (var c in Culturas) {
      areaUsada += x[f][c];
    }

    writeln(nomeFazenda[f], ": usada = ", areaUsada,
            " / disponivel = ", areaDisponivel[f]);
  }

  writeln("");
  writeln("Uso de agua por fazenda:");
  for (var f in Fazendas) {
    var aguaUsada = 0.0;

    for (var c in Culturas) {
      aguaUsada += aguaPorArea[c] * x[f][c];
    }

    writeln(nomeFazenda[f], ": usada = ", aguaUsada,
            " / disponivel = ", aguaDisponivel[f]);
  }

  writeln("");
  writeln("Area total por cultura:");
  for (var c in Culturas) {
    var areaCultura = 0.0;

    for (var f in Fazendas) {
      areaCultura += x[f][c];
    }

    writeln(nomeCultura[c], ": plantada = ", areaCultura,
            " / maximo = ", areaMaxima[c]);
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}