{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs =
    { self
    , flake-utils
    , opam-nix
    , nixpkgs
    ,
    }:
    let
      package = "avatar-bot";
    in
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsMusl = pkgs.pkgsCross.musl64;
      on = opam-nix.lib.${system};

      # Ocaml development packages
      devPackagesQuery = {
        ocaml-lsp-server = "*";
        ocamlformat = "*";
      };
      # You can force versions of certain packages here
      query = devPackagesQuery // { };

      createScope = pkgs: on.buildDuneProject { pkgs = pkgs; } package ./. query;

      overlay = final: prev: {
        ${package} = prev.${package}.overrideAttrs (attr: {
          # Prevent the ocaml dependencies from leaking into dependent environments
          doNixSupport = false;
        });
      };

      overlayMusl = final: prev: {
        ${package} = prev.${package}.overrideAttrs
          (attr: {
            doNixSupport = false;
            buildInputs = attr.buildInputs ++ [ pkgsMusl.pkgsStatic.gmp ];
          });

        conf-gmp = prev.conf-gmp.overrideAttrs (attr: {
          depsBuildBuild = [ pkgs.stdenv.cc ];
        });

        conf-gmp-powm-sec = prev.conf-gmp-powm-sec.overrideAttrs (attr: {
          depsBuildBuild = [ pkgs.stdenv.cc ];
        });
      };

      scope = (createScope pkgs).overrideScope' overlay;
      scopeMusl = (createScope pkgsMusl).overrideScope' overlayMusl;

      # The main package containing the executable
      main = scope.${package};
      mainMusl = scopeMusl.${package};

      # Packages from devPackagesQuery
      getOcamlDevPackages = scope:
        builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);

      getDevPackages = pkgs:
        [
          # Nix tools
          pkgs.nil
          pkgs.nixpkgs-fmt
        ];
    in
    {
      packages.default = main;
      packages.musl = mainMusl;

      formatter = pkgs.nixpkgs-fmt;

      devShells.default = pkgs.mkShell {
        inputsFrom = [ main ];
        buildInputs =
          getOcamlDevPackages scope
          ++ getDevPackages pkgs;
      };

      devShells.musl = pkgsMusl.mkShell
        {
          inputsFrom = [ mainMusl ];
          buildInputs = getOcamlDevPackages scopeMusl
            ++ getDevPackages pkgsMusl;
        };
    });
}
