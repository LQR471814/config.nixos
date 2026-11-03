self: super:
let
  # this wrapper fixes GUI issues when running UIs as sudo
  fixSudoGui = (
    pkg: flags:
    super.stdenv.mkDerivation {
      name = pkg.name + "-sudo-gui";

      buildInputs = [
        pkg
        super.xhost
      ];

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        for file in ${pkg}/bin/*; do
          if [ -f "$file" ]; then
            printf "${super.lib.getExe' super.xhost "xhost"} +SI:localuser:root\n${super.lib.getExe' super.lxqt.lxqt-sudo "lxqt-sudo"} '$file' ${flags}" | tee "$out/bin/$(basename "$file")"
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
    version = "0.1";

    src = self.fetchFromGitHub {
      owner = "kolunmi";
      repo = "sandbar";
      rev = "51887cee0a2cea8cf0aba2d81442b75403485e1c";
      hash = "sha256-lUiDdmcu/CYe8hEWoUX+bM1cDy/590TvRgfLO6Ry6Vk=";
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
  wireshark = fixSudoGui super.wireshark "";
  gparted = fixSudoGui super.gparted "";
  gnome-disks = fixSudoGui super.gnome-disks "";
  # virt-manager = fixSudoGui super.virt-manager "";
}
