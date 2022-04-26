-- state.lua
--
-- State machine.
--
-- Copyright (c) 2022 Stanaforth (@spindlebink).
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local State = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local rawget = rawget

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function State:new()
	self.__index = self
	local state = {}
	setmetatable(state, self)

	state.previous = ""
	state.current = ""

	state.between = {}
	setmetatable(state.between, {
		__index = function(self, key)
			local r = rawget(self, key)
			if r == nil then
				local t = {}
				self[key] = t
				return t
			else
				return r
			end
		end
	})

	state.when = {}
	state.on = {}
	state.after = {}

	return state
end

function State:change(to)
	self.current = to
end

function State:changeAndUpdate(to)
	self.current = to
	self:update()
end

function State:update()
	self.previous = self.current
	if self.when[self.current] then
		self.when[self.current](self)
	end
	if self.previous ~= self.current then
		if self.after[self.previous] then
			self.after[self.previous](self)
		end
		local r = rawget(self.between, self.previous)
		if r ~= nil and r[self.current] ~= nil then
			r[self.current](self)
		end
		if self.on[self.current] then
			self.on[self.current](self)
		end
	end
end

return State
