# /boot Partition Filled

Observed symptom was a failed rebuild switch, no space left on device.

## Diagnosis

```shell
$ df -h
... <snipped> /boot at 100% ...
```

## Intervention

To recover, prune old generations and sync /boot:

```shell
$ sudo nix-collect-garbage --delete-older-than 28d
$ cdh
$ sudo nixos-rebuild boot --flake .#s1
```

## Future Prevention

Auto gc schedule established:

```shell
nix = {
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 28d";
  };
};
```

