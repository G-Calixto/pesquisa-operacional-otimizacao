#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

using namespace std;

static constexpr double EPS = 1e-9;

struct Instance {
    int n{};
    double capacity{};
    vector<double> weight;
};

struct Solution {
    vector<vector<int>> bins;   
    vector<double> load;        
};

struct Cost {
    int numberOfBins{};
    double negativeCompactness{}; 
};

Instance readInstance(const string& filename) {
    ifstream in(filename);
    if (!in) {
        throw runtime_error("Nao foi possivel abrir o arquivo: " + filename);
    }

    Instance inst;
    if (!(in >> inst.n >> inst.capacity)) {
        throw runtime_error("Formato invalido. Esperado: n capacidade, depois os pesos dos itens.");
    }
    if (inst.n <= 0) {
        throw runtime_error("Numero de itens deve ser positivo.");
    }
    if (inst.capacity <= 0.0) {
        throw runtime_error("Capacidade deve ser positiva.");
    }

    inst.weight.assign(inst.n, 0.0);
    for (int i = 0; i < inst.n; ++i) {
        if (!(in >> inst.weight[i])) {
            throw runtime_error("Arquivo terminou antes de ler todos os pesos dos itens.");
        }
        if (inst.weight[i] < -EPS) {
            throw runtime_error("Item com peso negativo encontrado.");
        }
        if (inst.weight[i] > inst.capacity + EPS) {
            throw runtime_error("Existe item maior que a capacidade do bin.");
        }
    }

    return inst;
}

Cost evaluate(const Solution& sol) {
    double compactness = 0.0;
    for (double l : sol.load) {
        compactness += l * l;
    }
    return Cost{static_cast<int>(sol.bins.size()), -compactness};
}

bool betterCost(const Cost& a, const Cost& b) {
    if (a.numberOfBins != b.numberOfBins) {
        return a.numberOfBins < b.numberOfBins;
    }
    return a.negativeCompactness < b.negativeCompactness - EPS;
}

bool betterSolution(const Solution& a, const Solution& b) {
    return betterCost(evaluate(a), evaluate(b));
}

void removeEmptyBins(Solution& sol) {
    for (int b = static_cast<int>(sol.bins.size()) - 1; b >= 0; --b) {
        if (sol.bins[b].empty()) {
            sol.bins.erase(sol.bins.begin() + b);
            sol.load.erase(sol.load.begin() + b);
        }
    }
}

Solution firstFitDecreasing(const Instance& inst) {
    vector<int> order(inst.n);
    iota(order.begin(), order.end(), 0);

    sort(order.begin(), order.end(), [&](int a, int b) {
        return inst.weight[a] > inst.weight[b] + EPS;
    });

    Solution sol;
    for (int item : order) {
        bool placed = false;
        for (size_t b = 0; b < sol.bins.size(); ++b) {
            if (sol.load[b] + inst.weight[item] <= inst.capacity + EPS) {
                sol.bins[b].push_back(item);
                sol.load[b] += inst.weight[item];
                placed = true;
                break;
            }
        }
        if (!placed) {
            sol.bins.push_back(vector<int>{item});
            sol.load.push_back(inst.weight[item]);
        }
    }
    return sol;
}

bool isFeasible(const Solution& sol, const Instance& inst, string* reason = nullptr) {
    vector<int> count(inst.n, 0);

    if (sol.bins.size() != sol.load.size()) {
        if (reason) *reason = "Quantidade de bins e cargas nao bate.";
        return false;
    }

    for (size_t b = 0; b < sol.bins.size(); ++b) {
        double realLoad = 0.0;
        for (int item : sol.bins[b]) {
            if (item < 0 || item >= inst.n) {
                if (reason) *reason = "Indice de item invalido.";
                return false;
            }
            count[item]++;
            realLoad += inst.weight[item];
        }
        if (realLoad > inst.capacity + EPS) {
            if (reason) *reason = "Algum bin excede a capacidade.";
            return false;
        }
        if (fabs(realLoad - sol.load[b]) > 1e-7) {
            if (reason) *reason = "Carga armazenada diferente da carga real.";
            return false;
        }
    }

    for (int i = 0; i < inst.n; ++i) {
        if (count[i] != 1) {
            if (reason) *reason = "Algum item nao aparece exatamente uma vez.";
            return false;
        }
    }

    return true;
}

