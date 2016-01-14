local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Blitbuffer = require("ffi/blitbuffer")

--[[
RightContainer aligns its content (1 widget) at the right of its own dimensions
--]]
local RightContainer = WidgetContainer:new({
    bordersize = 0,
    color = Blitbuffer.COLOR_BLACK,
    radius = 0,
})

--TODO get data from FrameContainer
function RightContainer:paintTo(bb, x, y)
    local contentSize = self[1]:getSize()
    if contentSize.w > self.dimen.w or contentSize.h > self.dimen.h then
        -- throw error? paint to scrap buffer and blit partially?
        -- for now, we ignore this
    end

    if self.bordersize > 0 then
        bb:paintBorder(x + (self.dimen.w - contentSize.w),
            y + math.floor((self.dimen.h - contentSize.h) / 2),
            contentSize.w,
            contentSize.h,
            self.bordersize, self.color, self.radius)
    end

    self[1]:paintTo(bb,
        x + (self.dimen.w - contentSize.w),
        y + math.floor((self.dimen.h - contentSize.h) / 2))
end

return RightContainer
