local Widget = require("ui/widget/widget")
local InputContainer = require("ui/widget/container/inputcontainer")
local FrameContainer = require("ui/widget/container/framecontainer")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local CenterContainer = require("ui/widget/container/centercontainer")
local Geom = require("ui/geometry")
local Screen = require("device").screen
local Font = require("ui/font")
local _ = require("gettext")
local LuaSettings = require("luasettings")
local DataStorage = require("datastorage")
local Blitbuffer = require("ffi/blitbuffer")
local TextWidget = require("ui/widget/textwidget")
local Size = require("ui/size")
local DEBUG = require("dbg")

DEBUG:turnOn()

local SchulteNumber = InputContainer:new {
    label = nil,
    -- width = nil,
    -- height = math.max(Screen:getWidth(), Screen:getHeight()) * 0.33,
    bordersize = Size.border.default,
    face = Font:getFace("infont"),
    key_padding = Size.padding.default,
    padding = Size.padding.small,
    width = Screen:scaleBySize(600),
    height = math.max(Screen:getWidth(), Screen:getHeight())*0.33,
}

function SchulteNumber:init()
    local label_widget = TextWidget:new {
        text = self.label,
        face = self.face,
    }
    self[1] = FrameContainer:new{
        margin = 0,
        bordersize = 1,
        background = Blitbuffer.COLOR_WHITE,
        radius = 1,
        padding = 0,
        CenterContainer:new{
            dimen = Geom:new{
                w = self.width - 2*self.bordersize,
                h = self.height - 2*self.bordersize,
            },
            label_widget,
        },
    }
    self.dimen = Geom:new{
        w = self.width,
        h = self.height,
    }
end


local SchulteTable = InputContainer:extend{
    is_enabled = nil,
    name = "Schulte table",
    margin = 0.1,
    bordersize = Screen:scaleBySize(1),
    face = Font:getFace("infont"),
    key_padding = Screen:scaleBySize(5),
    padding = Screen:scaleBySize(2),
    width = Screen:scaleBySize(600),
    height = nil,
}

function SchulteTable:init()
    --[[    if not self.settings then self:readSettingsFile() end

        self.is_enabled = self.settings:readSetting("is_enabled") or false
        if not self.is_enabled then
            return
        end]]

    self.KEYS = {
        [1] = {1, 3, 5, 7, 9},
        [2] = {2, 4, 6, 8, 10},
        [3] = {11, 13, 15, 17, 19},
        [4] = {12, 14, 16, 18, 20},
        [5] = {21, 23, 25, 22, 24},
    }

    self.height = Screen:scaleBySize(600)
    self:createUI(true)
end

function SchulteTable:createUI(readSettings)
    --[[
        if readSettings then
            self.line_thickness = tonumber(self.settings:readSetting("line_thick"))
            self.margin = tonumber(self.settings:readSetting("margin"))
            self.line_color_intensity = tonumber(self.settings:readSetting("line_color_intensity"))
            self.shift_each_pages = tonumber(self.settings:readSetting("shift_each_pages"))
            self.page_counter = tonumber(self.settings:readSetting("page_counter"))
        end
    ]]

    --self.screen_width = Screen:getWidth()
    --self.screen_height = Screen:getHeight()
    --local line_height = screen_height * 0.9
    --local line_top_position = screen_height * 0.05

    local base_key_width =  math.floor((self.width - (#self.KEYS[1] + 1)*self.key_padding - 2*self.padding)/#self.KEYS[1])
    local base_key_height =  math.floor((self.height - (#self.KEYS + 1)*self.key_padding - 2*self.padding)/#self.KEYS)
    local h_key_padding = HorizontalSpan:new{width = self.key_padding}
    local v_key_padding = VerticalSpan:new{width = self.key_padding}
    local vertical_group = VerticalGroup:new{}

    for i = 1, #self.KEYS do
        local horizontal_group = HorizontalGroup:new{}
        for j = 1, #self.KEYS[i] do
            local width_factor = 1.0
            local key_width = math.floor((base_key_width + self.key_padding) * width_factor) - self.key_padding
            local key_height = base_key_height
            local label = self.KEYS[i][j]
            local key = SchulteNumber:new{
                label = label,
                width = key_width,
                height = key_height,
            }
            table.insert(horizontal_group, key)
            if j ~= #self.KEYS[i] then
                table.insert(horizontal_group, h_key_padding)
            end
        end
        table.insert(vertical_group, horizontal_group)
        if i ~= #self.KEYS then
            table.insert(vertical_group, v_key_padding)
        end
    end

    DEBUG("---------")
    DEBUG("keys width: " ,#self.KEYS[1] + 1, #self.keys[1])
    DEBUG("widht: " ,self.width)
    DEBUG("height: ",self.height)
    DEBUG("bordersize: ",self.bordersize)
    DEBUG("padding: ",self.padding)
    DEBUG("---------")
    self[1] = FrameContainer:new{
        margin = 2,
        bordersize = 1,
        background = Blitbuffer.COLOR_WHITE,
        radius = 0,
        padding = self.padding,
        CenterContainer:new{
            dimen = Geom:new{
                w = self.width - 2*self.bordersize -2*self.padding - 4,
                h = self.height - 2*self.bordersize -2*self.padding - 4,
            },
            vertical_group,
        }
    }
end

return SchulteTable
