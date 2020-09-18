{

  packageOverrides = defaultPkgs: with defaultPkgs; {
    home = with pkgs; buildEnv {
      name = "localDev";
      paths = [
        git
        vagrant
        ack
        powerline-go
        powerline-fonts
        direnv
        gnumake
        htop
        go-1.15.1
	tree
      ];
    };
  };

}
