{ ... }:

{
  config = {
    services.transmission = {
      enable = true;

      settings = {
        download-dir = "/mnt/data/streetwalrus/torrents";
        incomplete-dir-enabled = false;
        rename-partial-files = false;
        umask = 18;

        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
        rpc-host-whitelist-enabled = false;

        download-queue-size = 6;
        speed-limit-up-enabled = true;
        speed-limit-up = 3400;
        peer-limit-global = 1024;
        peer-limit-per-torrent = 180;
        upload-slots-per-torrent = 6;
      };

      # TODO run as dedicated user
      user = "novenary";
      group = "novenary";
      downloadDirPermissions = "755";

      openRPCPort = true;
      openPeerPorts = true;
      settings.port-forwarding-enabled = false;
    };

    systemd.services.transmission = {
      after = [ "mnt-data.mount" ];
    };
  };
}
