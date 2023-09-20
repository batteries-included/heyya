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
        elixir = pkgs.beam.packages.erlang.elixir_1_15;
        erlang = pkgs.beam.packages.erlang.erlang;
        rebar3 = pkgs.beam.packages.erlang.rebar3;
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
          mix local.hex --force --if-missing
        '';

        LANG = "en_US.UTF-8";
        ERL_AFLAGS = "-kernel shell_history enabled";

        buildInputs = [
          elixir
          erlang
          rebar3
          locales
        ];
      };
    }
  );
}
