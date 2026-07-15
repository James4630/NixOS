{
  lib,
  stdenv,
  src,

  pkg-config,
  makeWrapper,
  wrapGAppsHook4,

  glib,
  glib-networking,
  gvfs,
  gdk-pixbuf,
  gtk4,
  gtk4-layer-shell,
  libpulseaudio,

  coreutils,
  gnused,
  procps,
  which,
}:

stdenv.mkDerivation {
  pname = "hyprwave";
  version = "1.0";

  inherit src;

  strictDeps = true;
  dontConfigure = true;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    glib-networking
    gvfs
    gdk-pixbuf
    gtk4
    gtk4-layer-shell
    libpulseaudio
  ];

  postPatch = ''
    patchShebangs hyprwave-toggle.sh

    substituteInPlace paths.c \
      --replace-fail "/usr/share/hyprwave" "$out/share/hyprwave"

    substituteInPlace hyprwave-toggle.sh \
      --replace-fail "/usr/share/hyprwave" "$out/share/hyprwave"

    substituteInPlace hyprwave-toggle.sh \
      --replace-fail \
        'pgrep -x hyprwave 2>/dev/null' \
        'pgrep -f "(^|/)[.]?hyprwave(-wrapped)?([[:space:]]|$)" 2>/dev/null | head -n 1' \
      --replace-fail \
        'if pgrep -x hyprwave > /dev/null; then' \
        'if [ -n "$(get_hyprwave_pid)" ]; then'
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 hyprwave \
      "$out/bin/hyprwave"

    install -Dm755 hyprwave-toggle.sh \
      "$out/bin/hyprwave-toggle"

    install -Dm644 style.css \
      "$out/share/hyprwave/style.css"

    install -Dm644 style-layout.css \
      "$out/share/hyprwave/style-layout.css"

    install -Dm644 config.conf \
      "$out/share/hyprwave/config.conf"

    mkdir -p \
      "$out/share/hyprwave/icons" \
      "$out/share/hyprwave/themes"

    cp icons/*.svg "$out/share/hyprwave/icons/"
    cp themes/*.css "$out/share/hyprwave/themes/"

    install -Dm644 fonts/VT323-Regular.ttf \
      "$out/share/fonts/truetype/VT323-Regular.ttf"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GIO_EXTRA_MODULES : "${gvfs}/lib/gio/modules"
    )
  '';

  postFixup = ''
    # hyprwave-toggle invokes pgrep, sed, which, cat, sleep, etc.
    wrapProgram "$out/bin/hyprwave-toggle" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnused
          procps
          which
        ]
      }
  '';

  meta = {
    description = "Music control bar for Wayland compositors";
    homepage = "https://github.com/shantanubaddar/hyprwave";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "hyprwave";
  };
}
