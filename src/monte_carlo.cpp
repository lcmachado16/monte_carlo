// Monte Carlo para estimar pi (OpenMP).
// Uso: ./monte_carlo <N> <Threads> <Repeticao> [Semente=12345]
// Saida CSV: Repeticao,Threads,N,M,Pi_Estimado,Erro_Abs,Erro_Rel_Perc,Tempo_Execucao,Semente,Threads_Reais
#include <iostream>
#include <iomanip>
#include <string>
#include <random>
#include <cmath>
#include <cstdint>
#include <omp.h>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc != 4 && argc != 5) {
        cerr << "Uso: ./monte_carlo <N> <Threads> <Repeticao> [Semente]" << endl;
        return 1;
    }
    long long N = stoll(argv[1]);
    int num_threads = stoi(argv[2]);
    long long repeticao = stoll(argv[3]);
    unsigned long long semente = (argc == 5) ? stoull(argv[4]) : 12345ULL; 

    long long M = 0;
    int threads_reais = 0;
    const double pi_ref = acos(-1.0); // Ground truth: pi = 3.14159265358979323846
    omp_set_num_threads(num_threads);

    double t0 = omp_get_wtime();
    #pragma omp parallel reduction(+:M)
    {
        #pragma omp single
        threads_reais = omp_get_num_threads();

        // Fluxo independente por (semente da execucao, thread): seed_seq mistura os
        // valores, evitando que threads/repeticoes diferentes compartilhem sequencias
        // (o esquema "12345 + tid + rep" repetia fluxos entre repeticoes).
        seed_seq ss{(uint32_t)(semente & 0xFFFFFFFFu), (uint32_t)(semente >> 32),
                    (uint32_t)omp_get_thread_num()};
        mt19937 rng(ss);
        uniform_real_distribution<double> dist(-1.0, 1.0);

        #pragma omp for schedule(static)   // explicito: M depende do particionamento
        for (long long i = 0; i < N; ++i) {
            double x = dist(rng), y = dist(rng);
            if (x * x + y * y <= 1.0) M++;
        }
    }
    double tempo = omp_get_wtime() - t0;

    double pi_est = 4.0 * (double)M / (double)N;
    double erro_abs = fabs(pi_est - pi_ref);
    cout << setprecision(10)
         << repeticao << "," << num_threads << "," << N << "," << M << ","
         << pi_est << "," << erro_abs << "," << (erro_abs / pi_ref) * 100.0 << ","
         << tempo << "," << semente << "," << threads_reais << endl;
    return 0;
}
