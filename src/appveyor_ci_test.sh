set -e
set -x

opam init -y --auto-setup
eval `opam config env`

ocamlc -version

# Install dependencies.
opam pin add -y --no-action bisect_ppx .
opam pin add -y --no-action bisect_ppx-ocamlbuild .
opam install -y --deps-only bisect_ppx bisect_ppx-ocamlbuild

# Additional dependencies for testing.
opam install -y ounit ppx_blob

# ppx_deriving appears broken on Cygwin:
#   https://ci.appveyor.com/project/aantron/bisect-ppx/build/7/job/dkt61kjpqm4ahlvh#L246
if [ "$SYSTEM" != cygwin ]
then
  opam install -y ppx_deriving
fi

# Build and test.
make build

make test
make usage
make performance

# Test installation.
make clean
opam install -y bisect_ppx bisect_ppx-ocamlbuild
ocamlfind query bisect_ppx
