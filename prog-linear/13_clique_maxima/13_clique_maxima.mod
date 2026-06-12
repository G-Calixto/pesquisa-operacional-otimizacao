// problema da clique maxima
// escolher o maior conjunto de vertices todos conectados entre si

int nVertices = ...;

range Vertices = 1..nVertices;

string nomeVertice[Vertices] = ...;

// aresta[i][j] = 1 se existe aresta entre i e j
int aresta[Vertices][Vertices] = ...;

// x[v] = 1 se o vertice v entra na clique
dvar boolean x[Vertices];

// tamanho da clique
maximize
  sum(v in Vertices) x[v];

subject to {

  // se nao existe aresta entre dois vertices,
  // eles nao podem estar juntos na clique
  forall(i in Vertices, j in Vertices : i < j && aresta[i][j] == 0)
    x[i] + x[j] <= 1;

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Clique Maxima");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Tamanho da clique maxima: ", cplex.getObjValue());

  writeln("");
  writeln("Vertices escolhidos:");

  var tamanho = 0;

  for (var v in Vertices) {
    if (x[v] > 0.5) {
      writeln(nomeVertice[v]);
      tamanho += 1;
    }
  }

  writeln("");
  writeln("Conferencia dos pares escolhidos:");
  for (var i in Vertices) {
    for (var j in Vertices) {
      if (i < j && x[i] > 0.5 && x[j] > 0.5) {
        writeln(nomeVertice[i], " - ", nomeVertice[j],
                " | aresta = ", aresta[i][j]);
      }
    }
  }

  writeln("");
  writeln("Quantidade conferida = ", tamanho);

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}