{ pkgs
, package
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
    };
  };

  testScript = ''
    start_all()

    with subtest('connect to server'):
      client.wait_for_unit('default.target');
      server.wait_for_unit('server.service');
      assert 'lightning' in client.succeed('curl http://server:3000/pets/1')
  '';
}
