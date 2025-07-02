self: super: {
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
}
