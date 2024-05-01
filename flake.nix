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
        rebar = beamPackages.rebar.overrideAttrs (_old: { doCheck = false; });
        rebar3 = beamPackages.rebar3.overrideAttrs (_old: { doCheck = false; });

        # elixir,elixir-ls, and hex are using the same version elixir
        #
        elixir = beamPackages.elixir_1_16;
        # elixir-ls needs to be compiled with elixir_ls.release2 for the latest otp version
        elixir-ls = (beamPackages.elixir-ls.override { inherit elixir; }).overrideAttrs (_old: {
          buildPhase =
            ''
              runHook preBuild
              mix do compile --no-deps-check, elixir_ls.release2
              runHook postBuild
            '';
        });
        hex = beamPackages.hex.override {
          elixir = elixir;
        };


        locales = pkgs.glibcLocales;
      in
      {
        devShell = pkgs.mkShell {

          shellHook = ''
            # go to the top level.
            pushd "$FLAKE_ROOT" &> /dev/null
              # this allows mix to work on the local directory
              mkdir -p .nix-mix
              mkdir -p .nix-hex

              # set the environment variables
              export MIX_HOME=$PWD/.nix-mix
              export HEX_HOME=$PWD/.nix-hex

              # We want to be able to use binaries from the shell
              # so add them to the PATH
              export PATH=$MIX_HOME/bin:$PATH
              export PATH=$HEX_HOME/bin:$PATH

              # install rebar3 if it's not there
              find $MIX_HOME -type f -name 'rebar3' -executable -print0 | grep -qz . \
                  || mix local.rebar --if-missing rebar3 ${rebar3}/bin/rebar3

              # Install hex if it's not there
              find $MIX_HOME -type f -name 'hex.app' -print0 | grep -qz . \
                  || mix local.hex --if-missing
          '';

          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
          LC_CTYPE = "en_US.UTF-8";
          ERL_AFLAGS = "-kernel shell_history enabled";

          buildInputs = [
            elixir
            elixir-ls
            erlang
            rebar
            rebar3
            hex
            locales
          ];
        };
      }
    );
}
