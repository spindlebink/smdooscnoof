# Smdooscnoof

Assorted undocumented mini-libraries in Lua that I use for my game projects.

## The name

Sm'doose k'noof. Smuh-doose-cuh-noof. Four syllables. Like a guy slurring (horribly slurring) "it's my dude's canoe, friend."

## The components

* `state.lua`: simple state machine w/ fairly robust callbacks
	```lua
	local state = require("state.lua"):new()

	-- called as long as the state is "idle"
	state.when["idle"] = function(state)
		print("I'm an idle boy!")
	end

	-- called at the transition between "idle" and "running"
	state.between["idle"]["running"] = function(state)
		print("Huff huff, guess I better start running")
	end

	-- called at any transition to "running" (along with any associated `between`
	-- callback)
	state.on["running"] = function(state)
		print("I hate running")
	end

	-- called at any transition away from "running" (along with any associated
	-- `between` callback)
	state.after["running"] = function(state)
		print("my feet go slideeeee")
	end

	-- gotta call this every frame
	state:update()
	```
* `minibar.lua`: scrollbar logic
	```lua
	local minibar = require("minibar"):new()

	-- amount of stuff the scrollbar can scroll over
	minibar.contentSize = 400
	-- amount of stuff the scrollbar can see (i.e. with 400 vs. 100, we have 300
	-- px worth of scrollability)
	minibar.viewportSize = 100

	-- apply an input to the scrollbar
	-- minibar has acceleration/deceleration built in, so you should apply this
	-- any time you get a scroll event and as long as you're updating it each
	-- frame you'll get some loovely scrollage
	minibar:applyScrollInput(1)

	-- gotta call this every frame
	minibar:update(delta)
	```
* `thispatch.lua`: callback container
	```lua
	local dispatcher = require("thispatch"):new()

	dispatcher:add(function(pingle, dingle)
		print("pingle said " .. tostring(pingle) .. " and dingle yelled back " .. tostring(dingle))
	end)

	dispatcher:addBefore(function()
		print("just gonna sliiiiide in here")
	end)

	dispatcher:dispatch("porringer", "harbinger")

	local function swoop()
		print("swap")
	end

	dispatcher:addAfter(swoop)
	dispatcher:remove(swoop)
	```
* `rich_text.lua`: rich UTF-8 text for LOVE with wrapping and crawling
