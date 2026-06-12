// problema das facilidades
// escolher quais depositos abrir e quem atende cada cliente

int nDepositos = ...;
int nClientes = ...;

range Depositos = 1..nDepositos;
range Clientes = 1..nClientes;

string nomeDeposito[Depositos] = ...;
string nomeCliente[Clientes] = ...;

// custo fixo para abrir cada deposito
int custoAbertura[Depositos] = ...;

// custoAtendimento[i][j] = custo do deposito i atender o cliente j
int custoAtendimento[Depositos][Clientes] = ...;

// y[i] = 1 se o deposito i for aberto
dvar boolean y[Depositos];

// x[i][j] = 1 se o cliente j for atendido pelo deposito i
dvar boolean x[Depositos][Clientes];

// custo total
minimize
  sum(i in Depositos) custoAbertura[i] * y[i]
  +
  sum(i in Depositos, j in Clientes) custoAtendimento[i][j] * x[i][j];

subject to {

  // cada cliente precisa ser atendido por um unico deposito
  forall(j in Clientes)
    sum(i in Depositos) x[i][j] == 1;

  // so posso atender cliente usando deposito que foi aberto
  forall(i in Depositos, j in Clientes)
    x[i][j] <= y[i];

}


execute {
  writeln("==============================");
  writeln("PROBLEMA: Facilidades");
  writeln("==============================");

  writeln("Status CPLEX: ", cplex.getCplexStatus());
  writeln("Custo minimo: ", cplex.getObjValue());

  writeln("");
  writeln("Depositos abertos:");
  for (var i in Depositos) {
    if (y[i] > 0.5) {
      writeln(nomeDeposito[i], " | custo abertura = ", custoAbertura[i]);
    }
  }

  writeln("");
  writeln("Atendimento dos clientes:");
  for (var j in Clientes) {
    for (var i in Depositos) {
      if (x[i][j] > 0.5) {
        writeln(nomeCliente[j], " atendido por ", nomeDeposito[i],
                " | custo = ", custoAtendimento[i][j]);
      }
    }
  }

  var custoFixo = 0;
  var custoServico = 0;

  for (var i in Depositos) {
    if (y[i] > 0.5) {
      custoFixo += custoAbertura[i];
    }
  }

  for (var i in Depositos) {
    for (var j in Clientes) {
      if (x[i][j] > 0.5) {
        custoServico += custoAtendimento[i][j];
      }
    }
  }

  writeln("");
  writeln("Conferencia:");
  writeln("Custo de abertura = ", custoFixo);
  writeln("Custo de atendimento = ", custoServico);
  writeln("Custo total = ", custoFixo + custoServico);

  writeln("");
  writeln("Best bound: verificar no log do CPLEX");
  writeln("Gap: verificar no log do CPLEX");
  writeln("Nos explorados: verificar no log do CPLEX");

  writeln("==============================");
}