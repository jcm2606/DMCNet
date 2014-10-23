DMCNet by Jakemichie97 (a.k.a Jcm2606)

NOTE: When you first download this package, you should only get two files. This README file and a "launch_gui.bat" file. Download the latest update package and install it to get the rest of DMCNet. Once you have the update package, run the "launch_gui.bat" file and type 'update install <Version Number>' into the prompt on the console window. IF YOU DO NOT DO THIS, YOU WILL NOT BE ABLE TO RUN DMCNET!

DMCNet is a custom scripting language created by me (Jakemichie97/Jcm2606) coded completely in batch. I made this out of pure boredom, so this entire project is what came out of boredom. You may be expecting a small little file reader as the language, well no, this is an entire custom interpretor, runtime and execution environment capable of some cool stuff.

TABLE OF CONTENTS
	- Launching DMCNet
		- Flags
		- Launch scripts
	- Interaction
	- How the code works
		- Maps
		- Functions
		- ForEach loop
		- System commands
		- Using Inclusions
		- Hooks
	- How classes work
		- Class "hot-swapping"
		- Inclusions and how they work
	- Core object map and it's settings
		- Working Directory
		- Debug mode
	- Libraries
		
	
LAUNCHING DMCNET
	To launch DMCNet, you just need to execute the 'launch_gui' Batch script. If you wish to have more control over DMCNet launching, you can create a custom Batch script for launching, following the original as a template.
	
	FLAGS
		DMCNet includes some features which are not exactly "surfaced" by default, and require enabling to view and interact with. By use of a feature known as Environment Flags, you can interface with and enable these features. To use flags, you can use a set of quotes and put anything between them ("Put any data in here"). Typically, this is the last thing you type into the GUI, so for instance, running a class called TestClass with debug mode on would be 'class TestClass "-debug"'.
		
	LAUNCH SCRIPTS
		Sometimes with bigger applications, or even just applications which use some custom settings, you need to launch the application in a cleaner and more controllable way other than telling the user to input specific data into the GUI. This is where launch scripts come in.
		
		A launch script is essentially a custom .script file which has customised code to manipulate and modify the launch settings of the program it needs to run. Some libraries and modifications need certain data to be within the launch script in order for said libraries / modifications to run successfully. You can also make the launching code much cleaner using launch scripts.
	
INTERACTION
	DMCNet offers two ways to interact with the environment in terms of code. The first is the stand-alone command-line. To launch this, just type 'line' into the launcher and a new console window with a prompt should show up. Type in any code here to run the code. This option is better for small-scale code testing and evaluation. The command-line also has debugging enabled by default, so more behind-the-scenes information will be printed out to the console, making this a good way to test exactly what's going on. The other option is using a DMCNet class. To make a class, just create a file with the extension ".dmc", and type your code in. Once you have your class and it's in the current Working Directory (SEE THE "Working Directory" SECTION), type in 'class <Class name and (optional) pathing>' to launch the class.
	
