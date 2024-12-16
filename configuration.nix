# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
			<home-manager/nixos>
		];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nixos"; # Define your hostname.
	# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	# Set your time zone.
	time.timeZone = "Europe/Belgrade";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	# Enable the X11 windowing system.
	services.xserver.enable = true;

	# Enable the GNOME Desktop Environment.
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;

	# Configure keymap in X11
	services.xserver.xkb = {
		layout = "us";
		variant = "mac";
	};

	# Set the cursor theme and size
	environment.variables = {
		XCURSOR_THEME = "GoogleDot-Black";
		XCURSOR_SIZE = "24";
	};

	# Enable CUPS to print documents.
	services.printing.enable = false;

	# Enable sound with pipewire.
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	# Disable some problematic systemd servicess
	systemd.services.prlshprint.wantedBy = lib.mkForce [];

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		alacritty
		alacritty-theme
		atool
		bat
		fd
		git
		gnomeExtensions.toggle-alacritty
		go
		google-cursor
		home-manager
		httpie
		lsd
		micro
		nerdfonts
		ripgrep
		vscodium
		wget
		xclip
		zsh
		zsh-powerlevel10k
	];

	# Configure default settings for all users
	users.defaultUserShell = pkgs.zsh;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.pamburus = {
		isNormalUser = true;
		description = "pamburus";
		extraGroups = [ "networkmanager" "wheel" ];
		shell = pkgs.zsh;
		packages = with pkgs; [];
	};

	# Install firefox.
	programs.firefox.enable = true;

	# Install zsh
	programs.zsh = {
		enable = true;
		enableCompletion = true;
		syntaxHighlighting.enable = true;
		shellAliases = {
			ll = "lsd -lah";
			update = "sudo nixos-rebuild switch";
			pbcopy = "xclip -selection clipboard";
			pbpaste = "xclip -selection clipboard -o";
		};
		ohMyZsh = {
			enable = true;
			plugins = [ "git" ];
			theme = "robbyrussell";
		};
	};

	# Configure hl
	environment.etc."hl/config.json".text = builtins.toJSON {
		theme = "tc24d-b2";
	};

	# Configure micro
	environment.etc."micro/settings.json".text = builtins.toJSON {
		hltaberrors = true;
		hltrailingws = true;
		rmtrailingws = true;
	};

	# Install micro plug-ins
	environment.etc."micro/plug/detectindent" = {
		source = pkgs.fetchFromGitHub {
			owner = "dmaluka";
			repo = "micro-detectindent";
			rev = "v1.1.0";
			sha256 = "sha256-5bKEkOnhz0pyBR2UNw5vvYiTtpd96fBPTYW9jnETvq4=";
		};
	};

	# Enable the gnome-keyring secrets vault.
	# Will be exposed through DBus to programs willing to store secrets.
	services.gnome.gnome-keyring.enable = true;

	security.polkit.enable = true;

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.11"; # Did you read the comment?

	home-manager.users.root = { lib, pkgs, ... }: {
		# The state version is required and should stay at the version you
		# originally installed.
		home.stateVersion = "24.11";

		imports = [ ./home-manager-common.nix ];
	};

	home-manager.users.pamburus = { lib, pkgs, ... }: {
		# The state version is required and should stay at the version you
		# originally installed.
		home.stateVersion = "24.11";

		imports = [ ./home-manager-common.nix ];

		# Configure VS Code
		programs.vscode = {
			enable = true;
			package = pkgs.vscodium;
			extensions = with pkgs.vscode-extensions; [
				dracula-theme.theme-dracula
				golang.go
				yzhang.markdown-all-in-one
			];
		};

		programs.zsh = {
			enable = true;
			plugins = [
				{
					name = "powerlevel10k";
					src = pkgs.zsh-powerlevel10k;
					file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
				}
				# {
				# 	name = "powerlevel10k-config";
				# 	src = ./p10k-config;
				# 	file = "p10k.zsh";
				# }
			];
		};
	};
}
