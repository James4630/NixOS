{ inputs, pkgs, ... }:

{
	services.tlp.settings = {
		START_CHARGE_THRESH_BAT0 =  50;
		STOP_CHARGE_THRESH_BAT0 = 75;

		START_CHARGE_THRESH_BAT1 = 60;
		STOP_CHARGE_THRESH_BAT1 = 85;
	};
}
