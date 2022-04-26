-- minibar.lua
--
-- Minimal unidirectional smoothing-enabled scrollbar logic. Does zero rendering
-- or input. It's just the math.
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

local MiniBar = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Sensitivity of the scrollbar to applied scroll inputs. Set to a negative
-- number to reverse direction.
MiniBar.SENSITIVITY = 8

-- Speed at which the scrollbar approaches its target position. Higher values =
-- less smoothing. Set to 0 to disable smooth scrolling.
MiniBar.SMOOTHING_SPEED = 12

-- Rate at which the thumb size calculation scales with overflow of viewport. If
-- viewport size is 100 and content size is 120, a scale rate of 1 means the
-- thumb size will shrink by 20, a scale rate of 0.5 means it'll shrink by 10,
-- etc.
MiniBar.THUMB_SIZE_SCALE_RATE = 0.5

-- Minimum size for the thumb calculation.
MiniBar.THUMB_MIN_SIZE = 12

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Create a new scrollbar.
function MiniBar:new()
	self.__index = self
	local bar = {}
	setmetatable(bar, self)

	bar.atMin = false
	bar.atMax = true
	bar.viewportSize = 0
	bar.contentSize = 0
	bar.thumbSize = 0
	bar.offset = 0
	bar.velocity = 0

	bar._maxOffset = 0
	bar._targetOffset = 0
	bar._targetThumbSize = 0
	bar._targetVelocity = 0

	return bar
end

-- Updates the scrollbar.
function MiniBar:update(delta)
	local scrollableSpace = self.contentSize - self.viewportSize
	if scrollableSpace > 0 then
		self._targetThumbSize = math.max(self.viewportSize - scrollableSpace * self.THUMB_SIZE_SCALE_RATE, self.THUMB_MIN_SIZE)
		self._maxOffset = scrollableSpace
	else
		self._maxOffset = 0
	end

	if self._targetOffset < 0 then
		self._targetOffset = 0
	elseif self._targetOffset > self._maxOffset then
		self._targetOffset = self._maxOffset
	end

	if self.atMax then
		self._targetOffset = self._maxOffset
	end

	local start = self.offset

	local rate = self.SMOOTHING_SPEED * delta
	if rate > 1 or rate < 0 then
		rate = 1
	end

	self.offset = self.offset + (self._targetOffset - self.offset) * rate
	self.thumbSize = self.thumbSize + (self._targetThumbSize - self.thumbSize) * rate

	if self._targetOffset < 0 then
		self._targetOffset = 0
		self.atMin = true
	elseif self._targetOffset >= self._maxOffset then
		self._targetOffset = self._maxOffset
		self.atMax = true
	end
end

-- Applies a scroll input.
function MiniBar:applyScrollInput(scrollDelta)
	scrollDelta = scrollDelta * self.SENSITIVITY
	if scrollDelta > 0 then
		self.atMax = false
	end

	self._targetOffset = self._targetOffset - scrollDelta * self.SENSITIVITY
end

return MiniBar
