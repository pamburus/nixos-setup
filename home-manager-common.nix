{ config, lib, pkgs, ... }:
{
	dconf.settings = {
		"org/gnome/desktop/peripherals/keyboard" = {
			delay = lib.hm.gvariant.mkUint32 250;
			repeat-interval = lib.hm.gvariant.mkUint32 25;
			repeat = true;
		};
	};

	# Configure zsh
	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;
	};

	# Configure git
	programs.git = {
		enable = true;
		extraConfig = {
			push = { autoSetupRemote = true; };
			init = { defaultBranch = "main"; };
			safe = { directory = "/etc/nixos"; };
		};
	};

	# Configure Alacritty
	programs.alacritty = {
		enable = true;
		settings = {
			mouse = { hide_when_typing = false; };
			cursor = {
				style = {
					shape = "Beam";
					blinking = "On";
				};
			};
			colors = {
				cursor = {
					text = "CellBackground";
					cursor = "#d17277";
				};
			};
			font = {
				normal = {
					family = "LiterationMono Nerd Font Mono";
					style = "Regular";
				};
				bold = {
					style = "Bold";
				};
				italic = {
					style = "Italic";
				};
				size = 10;
			};
		};
	};

	# Configure micro
	home.file.".config/micro/settings.json".text = builtins.toJSON {
		hltaberrors = true;
		hltrailingws = true;
		rmtrailingws = true;
		tabsize = 4;
		"*.nix" = {
			tabsize = 2;
		};
	};
	home.file.".config/micro/plug" = {
		source = "/etc/micro/plug";
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
