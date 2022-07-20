# mhr_charm_exporter
for use on https://mhrise.wiki-db.com/sim/

## Thanks
Huge part of the script is translated from https://github.com/Fexty12573/mhr-charm-item-editor

## Steps
1. Set up [REFRAMEWORK](https://www.nexusmods.com/monsterhunterrise/mods/26)
2. Download [reframework.zip](https://github.com/valen214/mhr_charm_exporter/releases/download/v2.1.0/reframework.zip) and extract the content under <MHR Game Directory>/reframework
   - 2.5 create the folder 'reframework/data' if it doesn't exist yet
3. Open Monster Hunter Rise and select your character
4. Open the REFramework Menu and expand "Script Generated UI"
5. Click on "[Charms Export] export charms to reframework/data/exported_charms.txt" [image steps](https://i.imgur.com/avFgVRS.gif)
![click on export charm](https://i.imgur.com/avFgVRS.gif)
   - 5.5 If the button is not showing, try expand "ScriptRunner" and click "Reset scripts"
6. Open 'reframework/data/exported_charms.txt' with notepad++ and copy the content
7. paste it [here](https://mhrise.wiki-db.com/sim/) like so
![mhr sim charm import](https://i.imgur.com/zslFWI3.png)
8. Done
![mhr sim charm import](https://i.imgur.com/1BVQHTP.png)


## Requirements
[REFRAMEWORK](https://www.nexusmods.com/monsterhunterrise/mods/26)


## Other languages
Now the lua script should grab the names directly from your game, so it would have the same language as your game does, if you need another language, might seek the steps to change the ingame language

## TODO (WON'T DO)
I know how to compile a separate dll in order to save the output without using the json format provided by REFramework, and thus not needing to replace the quotes, etc.
but it works right now so I won't bother to change/add anything
