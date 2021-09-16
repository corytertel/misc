{
  description = "Standard C++ Project Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_latest;
          lib = nixpkgs.lib;

        in
          {
            devShell = pkgs.mkShell {
              nativeBuildInputs = [
                # builder
                # p.gnumake
                # p.bear
                pkgs.cmake
                pkgs.cmakeCurses
                # debugger
                llvm.lldb

                # XXX: the order of include matters
                pkgs.clang-tools
                llvm.clang # clangd

                pkgs.gtest

                pkgs.ncurses
              ];

              buildInputs = [
                # stdlib for cpp
                llvm.libcxx
              ];

              # CXXFLAGS = "-std=c++17";
              CPATH = builtins.concatStringsSep ":" [
                (lib.makeSearchPathOutput "dev" "include" [ llvm.libcxx ])
                (lib.makeSearchPath "resource-root/include" [ llvm.clang ])
              ];

              shellHook = let
                icon = "f121";
                triangle = "E0B0";
              in ''
                export DEBUG_FLAGS="\
                -g3 \
                -pthread \
                -gdwarf-4 \
                -fPIC \
                -Wno-deprecated \
                -pipe \
                -fno-elide-type \
                -fdiagnostics-show-template-tree \
                -Wall \
                -Wextra \
                -Werror \
                -Wpedantic \
                -Wvla \
                -Wextra-semi \
                -Wnull-dereference \
                -Wswitch-enum \
                -Wsuggest-override \
                -O \
                -MMD \
                -MP \
                -Wno-gnu-include-next \
                -Wno-unused-variable \
                -Wno-unused-parameter"

                # Usage: mycmake -B . -S ../
                alias mycmake='cmake \
                -DCMAKE_C_COMPILER=clang \
                -DCMAKE_CXX_COMPILER=clang++ \
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
                -DCMAKE_CXX_FLAGS_ALL_WARNINGS:STRING="$DEBUG_FLAGS" \
                -DCMAKE_BUILD_TYPE=ALL_WARNINGS'

                # Usage: myclang-tidy -p build main.cpp
                alias myclang-tidy="clang-tidy \
                --checks=-*,\
                boost-*,\
                bugprone-*,\
                clang-analyzer-*,\
                concurrency-*,\
                cppcoreguidelines-*,\
                misc-*,\
                modernize-*,\
                performance-*,\
                portability-*,\
                readability-* \
                -header-filter=.*"

                # Usage: mycppcheck main.cpp
                alias mycppcheck="cppcheck --enable=all --std=c++20"

                #export PS1="$(echo -e '\u${icon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} \\$ \[$(tput sgr0)\]"
                export PS1="\n\[\033[1;42;97m\] DEV $(echo -e '\u${icon}') \w \[\033[0m\]\[\033[1;32m\]$(echo -e '\u${triangle}')\[\033[0m\] \[$(tput sgr0)\]"
              '';
            };
          }
    );
}

