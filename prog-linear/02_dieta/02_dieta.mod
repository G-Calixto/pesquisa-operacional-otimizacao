// problema da dieta
// mistura com menor custo, respeitando o mínimo de vitaminas A = 9 e C = 19

int nIngredientes = ...;
int nVitaminas = ...;

range Ingredientes = 1..nIngredientes;
range Vitaminas = 1..nVitaminas;

string nomeIngrediente[Ingredientes] = ...;
string nomeVitamina[Vitaminas] = ...;

float preco[Ingredientes] = ...;
float minimo[Vitaminas] = ...;


float qtdVitamina[Vitaminas][Ingredientes] = ...;


dvar float+ x[Ingredientes];


minimize
  sum(i in Ingredientes) preco[i] * x[i];

subject to {

  
  forall(v in Vitaminas)
    sum(i in Ingredientes) qtdVitamina[v][i] * x[i] >= minimo[v];

}

execute {
  writeln("==============================");
  writeln("PROBLEMA: Dieta");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Custo minimo: ", cplex.getObjValue());

  writeln("");
  writeln("Ingredientes usados:");
  for (var i in Ingredientes) {
    if (x[i] > 0.000001) {
      writeln(nomeIngrediente[i], " = ", x[i]);
    }
  }

  writeln("");
  writeln("Vitaminas obtidas:");
  for (var v in Vitaminas) {
    var totalVitamina = 0.0;

    for (var i in Ingredientes) {
      totalVitamina += qtdVitamina[v][i] * x[i];
    }

    writeln(nomeVitamina[v], ": obtido = ", totalVitamina, " / minimo = ", minimo[v]);
  }

  writeln("");
  writeln("Best bound: nao aplicavel - modelo PL continuo");
  writeln("Gap: nao aplicavel - modelo PL continuo");
  writeln("Nos explorados: nao aplicavel - modelo PL continuo");

  writeln("==============================");
}