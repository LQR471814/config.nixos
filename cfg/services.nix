_: {
  services.searx = {
    enable = true;
    settings = {
      server.port = 8585;
      server.bind_address = "127.0.0.1";
      server.secret_key = "extremely secret key";
      search = {
        safe_search = 1;
        default_lang = "en";
        formats = [
          "html"
          "json"
        ];
      };
      engines = [
        {
          name = "wikidata";
          engine = "wikidata";
          disabled = true;
        }
      ];
    };
  };

  services.suwayomi-server = {
    enable = true;
    settings.server.port = 7754;
  };
}
