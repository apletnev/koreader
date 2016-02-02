local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Blitbuffer = require("ffi/blitbuffer")

--[[
LeftContainer aligns its content (1 widget) at the left of its own dimensions
--]]
local LeftContainer = WidgetContainer:new({
    bordersize = 0,
    color = Blitbuffer.COLOR_BLACK,
    radius = 0,
    padding = 0,
    margin = 0,
})

function LeftContainer:paintTo(bb, x, y)
    local contentSize = self[1]:getSize()
    if contentSize.w > self.dimen.w or contentSize.h > self.dimen.h then
        -- throw error? paint to scrap buffer and blit partially?
        -- for now, we ignore this
    end

    local content_size_width = contentSize.w + (self.padding + self.margin + self.bordersize) * 2
    local content_size_height = contentSize.h + (self.padding + self.margin + self.bordersize) * 2

    if self.bordersize > 0 then
        bb:paintBorder(x + self.margin,
            y + self.margin + math.floor((self.dimen.h - content_size_height) / 2),
            content_size_width - self.margin,
            content_size_height - self.margin,
            self.bordersize, self.color, self.radius)
    end

    self[1]:paintTo(bb,
        x + self.padding + self.margin + self.bordersize,
        y + self.padding + self.margin + self.bordersize + math.floor((self.dimen.h - contentSize.h) / 2))
end

return LeftContainer
