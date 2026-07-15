{ inputs, pkgs, ... }:

{
	services = {
		tlp = {
			enable = true;
			settings = {
				CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
			};
			pd.enable = true;
		};
	};
}
