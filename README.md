# Preface

This is a script for the [Archean game](https://store.steampowered.com/app/2941660/Archean/). It can also be found on the [Steam workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3613774706) for direct integration with the game.

# Description
This is just another auto crafting script. Connect some containers, a dashboard, some crafters, and be happy.

## The script features
 - Parallel crafting;
 - Storage management (keep a set number of items always in stock);
 - Crafting queueing;
 - Automatic output and crafting queueing;
 - Keyboard and numpad inputs for search and crafting specific amounts;
 - Multi-container storage.
 - Automatic output to a tool container

## Cons
 - Does NOT keep track of fluids. It is assumed the fluids will be there for crafting;
 - Stops when you don't have enough resources (ores) and simply prints an error.

## Planned features
 - Input container for ores and sorting outputs and resources;
 - Better version control;
 - Better error messages for debugging;
 - Better github documentation.


## How to use
Spawn the build (just a minicomputer) and insert the included HDD in a minicomputer or computer of choice.
Then, connect containers and crafters named "Craft_container*" and "Crafter*" where * means a number between 1 and 100 (inclusive). These names and the maximum number (100) can be changed in code.
Connect a dashboard named "Craft_dashboard", with a screen in port 0 (a big screen is recommended).
Now you are all set. Start the computer and the dashboard screen should display a welcome message (click to advance).


### Search feature
To use the search feature, connect a numpad named "Craft_keyboard" and turn on "SEARCH" on the screen.
To set a specific amount to craft connect a numpad named "Craft_numpad" and turn on "NUMPAD" on the screen.
To have an automatic output to a container, connect an item conveyor named "Output_conveyor". The items are only sent through the conveyor when the queue and stack are both empty (see below).


### Automated stock crafting
To set an amount to keep in stock, select the "SETTINGS" option on the menu, choose your item and either add, set, or subtract a number from the current set number.
This auto-stocking option can be toggled on and off by pushing "AUTOCRAFTING" on the screen. This and the auto-stocking amount is stored so the computer can be rebooted without loss of functionality.

On the right you can see the selected item, it's recipe, some usefull amount buttons, and two quantities like [0|1]. This is, in order, the amount you have in stock and the auto-stock amount setted for this item.


### Keeping track of progress
On the left you have 2 progress bars: Q and S. These are, respectivelly, the crafting Queue and Stack.
The way this works is: when you hit craft, your item is set as the last in the queue. When the stack is empty, the first item from the queue is put in the stack.
Then, if the item in the stack can't be directly crafted (say, you need more screws to do it), it will put the necessary items on the top of the stack, crafting them first.


### Dedicated output containers
Connect a conveyor named "Output_conveyor" going from the crafting containers to containers named "Output_container*", which should also be connected to the computer.
That's it. The autocrafter will automatically move items from the craft containers to the output **when idling**.

### Dedicated tool containers
Additionally to output containers, you can add another conveyor named "Tool_conveyor" going from the output containers to containers named "Tool_container*". Connect everything to the computer and it will move all the tools, construction blocks, and spools to the tool containers. This is useful to construct close to your base or easily finding these commonly used items.


### Color customisation
To change the UI colors, feel free to change the global variables in the Interface.xc file.



## More at...
This is the jist of it, I'll be updating this whenever I find a bug or new and cool functionality.

This was made for my Archean let's play on youtube:
https://youtube.com/playlist?list=PLE2DpCN7GH9U5ho76zWxBVVHLHhcie4iV