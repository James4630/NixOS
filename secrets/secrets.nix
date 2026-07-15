let
  james-iconoclast = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2Tw+9qYmBVn3QKJIHX5zAFmnFPyzCrMF6gdcU+4v6A";
  users = [ james-iconoclast ];

  iconoclast = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzMHUXe1o29/bMY+TIAEa3nuUGlacee7I8/7G7BFB6u";
  systems = [ iconoclast ];
in
{
  "wg_fritzbox.age".publicKeys = [ james-iconoclast iconoclast ];
}
