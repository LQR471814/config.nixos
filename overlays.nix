self: super:
let
  # this wrapper fixes GUI issues when running UIs as sudo
  fixSudoGui = (
    pkg: flags:
    super.stdenv.mkDerivation {
      name = pkg.name + "-sudo-gui";

      buildInputs = [
        pkg
        super.xorg.xhost
      ];

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        for file in ${pkg}/bin/*; do
          if [ -f "$file" ]; then
            printf "${super.xorg.xhost}/bin/xhost +SI:localuser:root\n${super.lxqt.lxqt-sudo}/bin/lxqt-sudo '$file' ${flags}" | tee "$out/bin/$(basename "$file")"
            chmod +x "$out/bin/$(basename "$file")"
          fi
        done
      '';
    }
  );
in
{
  sandbar = super.stdenv.mkDerivation {
    name = "sandbar";
    version = "0.2";

    src = self.fetchFromGitHub {
      owner = "kolunmi";
      repo = "sandbar";
      rev = "e64a8b788d086cdf4ec44b51e62bdc7b6b5f8165";
      hash = "sha256-dNYYlm5CEdnvLjskrPJgquptIQpYgU+gxOu+bt+7sbw=";
    };

    strictDeps = true;

    nativeBuildInputs = with self; [ pkg-config ];

    buildInputs = with self; [
      wayland-scanner
      wayland-protocols
      wayland
      pixman
      fcft
    ];

    makeFlags = [ "PREFIX=$(out)" ];
  };

  arduino-ide = fixSudoGui super.arduino-ide "--no-sandbox";
}
