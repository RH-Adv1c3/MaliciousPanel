# MaliciousPanel
Cipher Panel Research

With respect to @ericstolly's research, I have dug up more information and together with his research this repo has been created. 
Mainly for information and educational purposes for server owners to figure out how what and where.

The several stages will be found in the files of this repo, there's also tools available (for now very limited) and a file which they infected. Don't worry it's only effective whenever you drop this file in the server files at the right position.

Explaination of the several stages:

*Stage 1*: This stage is the "exploit" stage, just depends on what you want to name it. 
In this stage they are gaining entry into your FiveM server and talking with their panel. 

*Stage 2*: This stage is the Payload phase, this is when they're re-writing your sessionmanager files and build a control base for further spreading and infection of other resources.

*Stage 3*: This is the spread phase, this is mainly a bridge between phase 2 and phase 4, this is where local functions are added throughout several scripts and where the fxmanifests are edited to use / run MySQL statements assumably for gaining access to the IP's and user data. But most these days use other mysql scripts so it's pretty obvious when there is a `server_script {'@mysql-async/lib/MySQL.lua'}` added. 

*Stage 4*: This is the control stage, this is where the panel sends out triggers to the several listening functions, how they do it? Read in phase 4 docs.
In the basis they're performing simple HTTP requests to their panel. Whenever the panel sends out a call to action, the response in the web body changes and the functions reading the web body will then distribute the events either client or server sided. Also txAdmin is victim of this, disabling the whitelist for example or bypassing a txAdmin ban.

**Tips for now**:
- Use a other mysql script
- Use a 3rd Party script for your bans and whitelist
- Disable their website in the hosts file (in case of Windows)
- Re-install the fresh sessionmanager
- Use notepad++ to search for any obfuscated functions with the information that will be available per phase documentation
