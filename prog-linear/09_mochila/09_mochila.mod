// problema da mochila
// escolher os itens de maior valor sem passar da capacidade

int nItens = ...;

range Itens = 1..nItens;

string nomeItem[Itens] = ...;

int valor[Itens] = ...;
int peso[Itens] = ...;

int capacidade = ...;

// x[i] = 1 se o item i entra na mochila
dvar boolean x[Itens];

// valor total dos itens escolhidos
maximize
  sum(i in Itens) valor[i] * x[i];

subject to {

  // a mochila nao pode passar da capacidade
  sum(i in Itens) peso[i] * x[i] <= capacidade;

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Mochila");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Valor maximo: ", cplex.getObjValue());

  writeln("");
  writeln("Itens escolhidos:");

  var pesoTotal = 0;
  var valorTotal = 0;

  for (var i in Itens) {
    if (x[i] > 0.5) {
      writeln(nomeItem[i],
              " | valor = ", valor[i],
              " | peso = ", peso[i]);

      pesoTotal += peso[i];
      valorTotal += valor[i];
    }
  }

  writeln("");
  writeln("Conferencia:");
  writeln("Peso total = ", pesoTotal, " / capacidade = ", capacidade);
  writeln("Valor total = ", valorTotal);

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}