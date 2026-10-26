{
  runCommand,
  lean,
  clang,
  bendPackage,
}:
runCommand "bendtt-2.0.39"
  {
    nativeBuildInputs = [
      lean
      clang
    ];
    LEAN_CC = "${clang}/bin/clang";
  }
  ''
    cp ${bendPackage}/libexec/bend/bend2/bendtt.lean bendtt.lean
    lean -c bendtt.c bendtt.lean
    mkdir -p $out/bin
    leanc -O3 -DNDEBUG bendtt.c -o $out/bin/bendtt
  ''