bool shiftFirstImprovement(Solution& sol, const Instance& inst) {
    Cost currentCost = evaluate(sol);

    vector<int> sourceOrder(sol.bins.size());
    iota(sourceOrder.begin(), sourceOrder.end(), 0);
    sort(sourceOrder.begin(), sourceOrder.end(), [&](int a, int b) {
        return sol.load[a] < sol.load[b] - EPS; 
    });

    vector<int> targetOrder(sol.bins.size());
    iota(targetOrder.begin(), targetOrder.end(), 0);
    sort(targetOrder.begin(), targetOrder.end(), [&](int a, int b) {
        return sol.load[a] > sol.load[b] + EPS; 
    });

    for (int i : sourceOrder) {
        vector<int> itemOrder = sol.bins[i];
        sort(itemOrder.begin(), itemOrder.end(), [&](int a, int b) {
            return inst.weight[a] > inst.weight[b] + EPS;
        });

        for (int item : itemOrder) {
            for (int j : targetOrder) {
                if (i == j) continue;
                if (sol.load[j] + inst.weight[item] > inst.capacity + EPS) continue;

                Solution candidate = sol;

                auto& src = candidate.bins[i];
                auto it = find(src.begin(), src.end(), item);
                if (it == src.end()) continue;

                src.erase(it);
                candidate.load[i] -= inst.weight[item];

                candidate.bins[j].push_back(item);
                candidate.load[j] += inst.weight[item];

                removeEmptyBins(candidate);

                if (betterCost(evaluate(candidate), currentCost)) {
                    sol = std::move(candidate);
                    return true;
                }
            }
        }
    }

    return false;
}

bool swapFirstImprovement(Solution& sol, const Instance& inst) {
    Cost currentCost = evaluate(sol);

    for (int i = 0; i < static_cast<int>(sol.bins.size()); ++i) {
        for (int j = i + 1; j < static_cast<int>(sol.bins.size()); ++j) {
            for (int itemI : sol.bins[i]) {
                for (int itemJ : sol.bins[j]) {
                    double newLoadI = sol.load[i] - inst.weight[itemI] + inst.weight[itemJ];
                    double newLoadJ = sol.load[j] - inst.weight[itemJ] + inst.weight[itemI];

                    if (newLoadI > inst.capacity + EPS || newLoadJ > inst.capacity + EPS) {
                        continue;
                    }

                    Solution candidate = sol;
                    auto& binI = candidate.bins[i];
                    auto& binJ = candidate.bins[j];

                    auto itI = find(binI.begin(), binI.end(), itemI);
                    auto itJ = find(binJ.begin(), binJ.end(), itemJ);
                    if (itI == binI.end() || itJ == binJ.end()) continue;

                    *itI = itemJ;
                    *itJ = itemI;
                    candidate.load[i] = newLoadI;
                    candidate.load[j] = newLoadJ;

                    if (betterCost(evaluate(candidate), currentCost)) {
                        sol = std::move(candidate);
                        return true;
                    }
                }
            }
        }
    }

    return false;
}

void localSearch(Solution& sol, const Instance& inst, chrono::steady_clock::time_point start, double timeLimit) {
    while (chrono::duration<double>(chrono::steady_clock::now() - start).count() < timeLimit) {
        bool improved = false;

        if (shiftFirstImprovement(sol, inst)) {
            improved = true;
        } else if (swapFirstImprovement(sol, inst)) {
            improved = true;
        }

        if (!improved) break;
    }
}

void insertBestFit(Solution& sol, int item, const Instance& inst) {
    int bestBin = -1;
    double bestResidual = numeric_limits<double>::infinity();

    for (int b = 0; b < static_cast<int>(sol.bins.size()); ++b) {
        double newLoad = sol.load[b] + inst.weight[item];
        if (newLoad <= inst.capacity + EPS) {
            double residual = inst.capacity - newLoad;
            if (residual < bestResidual - EPS) {
                bestResidual = residual;
                bestBin = b;
            }
        }
    }

    if (bestBin == -1) {
        sol.bins.push_back(vector<int>{item});
        sol.load.push_back(inst.weight[item]);
    } else {
        sol.bins[bestBin].push_back(item);
        sol.load[bestBin] += inst.weight[item];
    }
}

