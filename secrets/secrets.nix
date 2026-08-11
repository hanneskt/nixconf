let
  # Users
  hannes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf";

  # Machines
  frost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVm/ig/PgoetxxWvGgtxXLSFBPDsK9zq322/GLZFiWS";
  puk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwXwQRCvPPqhIXPrrttY4cLmoTRC/66b8LovMeLwU4o";

  mkSecrets =
    machineKey: secretFiles:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = {
          publicKeys = [
            hannes
            machineKey
          ];
        };
      }) secretFiles
    );

in
mkSecrets frost [
  "betalog.env.age"
  "pocket-id.env.age"
  "wakapi.env.age"
  "tududi.env.age"
  "silverbullet.env.age"
  "vikunja.env.age"
  "homepage.env.age"
  "mealie.env.age"
]
// mkSecrets puk [
  "dawarich.env.age"
  "paperless.env.age"
  "sure.env.age"
  "floppy.env.age"
  "immich-oauth-secret.age"
]
