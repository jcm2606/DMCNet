ACENet by Jakemichie97 (a.k.a Jcm2606)

ACENet is a powerful API, library and modification of DMCNet which essentially allows greater control over the entire program you create. ACENet has a few different "modules" of sorts. More on these can be found in the "Installation "modules"" section.

ACENet comes in two packages. One for users, and one for developers, and these packages are separate from each other. More on this can be found in the "Installation Packages" section.

TABLE OF CONTENTS
	- Installation and the ACENet installation structure
		- Installation "modules"
		- Installation packages


INSTALLATION AND THE ACENET INSTALLATION STRUCTURE
	ACENet isn't as easy to install as DMCNet, having to just download a .zip archive, extract it and run a command. ACENet requires a more manual installation. ACENet essentially is a completely separate installation from DMCNet, being in it's own directory. Any programs that use ACENet also need to have their own launch scripts to tell the DMCNet Official Launcher where to find the core file.
	
	INSTALLATION "MODULES"
		ACENet essentially is made up of several "modules".
		
		The first are the Source Patches. These are stored in a separate folder. These essentially are Patchsets for the MS-DOS utility File Patcher, which is a utility tool designed to allow anyone to "patch" a file based on line numbers. The patches are performed to the original DMCNet source code, and essentially are designed to be as minimalistic as possible (keeping the actual amount of patching as low as possible, instead injecting calls to ACENet scripts into the source code).
		
		The next "module" is the collection of the Library Classes. These are DMCNet classes that essentially are designed to aid in one particular thing, and these classes are as generic as possible. The way you use these is you import these into the current session as Inclusions, and use the arguments to interface with the class. These again are stored in separate and unique folders. Some classes do have MS-DOS Batch scripts associated with themselves.

		The next "module" is the collection of the actual ACENet scripts. These are the MS-DOS Batch scripts which make ACENet possible, disregarding the patches and library classes.

		ACENet combines these "modules" to allow both the user and developer to have a seamless and easy-to-use ACENet installation environment.
		
	INSTALLATION PACKAGES
		There are two types of installations you can download, the User Package, and the Developer Package.
		
		The User Package is essentially the actual end user version of ACENet, able to function in any DMCNet environment, as long as it's installed properly (both DMCNet and ACENet). The User Package contains all the installation data of ACENet, but the format of the data is different from the Developer Package (more about this soon). This is generally the package you want if you want to just run ACENet applications.
		
		The next type of installation package is the Developer Package. The Developer Package is essentially the development build and installation of ACENet, including some useful tools only available in this package. The ACENet source code is also in an "open state", allowing the developer to essentially plug some custom data and code into the source code of ACENet, and use this to debug and test their own application's code. In other words, the files included in this package actually have different data, instead being more open. The Developer Package also contains some useful tools to manipulate DMCNet to aid the developer. This is generally the package to use if you want to develop applications using ACENet.