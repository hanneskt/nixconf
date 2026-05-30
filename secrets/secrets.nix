let
  # users
  hannes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf";

  # machines
  frost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVm/ig/PgoetxxWvGgtxXLSFBPDsK9zq322/GLZFiWS";
in
{
  "pocket-id.env.age".publicKeys = [
    hannes
    frost
  ];
  "wakapi.env.age".publicKeys = [
    hannes
    frost
  ];
  "tududi.env.age".publicKeys = [
    hannes
    frost
  ];
  "silverbullet.env.age".publicKeys = [
    hannes
    frost
  ];
  "vikunja.env.age".publicKeys = [
    hannes
    frost
  ];
  "homepage.env.age".publicKeys = [
    hannes
    frost
  ];
}
