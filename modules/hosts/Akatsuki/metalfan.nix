{ lib, config, ... }:

{
  config = lib.mkIf (config.networking.hostName == "Akatsuki") {
    # TODO https://bugzilla.kernel.org/show_bug.cgi?id=204807
    boot.kernelModules = [ "nct6775" ];
    boot.kernelParams = [ "acpi_enforce_resources=lax" ];

    services.metalfan = {
      enable = true;

      config = {
        interval = 1;

        hwmons = {
          cpu = {
            path = "/sys/bus/pci/drivers/k10temp/0000:*/hwmon/hwmon*";
            probes = [ "temp1" ];
          };
          superio = {
            path = "/sys/devices/platform/nct6775.656/hwmon/hwmon*";
          };
          gpu = {
            path = "/sys/bus/pci/drivers/amdgpu/0000:0b:00.0/hwmon/hwmon*";
            probes = [ "temp1" ];
          };
        };

        fangroups = [
          # CPU
          {
            probe = "cpu/temp1";
            temp_min = 60;
            temp_max = 105;
            speed = [ "superio/fan2" ];
            pwm = [ "superio/pwm2" ];
            pwm_stop = 93;
            pwm_min = 93;
            pwm_max = 255;
          }

          # GPU
          {
            probe = "gpu/temp1";
            temp_min = 50;
            temp_max = 90;
            speed = [ "gpu/fan1" ];
            pwm = [ "gpu/pwm1" ];
            pwm_stop = 31;
            pwm_min = 31;
            pwm_max = 100;
          }

          # Case fans
          {
            probe = "gpu/temp1";
            temp_min = 62;
            temp_max = 90;
            speed = [ "superio/fan3" "superio/fan4" ];
            speed_min = 310;
            pwm = [ "superio/pwm3" "superio/pwm4" ];
            pwm_stop = 60;
            pwm_start = 80;
            pwm_min = 80;
            pwm_max = 204;
            pwm_fixed = 90;
          }

          # Chipset fan
          {
            pwm = [ "superio/pwm5" ];
            pwm_fixed = 102;
          }

          # PSU fan
          {
            pwm = [ "superio/pwm1" ];
            pwm_fixed = 90;
          }
        ];
      };
    };
  };
}
