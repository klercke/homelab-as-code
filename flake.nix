{
  description = "HLAC IaC environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    formatter = forEachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (self.checks.${system}.pre-commit-check) config;
        inherit (config) package configFile;
        script = ''
          ${pkgs.lib.getExe package} run --all-files --config ${configFile}
        '';
      in
        pkgs.writeShellScriptBin "pre-commit-run" script
    );

    checks = forEachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        checkSops = pkgs.writeShellApplication {
          name = "check-sops";
          runtimeInputs = [pkgs.gnugrep];
          text = ''
            fail=0
            for f in "$@"; do
              if ! grep -q '^sops:' "$f"; then
                echo "UNENCRYPTED: $f" >&2
                fail=1
                continue
              fi
              n=$(grep -c 'recipient:' "$f")
              if [ "$n" -ne 3 ]; then
                echo "WRONG RECIPIENT COUNT ($n, want 3): $f" >&2
                fail=1
              fi
            done
            exit "$fail"
          '';
        };

        noAgeKeys = pkgs.writeShellApplication {
          name = "no-age-keys";
          runtimeInputs = [pkgs.gnugrep];
          text = ''
            if grep -lE 'AGE-SECRET-KEY-1[0-9A-Z]{50,}' "$@"; then
              echo "age private key found in staged files" >&2
              exit 1
            fi
          '';
        };
      in {
        pre-commit-check = inputs.git-hooks.lib.${system}.run {
          package = nixpkgs.legacyPackages.${system}.prek;
          src = ./.;
          hooks = {
            terraform-format.enable = true;
            terraform-validate.enable = true;
            tflint.enable = true;

            check-yaml = {
              enable = true;
              excludes = ["^secrets/"];
            };

            check-added-large-files.enable = true;

            end-of-file-fixer = {
              enable = true;
              excludes = ["^secrets/"];
            };

            trim-trailing-whitespace = {
              enable = true;
              excludes = ["^secrets/"];
            };

            sops-encrypted = {
              enable = true;
              name = "secrets are sops-encrypted";
              entry = pkgs.lib.getExe checkSops;
              language = "system";
              files = "^secrets/.*\\.sops\\.yaml$";
              pass_filenames = true;
            };

            no-age-private-keys = {
              enable = true;
              name = "no age private keys in repo";
              entry = pkgs.lib.getExe noAgeKeys;
              language = "system";
              types = ["text"];
              pass_filenames = true;
            };

            yamllint = {
              enable = true;
              files = "^registries/.*\\.ya?ml$";
            };
          };
          rawConfig = {
            repos = [
              {
                "repo" = "https://github.com/antonbabenko/pre-commit-terraform";
                "rev" = "v1.96.2";
                "hooks" = [
                  {
                    "id" = "terraform_docs";
                    "name" = "Terraform docs";
                    "require_serial" = true;
                  }
                ];
              }
              {
                "repo" = "https://github.com/python-jsonschema/check-jsonschema";
                "rev" = "0.33.0";
                "hooks" = [
                  {
                    "id" = "check-jsonschema";
                    "files" = "^registries/vlans\.yaml$";
                    "args" = ["--schemafile" "registries/schemas/vlans.json"];
                  }
                ];
              }
            ];
          };
        };
      }
    );

    devShells = forEachSystem (system: {
      default = let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
      in
        pkgs.mkShell {
          inherit shellHook;
          buildInputs =
            [
              pkgs.python313
              pkgs.opentofu
              pkgs.terraform-docs
              pkgs.tflint
              pkgs.sops
              pkgs.age
              pkgs.openssl
              pkgs.ansible
            ]
            ++ enabledPackages;
        };
    });
  };
}
