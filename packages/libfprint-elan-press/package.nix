{
  libfprint,
  fetchFromGitLab,
  opencv,
  doctest,
  python3,
}:

libfprint.overrideAttrs (old: {
  version = "1.94.10-unstable-2026-04-05";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "Tooniis";
    repo = "libfprint";
    rev = "bed05d2926c35f6d3c38fb59d8753b5480735b16";
    hash = "sha256-hPyZVciGUC77vJzhQGW6DK6pVQfVyOpeoiPmEtCUaPc=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [
    (python3.withPackages (ps: [ ps.pygobject3 ]))
  ];

  patches = (old.patches or [ ]) ++ [
    ./elan-press-capture.patch
    ./elan-disable-overheat.patch
  ];

  buildInputs = old.buildInputs ++ [
    opencv
    doctest
  ];

  postPatch = ''
    patchShebangs \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/virtual-device.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh
  '';

  doInstallCheck = false;
})