HOW THE CODE WORKS
	In order to understand behind-the-scenes DMCNet, you need to understand the basics of how DMCNet handles the code. Essentially, each line of code is executed from the top-down. The code is ran in "code callback cycles", where a single FOR loop runs through the input (whether it be file or direct command input) and pits the current code up against a bunch of logical IF statements. Each statement redirects the script to a subroutine which then executes the code for the command being processed.
	
	MAPS
		A Map is essentially an intelligent array of data, each value residing in a unique index within the central Map instance. Using Maps, you can store a range of data in a way that makes it easily accessible. Using commands and loops, you can loop through all available elements of a Map, and more (SEE THE "ForEach Loop" SECTION).
		
	FUNCTIONS
		A function is essentially a way for DMCNet to store a "block" of code in such a way that it can be called back at any time by invoking the function. To declare a function, use "function.wrap <Function Name>", <Function Name> being your desired function name. NOTE: This name can not have any spaces in it. You cannot declare a function while another is already being declared. A function declaration can be stopped by using "function.end".
		
		While the function is being wrapped, DMCNet will ignore any code inside, instead just adding the code to the function.
		
		The function is executed in a separate callback cycle from the rest of the code.
		
	FOREACH LOOP
		You can use a "forEach" command to loop a line of code throughout a set of data (Map, file data, etc), assigning a specified variable name to be set as the particular value the loop is currently at. For example, to write the data of a Map with the name "DataMap" out, with each element on a separate line, "forEach DataMap value write value". The code ran is executed in a separate callback cycle from the rest of the code.
		
	SYSTEM COMMANDS
		DMCNet includes a few ways to interface directly with both the system and the MS-DOS interpretor. Use of these commands is done through the "system.***" commands. Direct MS-DOS commands can be done by using the "system.comIn <MS-DOS command and respective arguments>" command.
		
	USING INCLUSIONS (SEE THE "Inclusions and How They work" SECTION)
		To actually create an Inclusion and use it, you must first declare the Inclusion. To do this, you can use the "include" command. This command expects two arguments, the first being the Inclusion name (cannot have ANY spaces), and the second being the Inclusion path, the second can include spaces. The Inclusion name is the in-code name of the Inclusion object, and the Inclusion path is the actual path on the file system of the Inclusion class. When you declare an Inclusion, you are actually making a new variable that is equal to the Inclusion path. Any code using Inclusions references this variable to get the location of the class the Inclusion is for.
		
		To make a callback to an Inclusion, you can use the "@" symbol, followed by the Inclusion name (cannot have ANY spaces), and directly after the Inclusion name are the arguments for the Inclusion. The arguments must be separated by spaces, so you cannot use spaces at any point in any of the arguments. However there is a way to use spaces, and this method is called Fine Inclusion.
		
		Inclusion callbacks are intelligent, they can actually be ran through in "stages", one being the Inclusion callback declaration, and the next being the actual callback itself. To use these separate stages, you need to use "@-" instead of "@" when you go to make a callback. You can specify the arguments like normal, however this will temporarily halt the callback to allow for manual injection of arguments. Through the manual injection, you can actually use spaces in the arguments. Inclusions use a Map with the name "InclusionArguments" to store the Inclusion arguments.. See the "Maps" section for adding data to Maps.
		
		To resume callback, just use "@+" instead of "@". Note that when resuming callback, anything else except for the Inclusion name is ignored, so you cannot specify arguments to be added when resuming callback. Any data you add to the Inclusion arguments between the Fine Inclusion callback declaration and callback execution will be stored as valid arguments. Any data added prior to the callback declaration will automatically be wiped from the Map. Upon completion of the callback execution, the data in the Map will be wiped.
		
	HOOKS
		When a program needs to run some code when a specific event is reached, such as pre-session-build (before most of the data is set for the session). Of course the program can edit the original source code to add in the code needed, but that isn't really a good idea as it does have major issues, such as incompatibility, more work needing to be done by the end user, more effort to debug, generally it isn't a good idea. This is where hooks come in. A hook is essentially a type of class which gets invoked when an event is fired, such as pre-session-build, post-session-build, pre-class-callback, mid-class-callback, etc.
	
HOW CLASSES WORK
	Classes go through a little bit of work before they are interpreted and ran through. Firstly, the class-loader has it's Class value set and the data for the current class is set. Once all the valid data is set, DMCNet then runs through the code in the class.
	
	CLASS "HOT-SWAPPING"
		If you need to "hot-swap" classes during execution, you can do so by pushing a class to the current session class-loader, then reloading the class-loader. This will cause the data to be reset to the data for the parsed class.
		
	INCLUSIONS AND HOW THEY WORK
		Sometimes you have a common lot of code that can be used in many situations, but you don't want to have to continuously copy and paste the code into the current class. This is where Inclusions come into play. An Inclusion is essentially an "import" of the class, that allows the class to be "called on the fly", resulting in no class-loader reloads as the Included class is actually called in a separate code callback cycle in comparison to the "super class".
		
		This is used in libraries and other such modular code situations to avoid the end developer having to code their own solution, for example, a library can include a class that can be used as an Inclusion that will essentially take Map data and turn it into a viable String sentence.
		
CORE OBJECT MAP AND IT'S SETTINGS
	The Core Object Map (COM) is essentially a global configuration. The COM contains global environment settings and values, the user to manipulate and store environment values through use of the COM. DMCNet requires the COM to be available and accessible to function. If this requirement is not met, DMCNet will attempt to generate a new COM.
	
	WORKING DIRECTORY
		DMCNet operates in terms of directories, having two main directories. The first type of directory is the Core Path (CP). The CP is a location by which DMCNet will store the main files such as the COM, and sometimes the raw binaries and core scripts. The second type of directory is the Working Directory (WD). The WD is the directory in which the root directory for the class structure of DMCNet resides. In other words, the WD essentially 