Solution perturb(const Solution& best, const Instance& inst, mt19937& rng) {
    if (best.bins.size() <= 1) return best;

    Solution sol = best;

    vector<int> order(sol.bins.size());
    iota(order.begin(), order.end(), 0);
    sort(order.begin(), order.end(), [&](int a, int b) {
        return sol.load[a] < sol.load[b] - EPS;
    });

    int destroyCount = min<int>(2, sol.bins.size());
    vector<int> selected(order.begin(), order.begin() + destroyCount);
    sort(selected.rbegin(), selected.rend()); 

    vector<int> removedItems;
    for (int b : selected) {
        removedItems.insert(removedItems.end(), sol.bins[b].begin(), sol.bins[b].end());
        sol.bins.erase(sol.bins.begin() + b);
        sol.load.erase(sol.load.begin() + b);
    }

    shuffle(removedItems.begin(), removedItems.end(), rng);
    for (int item : removedItems) {
        insertBestFit(sol, item, inst);
    }

    return sol;
}

Solution iteratedLocalSearch(const Instance& inst, double timeLimit, unsigned seed) {
    auto start = chrono::steady_clock::now();
    mt19937 rng(seed);

    Solution current = firstFitDecreasing(inst);
    localSearch(current, inst, start, timeLimit);

    Solution best = current;

    while (chrono::duration<double>(chrono::steady_clock::now() - start).count() < timeLimit) {
        current = perturb(best, inst, rng);
        localSearch(current, inst, start, timeLimit);

        if (betterSolution(current, best)) {
            best = current;
        }
    }

    return best;
}

void printSolution(const Solution& sol, const Instance& inst) {
    vector<int> order(sol.bins.size());
    iota(order.begin(), order.end(), 0);
    sort(order.begin(), order.end(), [&](int a, int b) {
        return sol.load[a] > sol.load[b] + EPS;
    });

    cout << fixed << setprecision(6);
    cout << "Melhor solucao encontrada:\n";
    int shown = 1;
    for (int b : order) {
        cout << "Bin " << shown++ << " | carga = " << sol.load[b] << " | itens: ";
        for (int item : sol.bins[b]) {
            cout << "(" << item << ": " << inst.weight[item] << ") ";
        }
        cout << '\n';
    }

    double totalWeight = accumulate(inst.weight.begin(), inst.weight.end(), 0.0);
    int lowerBound = static_cast<int>(ceil(totalWeight / inst.capacity - EPS));

    cout << "\nNumero de bins: " << sol.bins.size() << '\n';
    cout << "Limite inferior simples ceil(soma/capacidade): " << lowerBound << '\n';
    cout << "Soma dos itens: " << totalWeight << '\n';
}

int main(int argc, char* argv[]) {
    try {
        if (argc < 3) {
            cerr << "Uso: " << argv[0] << " <arquivo_instancia.txt> <tempo_limite_segundos> [semente]\n";
            cerr << "Exemplo: " << argv[0] << " input.txt 5 123\n";
            return 1;
        }

        string filename = argv[1];
        double timeLimit = stod(argv[2]);
        if (timeLimit <= 0.0) {
            throw runtime_error("Tempo limite deve ser positivo.");
        }

        unsigned seed;
        if (argc >= 4) {
            seed = static_cast<unsigned>(stoul(argv[3]));
        } else {
            seed = static_cast<unsigned>(chrono::high_resolution_clock::now().time_since_epoch().count());
        }

        Instance inst = readInstance(filename);
        Solution best = iteratedLocalSearch(inst, timeLimit, seed);

        string reason;
        if (!isFeasible(best, inst, &reason)) {
            cerr << "Solucao inviavel: " << reason << '\n';
            return 2;
        }

        printSolution(best, inst);
        return 0;
    } catch (const exception& e) {
        cerr << "Erro: " << e.what() << '\n';
        return 1;
    }
}
