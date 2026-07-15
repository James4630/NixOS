{
	programs.firefox.profiles.main.userChrome = ''
		@-moz-document url("chrome://browser/content/browser.xhtml") {
		  /*
		   * Clear every layer behind the tab strip.
		   *
		   * Firefox's current browser window consists of an HTML root/body,
		   * followed by navigator-toolbox, TabsToolbar and several inner
		   * tab-strip containers.
		   */
		  :root,
		  :root > body,
		  #main-window,
		  #navigator-toolbox,
		  #toolbar-menubar,
		  #TabsToolbar,
		  #TabsToolbar > .toolbar-items,
		  #TabsToolbar-customization-target,
		  #tabbrowser-tabs,
		  #tabbrowser-arrowscrollbox,
		  #tabbrowser-arrowscrollbox-periphery {
		    background-color: transparent !important;
		    background-image: none !important;
		    box-shadow: none !important;
		    border-color: transparent !important;
		  }

		  /*
		   * Firefox themes can place their frame image/color on body or
		   * navigator-toolbox. Explicitly defeat those theme-specific rules.
		   */
		  :root[lwtheme] > body,
		  :root[lwtheme] #navigator-toolbox,
		  :root[lwtheme-image] > body,
		  :root[lwtheme-image] #navigator-toolbox {
		    background-color: transparent !important;
		    background-image: none !important;
		  }

		  /*
		   * Keep the URL/navigation bar opaque.
		   */
		  #nav-bar,
		  #PersonalToolbar {
		    background-color: rgb(24 24 28 / 0.96) !important;
		    background-image: none !important;
		    box-shadow: none !important;
		  }

		  /*
		   * Give Firefox an opaque backing behind web content, preventing
		   * transparent flashes while pages load.
		   */
		  #browser,
		  #appcontent,
		  .browserContainer {
		    background-color: rgb(24 24 28) !important;
		  }

		  /*
		   * Tabs themselves.
		   */
		  .tabbrowser-tab .tab-background {
		    background-color: transparent !important;
		    background-image: none !important;
		    box-shadow: none !important;
		    outline: none !important;
		  }

		  .tabbrowser-tab:hover .tab-background {
		    background-color: rgb(35 35 42 / 0.30) !important;
		  }

		  .tabbrowser-tab[selected] .tab-background {
		    background-color: rgb(35 35 42 / 0.50) !important;
		  }
		}

		/*
		 * High-contrast tab titles.
		 */
		.tabbrowser-tab .tab-label {
		  color: rgb(255 255 255 / 0.98) !important;
		  font-weight: 500 !important;

		  text-shadow:
		    0 1px 2px rgb(0 0 0 / 1),
		    0 0 5px rgb(0 0 0 / 0.9) !important;
		}

		/*
		 * Add shadows to favicons and close buttons too.
		 */
		.tabbrowser-tab .tab-icon-image,
		.tabbrowser-tab .tab-close-button {
		  filter: drop-shadow(0 1px 2px rgb(0 0 0 / 0.9));
		}

		/*
		 * Dark translucent scrim behind each tab.
		 */
		.tabbrowser-tab:not([selected]) .tab-background {
		  background-color: rgb(0 0 0 / 0.08) !important;
		}

		.tabbrowser-tab:hover .tab-background {
		  background-color: rgb(0 0 0 / 0.18) !important;
		}

		.tabbrowser-tab[selected] .tab-background {
		  background-color: rgb(0 0 0 / 0.20) !important;
		}
	'';
}
