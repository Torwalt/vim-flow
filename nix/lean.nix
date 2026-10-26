{
  lib,
  stdenv,
  fetchurl,
  zstd,
  autoPatchelfHook,
  zlib,
  gmp,
  libuv,
  libxml2,
  ncurses,
}:
let
  version = "4.34.0";
  archives = {
    x86_64-linux = {
      target = "linux";
      sha256 = "caaa98356098c85dc0fcbbd28e1ec66f39eb6551829972b752ff20e1286b646b";
    };
    aarch64-linux = {
      target = "linux_aarch64";
      sha256 = "40b04fdb7fb849d3c80e10c3bbeebc7b7354b6d3f07450b9168c2149b40d2a82";
    };
    x86_64-darwin = {
      target = "darwin";
      sha256 = "e90afe84c0a2aa3583f3ecd08e51fb7eeebb84d36f99b7cac5d3c067fa8640b0";
    };
    aarch64-darwin = {
      target = "darwin_aarch64";
      sha256 = "69f263fa6e21bbc2466bbfb1affcd92479ee2714c883a07de548e099a5922932";
    };
  };
  archive = archives.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "lean4-bin";
  inherit version;
  src = fetchurl {
    url = "https://github.com/leanprover/lean4/releases/download/v${version}/lean-${version}-${archive.target}.tar.zst";
    inherit (archive) sha256;
  };
  nativeBuildInputs = [ zstd ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    gmp
    libuv
    libxml2
    ncurses
  ];
  dontBuild = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';
  meta = {
    description = "Lean version required by Bend 2.0.39's formalized kernel";
    homepage = "https://github.com/leanprover/lean4";
    license = lib.licenses.asl20;
    mainProgram = "lean";
    platforms = builtins.attrNames archives;
  };
}
