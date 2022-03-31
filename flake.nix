{
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system':
      let
        system = if system' == "aarch64-darwin" then "x86_64-darwin" else system';
        name = "haskell-nix-playground";
        pkgs = import nixpkgs {
          inherit system;
          inherit (haskellNix) config;
          overlays = [ haskellNix.overlay ];
        };
        index-state = "2022-03-29T00:00:00Z";
        mkProjects = { checkMaterialization ? false }:
          let
            tools = pkgs.lib.mapAttrs
              (name: value: value // {
                inherit index-state checkMaterialization;
                materialized = ./materializations/${name};
              })
              {
                cabal = {
                  plan-sha256 = "12sfwppv9q043jvkmq9zjiw54nv5dhbqwqidj12sz8k59x5sm5rj";
                };
                haskell-language-server = {
                  plan-sha256 = "0aqa6cpgyflcfv6j8rlan14bnl94y8b7gjg0n3vsvph82qpccmmz";
                };
                hoogle = {
                  plan-sha256 = "1di5g5g1ajfirr8cj9ymvi2l10c56fcw73n9xdasmkhkcwrrnh16";
                };
              };
            project =
              pkgs.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc8107";
                shell = {
                  buildInputs = with pkgs; [
                    nixpkgs-fmt
                  ];
                  inherit tools;
                };
                plan-sha256 = "09lrd54jdf3mdzjq5icg2irkh9zrw5wpw5s5amxwj4n03nnmbgr5";
                materialized = ./materializations/${name};
                inherit index-state checkMaterialization;
              };
          in
          ({ ${name} = project; } // pkgs.lib.mapAttrs (_: tool: tool.project) (project.tools tools));
        projects = mkProjects { };
        flake = projects.${name}.flake {
          crossPlatforms = p: [ p.ghcjs ];
        };
      in
      flake // rec {
        defaultPackage = flake.packages."haskell-nix-playground:exe:haskell-nix-playground-app";
        packages = flake.packages // {
          materializer = pkgs.writeShellScript "${name}-materialize" (builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList
            (name: project: ''
              echo ${name}:
              echo plan-sha256 = \"$(${project.plan-nix.passthru.calculateMaterializedSha})\"
              ${project.plan-nix.passthru.generateMaterialized} ./materializations/${name}
              echo
            '')
            projects));
          checkMaterialization =
            let
              projects' = mkProjects { checkMaterialization = true; };
              dummyDrv = pkgs.writeTextFile {
                name = "checkMaterialization";
                text = "Success checkMaterialization";
              };
            in
            pkgs.lib.foldr builtins.seq dummyDrv (pkgs.lib.attrValues projects');
        };
        defaultApp = {
          type = "app";
          program = "${defaultPackage}/bin/haskell-nix-playground-app";
        };
        apps = flake.apps // {
          materialize = {
            type = "app";
            program = "${packages.materializer}";
          };
        };
      }
    );
}
