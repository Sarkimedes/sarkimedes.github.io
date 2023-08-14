---
layout: post
title:  "Hacking Rare Candies into Pokemon Platinum"
date:   2023-08-14 22:12:00 +0100
categories: Fun
---

This is how I hacked in a bunch of Rare Candies at the start of my Pokemon Platinum save, using the excellent DS Pokemon Rom Editor: https://github.com/AdAstra-LD/DS-Pokemon-Rom-Editor
The overall approach I took was to piggyback on one of the events triggered right at the start of the game, and make that event stick a load of Rare Candies in my bag - it would also be possible to do this by writing my own trigger but I'm too lazy to bother with that.

The first thing I did was pick an appropriate event. In Platinum, the very first time you take a step your rival comes up and talks to you - therefore, this seemed like the perfect event to use. 

The next step was finding which map the event was triggered on. This event happens in the player's room (where you start the game) in Twinleaf Town. This involved digging through the header editor (which lists out all the maps in the game) for Twinleaf Town. There's a few maps in Twinleaf Town (because the town comprises both outside and inside maps) - what I ended up doing was finding the overworld map (which is the first one in the list), opening up the event editor for that map, and then following the warp points through until I reached the player's room at header location 415.

Once I'd figured out which map it was, I could open it up in the event editor to check which script was being executed by that event - each location has a script file associated with it, and the scripts on the event page correspond to a script within that locations's script file. In this case, all four scripts that are called by the triggers on this map call into the same function, so this is where I ended up inserting code to add a bunch of Rare Candies to my bag.

![Events in the player's room](/assets/images/PokemonPlatPlayersRoomEvents.PNG)

The actual code is just one line: 

`GiveItem <item_number> <amount> 0x800C`

where  `item_number` is the ID for whichever item I want to give myself - in this case, `50` for Rare Candy - and then the amount is a number between 1 and 999. I'm not 100% sure what the last parameter does - it's possibly telling the game to put the item in the last available item slot, but this is only a guess based on how it's used elsewhere in the game's code. All I needed to do was drop this near the end of the event script to make the game run this line of code along with the event it's running anyway:

![Rare Candy script in the script editor](/assets/images/PokemonPlatRareCandyScript.PNG)


And once I've started the game, I have 999 Rare Candies to use. This just saves me a few hours of grinding. Yes, I'm fully aware it's cheating - however, I also don't care what you think about how I play the children's video game.

