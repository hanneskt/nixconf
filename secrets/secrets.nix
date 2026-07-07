let
  # users
  hannes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf";

  # machines
  frost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVm/ig/PgoetxxWvGgtxXLSFBPDsK9zq322/GLZFiWS";

  allKeys = [
    hannes
    frost
  ];

  secrets = [
    "pocket-id.env.age"
    "wakapi.env.age"
    "tududi.env.age"
    "silverbullet.env.age"
    "vikunja.env.age"
    "homepage.env.age"
    "mealie.env.age"
  ];
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = {
      publicKeys = allKeys;
    };
  }) secrets
)
