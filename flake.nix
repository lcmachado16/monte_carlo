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

      texEnv = pkgs.texliveSmall.withPackages (ps: with ps; [
        scheme-medium
        wrapfig
        ulem
        capt-of
        beamer
        newunicodechar
      ]);
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gcc
          pkgs.gnumake
          pkgs.bash
          rEnv
          pkgs.pandoc
          texEnv
          pkgs.emacs-nox   # criar pdf automaticamente
        ];

        shellHook = ''
          echo "Ambiente Nix carregado para o TF de Desempenho."
          echo "Compilador C++: $(g++ --version | head -n 1)"
          echo "R com tidyverse e rmarkdown prontos para uso."
        '';
      };
    };
}