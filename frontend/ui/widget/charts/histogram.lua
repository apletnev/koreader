--[[--
Histogram chart widget.

Example:
    local chart_data = {1, 3, 5, 1, 11, 18, 6}
    UIManager:show(require("ui/widget/charts/histogram"):new{
        data = chart_data,
        height = 300,
        width = 600,
        margin = {top = 10, right = 30, bottom = 30, left = 30},
        color = Blitbuffer.COLOR_GREY,
        background = Blitbuffer.COLOR_WHITE,
        border = 1,
    })

]]

local FrameContainer = require("ui/widget/container/framecontainer")
local InputContainer = require("ui/widget/container/inputcontainer")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local LineWidget = require("ui/widget/linewidget")
local Blitbuffer = require("ffi/blitbuffer")
local Geom = require("ui/geometry")
local _ = require("gettext")
local util = require("util")
local DEBUG = require("dbg")


local histogram = InputContainer:new{
    width = nil,
    height = nil,
    margin = { top = 10, right = 30, bottom = 30, left = 30 },
    data = nil,
    color = Blitbuffer.COLOR_GREY,
    background = Blitbuffer.COLOR_WHITE,
    border = 0,
}

function histogram:init()
   local dimen =  Geom:new{w = self.width, h = self.height }
    self[1] = FrameContainer:new{
        dimen = dimen,
        background = self.background,
        bordersize = self.border,
        padding = 0,
        self:generateChart(dimen, self.data)
    }
end

function histogram:generateChart(dimen, data)
    local chartGroup = HorizontalGroup:new{
        align = "bottom",
    }

    local total_items_count = util.tableSize(data)

    local max_bar_width = (dimen.w - self.margin.left - self.margin.right) / total_items_count
    local max_bar_height = dimen.h - self.margin.top - self.margin.bottom

    DEBUG(total_items_count, (dimen.w - self.margin.left - self.margin.right))

    if data then
        for i = 1, #data do
            table.insert(chartGroup, self:generateOneBar(max_bar_width, max_bar_height, data[i]))
        end
    end

    --TODO: Generate empty bars (left and right) to make histogram at the center
    return chartGroup;
end

function histogram:generateOneBar(max_bar_width, max_bar_height, value)
    return FrameContainer:new{
        dimen = Geom:new{ w = max_bar_width, h = max_bar_height},
        bordersize = 0,
        LineWidget:new{
            background = self.color,
            dimen = Geom:new{
                w = max_bar_width / 2,
                h = max_bar_height * (0.1 * value),
            }
        }
    }
end


return histogram
