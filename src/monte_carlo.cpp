#include <iostream>
#include <cstdlib>
#include <string>   // Faltava para stoll() e stoi()
#include <random>
#include <cmath>
#include <omp.h>

using namespace std;

int main(int argc, char* argv[]) {
    if (argc != 4) {
        cerr << "Uso: ./monte_carlo <N> <Threads> <Repeticao>" << endl;
        return 1;
    }

    // A conversão funciona em segurança pois o script R gerou strings inteiras sem notação científica
    long long N = stoll(argv[1]);
    int num_threads = stoi(argv[2]);
    long long repeticao = stoll(argv[3]);
    
    long long M = 0;
    double pi_ref = acos(-1.0);

    // Ajusta o numero de threads da iteracao
    omp_set_num_threads(num_threads);

    double tempo_inicio = omp_get_wtime();

    #pragma omp parallel reduction(+:M)
    {
        // Seed unica por thread e iteracao minimiza padroes repetidos no gerador Mersenne Twister
        mt19937 rng(12345 + omp_get_thread_num() + repeticao);
        uniform_real_distribution<double> dist(-1.0, 1.0);

        #pragma omp for
        for (long long i = 0; i < N; ++i) {
            double x = dist(rng);
            double y = dist(rng);
            if (x * x + y * y <= 1.0) {
                M++;
            }
        }
    }

    double tempo_fim = omp_get_wtime();
    double tempo_execucao = tempo_fim - tempo_inicio;

    // Cast explícito para double garantindo precisão total na divisão em ponto flutuante
    double pi_estimado = 4.0 * (double)M / (double)N;
    double erro_abs = abs(pi_estimado - pi_ref);
    double erro_rel_percentual = (erro_abs / pi_ref) * 100.0;

    // Saida limpa CSV formatada
    cout << repeticao << ","
         << num_threads << ","
         << N << ","
         << M << ","
         << pi_estimado << ","
         << erro_abs << ","
         << erro_rel_percentual << ","
         << tempo_execucao << endl;

    return 0;
}