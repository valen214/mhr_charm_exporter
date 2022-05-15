# mhr_charm_exporter
for use on https://mhrise.wiki-db.com/sim/

## Thanks
Huge part of the script is translated from https://github.com/Fexty12573/mhr-charm-item-editor

## Steps
1. Open Monster Hunter Rise and select your character
2. Run the [script: extract_charm_data.py](https://github.com/valen214/mhr_charm_exporter/blob/main/extract_charm_data.py), if everything goes well a file named 'charms_data.csv' will be created in the working directory or next to the script file.
3. Open 'charms_data.csv' with notepad and copy the content
4. paste it [here](https://mhrise.wiki-db.com/sim/) like so
![mhr sim charm import](https://i.imgur.com/zslFWI3.png)
5. Done
![mhr sim charm import](https://i.imgur.com/1BVQHTP.png)


## Requirements
Python 3.10 (tested environment, Python 3.4 or lower is guaranteed to fail as the script uses something from 3.5+)
Windows 64bit (I hard-coded the size of a pointer, search for "32bit" in the source code to see where)


## Other languages

### Change skill names csv
![change skill names csv](https://i.imgur.com/eCVnz8K.png)
From @Fexty's repo there are 3 csv available, actually I think he provided a skill names exporter as well, check [here](https://github.com/Fexty12573/mhr-charm-item-editor/tree/master/RisePCItemEditor/lang/converter)
In order to use local csv file, you need to set online to False as seen from the first line of the image, and change the csv file names in the else clause accordingly.

## TODO (WON'T DO)
I know those stuff that can improve user experience, like GUI,
remove useless print so one can execute and save input with a single command `py script.py > charms.csv`,
throw error and display error message when something goes wrong
but it works right now so I won't bother to change/add anything
