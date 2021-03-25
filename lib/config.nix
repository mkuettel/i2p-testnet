let
  # This defines the default values and structure of the configuration
  # and what representation of it is available in the nix codenix code.
  parseConfig = { nodes ? { } , ... } @ args: args;

in {
  read = f: parseConfig (import f);
}
