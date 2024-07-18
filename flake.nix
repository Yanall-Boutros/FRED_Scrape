{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            cudaPackages.cuda_nvrtc
            cudaPackages.cudnn
            cudaPackages.cutensor
            cudaPackages.cudatoolkit
            python311Packages.torch-bin
            python311Packages.torchaudio-bin
            python311Packages.progressbar
            python311Packages.einops
            python311Packages.librosa
            python311Packages.unidecode
            python311Packages.inflect
            python311Packages.rotary-embedding-torch
            python311Packages.safetensors
            python311Packages.transformers
          ];
          inputsFrom = [ 
            pkgs.cudaPackages.cuda_nvrtc
            pkgs.cudaPackages.libcusparse
            pkgs.cudaPackages.cudatoolkit
            self.packages.${system}.myapp
          ];
          # https://nixos.wiki/wiki/Tensorflow
          shellHook = ''
                export LD_LIBRARY_PATH=${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudatoolkit.lib}/lib:$LD_LIBRARY_PATH
                unset SOURCE_DATE_EPOCH
          '';
        };
    });
}
