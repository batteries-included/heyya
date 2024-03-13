{
  description = "The entire Batteries Included world";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = inputs@{ flake-utils, nixpkgs, ... }:
   flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        beam = pkgs.beam;
        beamPackages = beam.packagesWith beam.interpreters.erlang_26;
        erlang = beamPackages.erlang;
        rebar3 = beamPackages.rebar3;

        # elixir and elixir-ls are using the same version
        elixir = beamPackages.elixir_1_16;
        hex = beamPackages.hex.override { inherit elixir; };
        elixir-ls = (beamPackages.elixir-ls.override { inherit elixir; }).overrideAttrs (_old: {
          buildPhase =
            ''
              runHook preBuild
              mix do compile --no-deps-check, elixir_ls.release2
              runHook postBuild
            '';
        });

        locales = pkgs.glibcLocales;
      in
      {
        devShell = pkgs.mkShell {

        shellHook = ''
          # this allows mix to work on the local directory
          mkdir -p .nix-mix
          mkdir -p .nix-hex
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-hex
          export PATH=$MIX_HOME/bin:$PATH
          export PATH=$HEX_HOME/bin:$PATH

          mix local.rebar --if-missing rebar3 ${rebar3}/bin/rebar3;
        '';

        LANG = "en_US.UTF-8";
        ERL_AFLAGS = "-kernel shell_history enabled";

        buildInputs = [
          elixir
          elixir-ls
          erlang
          rebar3
          hex
          locales
        ];
      };
    }
  );
}
