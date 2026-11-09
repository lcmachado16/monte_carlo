{
  description = "Ambiente reprodutível para TF de Desempenho - Monte Carlo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      rEnv = pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [
          rmarkdown
          knitr
          tidyverse
          ggplot2
          dplyr
        ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gcc
          pkgs.gnumake
          pkgs.bash
          rEnv
          pkgs.pandoc # Necessário para o rmarkdown renderizar HTML/PDF
        ];

        shellHook = ''
          echo "Ambiente Nix carregado para o TF de Desempenho."
          echo "Compilador C++: $(g++ --version | head -n 1)"
          echo "R com tidyverse e rmarkdown prontos para uso."
        '';
      };
    };
}