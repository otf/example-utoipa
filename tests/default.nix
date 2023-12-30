{ pkgs
, package
, test-package
}:

{
  name = "System test of utoipa & axum";
  nodes = {
    server = {
      systemd.services.server = {
        wantedBy = [ "multi-user.target" ];
        script = "${package}/bin/example-utoipa";
      };
      networking.firewall.enable = false;
    };
    client = {
      environment.systemPackages = [
        test-package
      ];
    };
  };

  testScript = ''
    start_all()

    with subtest('connect to server'):
      client.wait_for_unit('default.target');
      server.wait_for_unit('server.service');
      client.succeed('nodejs-client');
  '';
}
