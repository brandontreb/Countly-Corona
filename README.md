# Corona - Countly

[Countly](http://count.ly) is a fantastic open source stat tracking application and a good alternative for those wishing to take control of their own statistical data produced from apps.

Countly-Corona is a lua interface to Count.ly enabling you to use it in your Corona SDK applications.

## Getting Set Up

1. Corona-Countly uses [GGData](https://github.com/GlitchGames/GGData) to aid with disk caching when offline. Clone that repository and copy GGData.lua into a subdirectory of your Corona application called util.
2. Copy countly.lua into the util directory as well

When you are done, your files should look like this:

<pre>
Corona_Project
|-util
  |- GGData.lua
  |- countly.lua
|-main.lua
</pre>

## Using The Countly Module

First, import the countly module into main.lua

`````lua
local Countly = require("util.countly")
`````

Then initialize counlty with your application key and url

`````lua
Countly:startWithHost("APP_KEY","http://yourappaddress.com")
`````

## Tracking Events

Again, make sure that the countly module is imported for any file you want to track an event for.

`````lua
local Countly = require("util.countly")
`````

Then use one of the following methods:

`````lua
Countly:recordEventCount(key, count)
Countly:recordEventCountSum(key, count, sum)
Countly:recordEventCountSegmentation(key, count, segmentation)
Countly:recordEventCountSumSegmentation(key, count, sum, segmentation)
`````

Here is an example of each:

`````lua
-- Simple count
Countly:recordEventCount("game_started", 1)

-- Simple sum
Countly:recordEventCountSum("time_spent_hacking", 1, 13.37)

-- Using segmentation
Countly:recordEventCountSegmentation("choose_your_player", 1, { ["player"] = "Mario" }) 
`````

## Known Issues

- App Version: I wasn't sure how to determine this with Corona
- Carrier: I wasn't sure how to determine this

If you know how to determine either above, I'd really appreciate a pull request.

