-- Copyright (c) 2013 Brandon Trebitowski (http://brandontreb.com)

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
-- associated documentation files (the "Software"), to deal in the Software without restriction, including 
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
-- sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
-- Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local json = require("json")
local socket = require "socket"
local GGData = require("util.GGData")
local cache = GGData:new( "countly_cache" )

local Countly = {}

-- Public
Countly.debug = true
Countly.app_key = nil
Countly.host = nil
Countly.session_duration = 30 * 1000
Countly.device_id = system.getInfo( "deviceID" )

local session_timer

local function monitor_session()
  local event_table = {{["key"] = key, ["count"] = count}}
  local events = json.encode( event_table )

  local url = Countly.host .."/i?app_key=" .. Countly.app_key ..
  "&device_id=" .. Countly.device_id .. 
  "&session_duration=" .. Countly.session_duration

  network.request( url, "GET", networkListener )

  if Countly.debug == true then
    print ( "Countly Session Tick")
  end
end

local function cacheNetworkListener(event)
  if ( event.isError ) then
    if Countly.debug == true then
      print( "Countly error flushing cache")                            
    end
  else
    if Countly.debug == true then
      print( "Countly cache flush: " .. event.response)                            
    end
  end
end

local function networkListener( event )
  if ( event.isError ) then
      if Countly.debug == true then
        print( "Countly Network error caching!")                            
      end

      if cache.requests == nil then
        cache.requests = {}
      end
      -- Cache the request with it's timestamp
      table.insert(cache.requests, event.url .. "&timestamp=" .. socket.gettime()*1000)
      cache:save()          
  else
    if Countly.debug == true then
      print ( "Countly Response: " .. event.response )            
    end

    -- Flush the cache
     if cache.requests ~= nil then
      for i=1,#cache.requests do
        url = cache.requests[i]
        network.request( url, "GET", cacheNetworkListener )  
      end
      cache.requests = nil
      cache:save()
     end

  end
end

-- Needed to URL Encode JSON
function escape(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str  
end

function Countly:startWithHost(app_key, host)

  Countly.app_key = app_key
  Countly.host = host

  local device_id = Countly.device_id
  local sdk_version = system.getInfo( "build" )
  local os = system.getInfo( "platformName" )
  local os_version = system.getInfo( "platformVersion" )
  local device = system.getInfo( "model" )
  local resolution = display.contentWidth .. "x" .. display.contentHeight
  local carrier = "unknown"
  -- Hardcoded, please do a pull request if you know how to obtain this value
  local app_version = "1.0"
  local metrics = escape(json.encode(
      {["_os"] = os,
      ["_os_version"] = os_version,
      ["_device"] = device,
      ["_resolution"] = resolution,
      ["_app_version"] = app_version,
      ["_carrier"] = carrier}
    ))

  local url = host .. "/i?app_key=" .. app_key .. 
  "&device_id=" .. device_id ..
  "&sdk_version=" .. sdk_version ..
  "&begin_session=1" ..
  "&metrics=" .. metrics

  if Countly.debug == true then
    print("Countly Initialized")
  end
  network.request( url, "GET", networkListener )  

end

function Countly:recordEventCount(key, count)

  local event_table = {{["key"] = key, ["count"] = count}}
  local events = json.encode( event_table )

  local url = Countly.host .."/i?app_key=" .. Countly.app_key ..
  "&device_id=" .. Countly.device_id .. 
  "&events=" .. escape(events)

  if Countly.debug == true then
    print("Countly Event Logged " .. key)
  end
  network.request( url, "GET", networkListener )

end

function Countly:recordEventCountSum(key, count, sum)

  local event_table = {{["key"] = key, ["count"] = count, ["sum"] = sum}}
  local events = json.encode( event_table )

  local url = Countly.host .."/i?app_key=" .. Countly.app_key ..
  "&device_id=" .. Countly.device_id .. 
  "&events=" .. escape(events)

  if Countly.debug == true then
    print("Countly Event Logged " .. key)
  end

  network.request( url, "GET", networkListener )
end

function Countly:recordEventCountSegmentation(key, count, segmentation)

  local event_table = {{["key"] = key, ["count"] = count, ["segmentation"] = segmentation}}
  local events = json.encode( event_table )

  local url = Countly.host .."/i?app_key=" .. Countly.app_key ..
  "&device_id=" .. Countly.device_id .. 
  "&events=" .. escape(events)

  if Countly.debug == true then
    print("Countly Event Logged " .. key)
  end

  network.request( url, "GET", networkListener )
end

function Countly:recordEventCountSumSegmentation(key, count, sum, segmentation)

  local event_table = {{["key"] = key, ["count"] = count,["sum"] = sum, ["segmentation"] = segmentation}}
  local events = json.encode( event_table )

  local url = Countly.host .."/i?app_key=" .. Countly.app_key ..
  "&device_id=" .. Countly.device_id .. 
  "&events=" .. escape(events)

  if Countly.debug == true then
    print("Countly Event Logged " .. key)
  end

  network.request( url, "GET", networkListener )
end

local function cache_session_end()
  if cache.requests == nil then
    cache.requests = {}
  end

  local url = Countly.host .. "/i?app_key=" .. Countly.app_key .. 
  "&device_id=" .. Countly.device_id ..
  "&end_session=1" 

  -- Cache the request with it's timestamp
  table.insert(cache.requests, url .. "&timestamp=" .. socket.gettime()*1000)
  cache:save()
end

-- Hooks to start and stop Countly when the app starts or stops.  Since Corona
-- won't allow network events when the system is shutting down, the end session event
-- is cached and uploaded the next time the app is online.
local function onSystemEvent( event )
  if (event.type == "applicationExit") then
    if session_timer ~= nil then
      timer.cancel(session_timer)
      cache_session_end()
    end
  elseif (event.type == "applicationStart") then
    session_timer = timer.performWithDelay(Countly.session_duration, monitor_session, 0)
  elseif (event.type == "applicationOpen") then
    if session_timer == nil then
      session_timer = timer.performWithDelay(Countly.session_duration, monitor_session, 0)
    else
      timer.resume(session_timer)
    end
  elseif (event.type == "applicationResume") then
    if session_timer == nil then
      session_timer = timer.performWithDelay(Countly.session_duration, monitor_session, 0)
    else
      timer.resume(session_timer)
    end
  elseif (event.type == "applicationSuspend") then
    if session_timer ~= nil then
      timer.cancel(session_timer)
      session_timer = nil
    end
  end
end

Runtime:addEventListener( "system", onSystemEvent )

return Countly