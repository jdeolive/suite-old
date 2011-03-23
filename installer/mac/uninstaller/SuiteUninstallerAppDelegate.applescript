--
--  SuiteUninstallerAppDelegate.applescript
--  SuiteUninstaller
--
--  Created by Paul Ramsey on 10-05-12.
--  Copyright 2010 __MyCompanyName__. All rights reserved.
--

script SuiteUninstallerAppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property textField : missing value
	property quitButton : missing value
	property uninstallButton : missing value
	property appWindow : missing value
	
	-- IBActions
	on startUninstall_(sender)
		set msg to "no"
		set uninstall to "/opt/opengeo/suite/suite_uninstall.sh"
		-- See if the script exists
		tell application "Finder"
			if exists uninstall as POSIX file then
				set msg to "yes"
			else
				textField's setString_("Unable to find uninstall script: " & uninstall)
				uninstallButton's setEnabled_(false)
			end if
		end tell
		-- If it does, run it with admin priv
		if msg is "yes" then
			textField's setString_("Starting un-install process...")
			set uninstall_result to do shell script "/bin/bash " & uninstall & " quiet" with administrator privileges
			uninstallButton's setEnabled_(false)
			textField's setString_(uninstall_result)
		end if
	end startUninstall_
	
	on quitApplication_(sender)
		quit
	end quitApplication_
	
	on awakeFromNib()
		textField's setString_("Uninstalling the OpenGeo Suite will remove the application programs, configuration and all data files.

Click \"Uninstall\" to begin.")
		textField's setEditable_(false)
		textField's setTextContainerInset_({8.0, 8.0})
		appWindow's setInitialFirstResponder_(quitButton)
	end awakeFromNib
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script