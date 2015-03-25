whats-playing
===============
Simple menu bar application to display the current track in Spotify and Rdio

Setup
-----
This application runs an AppleScript to retrieve now playing information. Unfortunately, as of 25/03/15 Spotify appear to have broken their AppleScript integration and you need to make a small change to Spotify's plist.

To do this simply right click on Spotify.app in Applications and select "Show Package Contents". Go into the "Contents" folder and open "Info.plist". Ensure that the following keys are present and set to the following (should be located at the bottom of the file):

    <key>NSAppleScriptEnabled</key>
	  <true/>
	  <key>OSAScriptingDefinition</key>
	  <string>applescript/Spotify.sdef</string>
	  
You will probably notice that the value for OSAScriptingDefinition is set to just "Spotify.sdef". This is the offending line. If it isn't then hurrah they've fixed it or you've meddled before.

You should now be able to run the application.

Happy "finding out what you're listening to really easily"!
