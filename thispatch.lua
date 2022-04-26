-- thispatch.lua
--
-- Signal/callback dispatcher.
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

local Dispatcher = {}

function Dispatcher:new()
	self.__index = self
	local dispatcher = {}
	setmetatable(dispatcher, self)

	dispatcher._before = {}
	dispatcher._callbacks = {}
	dispatcher._after = {}
	dispatcher._where = {}

	return dispatcher
end

function Dispatcher:addBefore(callback)
	table.insert(self._before, callback)
	self._where[callback] = self._before
end

function Dispatcher:add(callback)
	table.insert(self._callbacks, callback)
	self._where[callback] = self._callbacks
end

function Dispatcher:addAfter(callback)
	table.insert(self._after, callback)
	self._where[callback] = self._after
end

function Dispatcher:remove(callback)
	local w = self._where[callback]
	if not w then
		return
	end
	for i = #w, 1, -1 do
		if w[i] == callback then
			table.remove(w, i)
		end
	end
	self._where[callback] = nil
end

function Dispatcher:dispatch(...)
	for i = 1, #self._before do
		self._before[i](...)
	end
	for i = 1, #self._callbacks do
		self._callbacks[i](...)
	end
	for i = 1, #self._after do
		self._after[i](...)
	end
end

function Dispatcher:dispatchBefore(...)
	for i = 1, #self._before do
		self._before[i](...)
	end
end

function Dispatcher:dispatchMain(...)
	for i = 1, #self._callbacks do
		self._callbacks[i](...)
	end
end

function Dispatcher:dispatchAfter(...)
	for i = 1, #self._after do
		self._after[i](...)
	end
end

return Dispatcher
