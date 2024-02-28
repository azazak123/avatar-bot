{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    nixpkgs.follows = "opam-nix/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self
    , opam-nix
    , nixpkgs
    , nixpkgs-unstable
    }:
    let
      package = "avatar-bot";

      systems = [
        "x86_64-linux"
      ];

      # Packages from devPackagesQuery
      getOcamlDevPackages = pkgs: scope:
        builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);

      # Ocaml development packages
      devPackagesQuery = {
        ocaml-lsp-server = "*";
        ocamlformat = "*";
      };

      # You can force versions of certain packages here
      query = devPackagesQuery // {
        ocaml-base-compiler = "*";
      };

      createScope = pkgs: on: on.buildDuneProject { pkgs = pkgs; } package ./. query;

      getDevPackages = pkgs:
        with pkgs;[
          zip

          # Nix tools
          nil
          nixpkgs-fmt
        ];

      getIbmcloud = pkgs: with pkgs;[
        # Faas provider
        ibmcloud-cli
      ];

      overlay = final: prev: {
        ${package} = prev.${package}.overrideAttrs
          (attr: {
            # Prevent the ocaml dependencies from leaking into dependent environments
            doNixSupport = false;
          });
      };

      forSystems = f:
        nixpkgs.lib.genAttrs systems
          (system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
              on = opam-nix.lib.${system};
              scope = (createScope pkgs on).overrideScope' overlay;
            in
            f system pkgs scope
          );

      getDockerImage = pkgs: pkg: pkgs.dockerTools.buildImage {
        name = package;
        tag = "latest";
        created = "now";

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [ pkg pkgs.iana-etc ];
          pathsToLink = [ "/bin" "/etc" ];
        };

        extraCommands = ''
          mkdir -p ./tmp
        '';

        config = {
          Cmd = [ "/bin/${package}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
          ExposedPorts = {
            "80/tcp" = { };
          };
        };
      };

    in
    nixpkgs.lib.recursiveUpdate
      rec {
        packages = forSystems (_: pkgs: scope:
          rec {
            default = scope.${package};
            docker = getDockerImage pkgs default;
          }
        );

        formatter = forSystems (_: pkgs: _: pkgs.nixpkgs-fmt);

        devShells = forSystems (system: pkgs: scope:
          {
            default =
              pkgs.mkShell {
                inputsFrom = [ packages.${system}.default ];
                buildInputs =
                  getOcamlDevPackages pkgs scope
                  ++ getDevPackages pkgs
                  ++ getIbmcloud nixpkgs-unstable.legacyPackages.${system};
              };
          }
        );
      }
      (
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgsMusl = pkgs.pkgsMusl;
          on = opam-nix.lib.x86_64-linux;

          overlayMusl = final: prev: {
            ${package} = prev.${package}.overrideAttrs
              (attr: {
                # Prevent the ocaml dependencies from leaking into dependent environments
                doNixSupport = false;

                buildInputs = attr.buildInputs ++ [
                  pkgs.pkgsStatic.gmp
                  pkgs.pkgsStatic.openssl
                  pkgs.pkgsStatic.libev
                ];

                buildPhase = "dune build -p avatar-bot --profile static";
              }
              );
          };

          scopeMusl =
            ((createScope pkgsMusl on).overrideScope' overlayMusl);
          mainMusl = scopeMusl.${package};
        in
        rec {
          packages.x86_64-linux.static = mainMusl;
          packages.x86_64-linux.staticDocker =
            getDockerImage pkgs packages.x86_64-linux.static;

          devShells.x86_64-linux.static = pkgsMusl.mkShell {
            inputsFrom = [ mainMusl ];
            buildInputs = getOcamlDevPackages pkgs scopeMusl
              ++ getDevPackages pkgs
              ++ getIbmcloud nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
        }
      );
}
