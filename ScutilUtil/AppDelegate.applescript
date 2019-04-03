--
--  AppDelegate.applescript
--  ScutilUtil
--
--  Created by John Welch on 8/23/17.
--  Copyright © 2017 John Welch. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
    
    --UI Field Properties
    property theCurrentComputerName : "" --these six values all correspond to scutil settings
    property theCurrentLocalHostName : ""
    property theCurrentHostName : ""
    
    property theNewComputerName : ""
    property theNewLocalHostName: ""
    property theNewHostName : ""
    
    property theUserName: "" --short user name of currently logged in user
    property theUserPassword: "" --password entered to commit changes
    property aNewFieldIsBlank: true
    property areYouSure:""
	
	on applicationWillFinishLaunching_(aNotification)
        try
            set my theCurrentComputerName to do shell script "/usr/sbin/scutil --get ComputerName"
            on error
            set my theCurrentComputerName to ""
        end try
        set my theNewComputerName to my theCurrentComputerName --this will give us some defaults, makes life easier
        
        try
            set my theCurrentLocalHostName to do shell script "/usr/sbin/scutil --get LocalHostName"
            on error
            set my theCurrentLocalHostName to ""
        end try
        set my theNewLocalHostName to my theCurrentLocalHostName
        
        try
            set my theCurrentHostName to do shell script "/usr/sbin/scutil --get HostName"
            on error
            set my theCurrentHostName to ""
        end try
        set my theNewHostName to my theCurrentHostName
        
        set my theUserName to short user name of (get system info)
    end applicationWillFinishLaunching_
    
    on commitChanges_(sender) --hit "save changes" button
        --missing value is what you get if the human enters information, then deletes it. No, it doesn't go back to "" which is kind of a pain
        if ((theNewComputerName is "") or (theNewLocalHostName is "") or (theNewHostName is "") or (theNewComputerName is missing value) or (theNewLocalHostName is missing value) or (theNewHostName is missing value)) --one of the host name fields is blank
            try
                set areYouSure to button returned of (display dialog "One of your entries will blank out a host or computer name./nDo you really want to do this?")
            on error theErrorMessage number theErrorNumber --test the error
                if theErrorNumber is -128 then --this is the error generated when you hit "Cancel
                    return
                end if
            end try --if they click "ok" well, we're going to write blanks. It's dumb, but hey, the user wants it.
        end if
    
        --so there's a quirk in do shell script. When you're running the app, it caches your admin credentials the first time you enter them.
        --not sure how long for, but yeah, you only have to enter them once. Don't freak out.
        
        do shell script "/usr/sbin/scutil --set ComputerName \"" & theNewComputerName & "\"" with administrator privileges --this sets the computer name in scutil to the new computer name. Since that can have all kinds of characters, we quote it
        do shell script "/usr/sbin/scutil --set LocalHostName " & theNewLocalHostName with administrator privileges
        do shell script "/usr/sbin/scutil --set HostName " & theNewHostName with administrator privileges
        
        --now let's rerun the scutil --get so we can see our changes
        try
            set my theCurrentComputerName to do shell script "/usr/sbin/scutil --get ComputerName"
            on error
            set my theCurrentComputerName to ""
        end try
        
        try
            set my theCurrentLocalHostName to do shell script "/usr/sbin/scutil --get LocalHostName"
            on error
            set my theCurrentLocalHostName to ""
        end try
        
        try
            set my theCurrentHostName to do shell script "/usr/sbin/scutil --get HostName"
            on error
            set my theCurrentHostName to ""
        end try


    end commitChanges_
    
    on clearFields_(sender) -- hit cancel button
        set my theNewComputerName to ""
        set my theNewLocalHostName to ""
        set my theNewHostName to ""
    end clearFields_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
	
end script
