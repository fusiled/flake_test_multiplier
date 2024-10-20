{
  description = "A simple multiplier library";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.adder.url = "github:fusiled/flake_test_adder";


    outputs = { self, nixpkgs, adder, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      package_name = "libmultiplier";
      pkgs = system : import nixpkgs { inherit system; };

      adder_pkg = system : adder.packages.${system}.libadder;

      derivRecipe = {system } : (pkgs(system)).stdenv.mkDerivation rec {
          pname = package_name;
          version = "0.0.1";

          src = ./.;

          nativeBuildInputs = [ adder ];
          buildInputs = [ adder ];

          buildPhase = ''
            $CXX -v -I${adder_pkg(system)}/include --std=c++11  ${adder_pkg(system)}/lib/libadder.dylib -dynamiclib -install_name $out/lib/libmultiplier.dylib  -o libmultiplier.dylib ./libmultiplier.cpp;
            echo buildstep
            otool -L ${adder_pkg(system)}/lib/libadder.dylib
            echo "$(otool -l libmultiplier.dylib | grep adder)" 
            echo "end buildstep"
        '';

        installPhase = ''
            mkdir -p $out/lib;
            mkdir -p $out/include;
            cp ./libmultiplier.dylib $out/lib/;
            cp ./libmultiplier.h $out/include;
        '';
        };

    in
    {
        packages = forAllSystems (system: {${package_name} = derivRecipe {system=system;};});
        defaultPackage = forAllSystems (system: self.packages.${system}.${package_name});
    };

}
