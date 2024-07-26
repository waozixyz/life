{ pkgs, ... }:

{
  packages = [
    pkgs.tcl
    pkgs.tk
    pkgs.tcllib
  ];

  scripts = {
    run-tcl.exec = "tclsh main.tcl";
  };


  enterShell = ''
    echo "Environment set up. You can use the following commands:"
    echo "  run-tcl      : Run the Tcl version"
    echo ""
  '';
}
