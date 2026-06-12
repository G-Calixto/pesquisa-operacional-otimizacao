// problema dos padroes
// decidir quantas impressoes fazer de cada padrao

int nPadroes = ...;
int nTiposFolha = ...;

range Padroes = 1..nPadroes;
range TiposFolha = 1..nTiposFolha;

string nomePadrao[Padroes] = ...;

int tipoFolha[Padroes] = ...;
int numCorpo[Padroes] = ...;
int numTampa[Padroes] = ...;
int tempo[Padroes] = ...;

int folhasDisponiveis[TiposFolha] = ...;
int tempoMax = ...;

int precoLata = ...;
int custoCorpoSobra = ...;
int custoTampa = ...;

// x[p] = quantas vezes usamos o padrao p
dvar int+ x[Padroes];

// quantidade de latinhas completas
dvar int+ latas;

// sobras
dvar int+ sobraCorpos;
dvar int+ sobraTampas;

// lucro total
maximize
  precoLata * latas
  - custoCorpoSobra * sobraCorpos
  - custoTampa * sum(p in Padroes) numTampa[p] * x[p];

subject to {

  // limite de folhas de cada tipo
  forall(t in TiposFolha)
    sum(p in Padroes : tipoFolha[p] == t) x[p] <= folhasDisponiveis[t];

  // limite de tempo de impressao
  sum(p in Padroes) tempo[p] * x[p] <= tempoMax;

  // cada lata usa 1 corpo
  latas + sobraCorpos == sum(p in Padroes) numCorpo[p] * x[p];

  // cada lata usa 2 tampas
  2 * latas + sobraTampas == sum(p in Padroes) numTampa[p] * x[p];

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Padroes");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Lucro maximo: ", cplex.getObjValue());

  writeln("");
  writeln("Padroes usados:");
  for (var p in Padroes) {
    if (x[p] > 0.000001) {
      writeln(nomePadrao[p], " = ", x[p]);
    }
  }

  var totalCorpos = 0;
  var totalTampas = 0;
  var tempoUsado = 0;

  for (var p in Padroes) {
    totalCorpos += numCorpo[p] * x[p];
    totalTampas += numTampa[p] * x[p];
    tempoUsado += tempo[p] * x[p];
  }

  writeln("");
  writeln("Conferencia:");
  writeln("Latas produzidas = ", latas);
  writeln("Corpos produzidos = ", totalCorpos);
  writeln("Tampas produzidas = ", totalTampas);
  writeln("Sobra de corpos = ", sobraCorpos);
  writeln("Sobra de tampas = ", sobraTampas);
  writeln("Tempo usado = ", tempoUsado, " / ", tempoMax);

  writeln("");
  writeln("Uso de folhas:");
  for (var t in TiposFolha) {
    var folhasUsadas = 0;

    for (var p in Padroes) {
      if (tipoFolha[p] == t) {
        folhasUsadas += x[p];
      }
    }

    writeln("Folha tipo ", t, ": usada = ", folhasUsadas,
            " / disponivel = ", folhasDisponiveis[t]);
  }

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}