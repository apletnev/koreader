local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Blitbuffer = require("ffi/blitbuffer")

--[[
CenterContainer centers its content (1 widget) within its own dimensions
--]]
local CenterContainer = WidgetContainer:new({
    bordersize = 0,
    color = Blitbuffer.COLOR_BLACK,
    radius = 0,
    padding = 0,
    margin = 0,
})

function CenterContainer:paintTo(bb, x, y)
    local content_size = self[1]:getSize()
    if content_size.w > self.dimen.w or content_size.h > self.dimen.h then
        -- throw error? paint to scrap buffer and blit partially?
        -- for now, we ignore this
    end

    local content_size_width = content_size.w + (self.padding + self.margin + self.bordersize) * 2
    local content_size_height = content_size.h + (self.padding + self.margin + self.bordersize) * 2

    local x_pos = x
    local y_pos = y
    if self.ignore ~= "height" then
        y_pos = y + math.floor((self.dimen.h - content_size.h) / 2)
    end
    if self.ignore ~= "width" then
        x_pos = x + math.floor((self.dimen.w - content_size.w) / 2)
    end

    if self.bordersize > 0 then
        bb:paintBorder(x_pos + self.margin, y_pos + self.margin,
            content_size_width - self.margin,
            content_size_height - self.margin,
            self.bordersize, self.color, self.radius)
    end
    if self[1] then
        self[1]:paintTo(bb,
            x_pos + self.padding + self.margin + self.bordersize,
            y_pos + self.padding + self.margin + self.bordersize)
    end
end

return CenterContainer
