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
local Blitbuffer = require("ffi/blitbuffer")
local TextWidget = require("ui/widget/textwidget")
local Size = require("ui/size")
local DEBUG = require("dbg")
local ToggleSwitch = require("ui/widget/toggleswitch")

DEBUG:turnOn()

local SchulteNumber = InputContainer:new {
    label = nil,
    bordersize = Size.border.default,
    face = Font:getFace("infont"),
    key_padding = Size.padding.default,
    padding = Size.padding.small,
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
        radius = 0,
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
    width = Screen:getWidth() / 2,
    height = Screen:getWidth() / 2,
    medium_font_face = Font:getFace("ffont"),
    table_size = 5,
}

function SchulteTable:init()
    self:generateNumbers()
    self:createUI(true)
end

function SchulteTable:generateNumbers()
    local numbs = {}
    for i = 1, self.table_size * self.table_size do
        numbs[i] = false
    end

    self.NUMBS = {}
    math.randomseed(os.time())
    for i = 1, self.table_size do
        self.NUMBS[i] = {}
        for j = 1, self.table_size do
            local numb
            local repeatUntil
            repeat
                repeatUntil = false
                numb = math.random(1, self.table_size * self.table_size);
                if not numbs[numb] then
                    numbs[numb] = true
                    self.NUMBS[i][j] = numb
                    break
                end
            until repeatUntil ~= false
        end
    end
end

function SchulteTable:createUI(readSettings)
    local base_key_width =  math.floor((self.width - (#self.NUMBS[1] + 1)*self.key_padding - 2*self.padding)/#self.NUMBS[1])
    local base_key_height =  math.floor((self.height - (#self.NUMBS + 1)*self.key_padding - 2*self.padding)/#self.NUMBS)
    local h_key_padding = HorizontalSpan:new{width = self.key_padding}
    local v_key_padding = VerticalSpan:new{width = self.key_padding}
    local vertical_group = VerticalGroup:new{}

    for i = 1, #self.NUMBS do
        local horizontal_group = HorizontalGroup:new{}
        for j = 1, #self.NUMBS[i] do
            local schult_number = SchulteNumber:new{
                label = self.NUMBS[i][j],
                width = math.floor(base_key_width + self.key_padding) - self.key_padding,
                height = base_key_height,
            }
            table.insert(horizontal_group, schult_number)
            if j ~= #self.NUMBS[i] then
                table.insert(horizontal_group, h_key_padding)
            end
        end
        table.insert(vertical_group, horizontal_group)
        if i ~= #self.NUMBS then
            table.insert(vertical_group, v_key_padding)
        end
    end

    local schult_table_result = HorizontalGroup:new{}
    table.insert(schult_table_result, HorizontalSpan:new{width = self.width / 2})
    table.insert(schult_table_result, CenterContainer:new{
        dimen = Geom:new{
            w = self.width - 2*self.bordersize -2*self.padding - 4,
            h = self.height - 2*self.bordersize -2*self.padding - 4,
        },
        vertical_group})



    local buttons_group = HorizontalGroup:new{}

    local sizeConfig = {
        default_value = 0,
        args = { "incSize", "decSize" },
        default_arg = "",
        toggle = { _("decrease"), _("increase") },
        values = { 1, 2, 3 },
        name = "Table size",
        alternate = false,
        enabled = true,
    }

    local sizeSwitch = ToggleSwitch:new{
        width = self.width,
        default_value = 0,
        name = sizeConfig.name,
        name_text = "My text name",
        event = "ChangeTableSize",
        toggle = sizeConfig.toggle,
        args = sizeConfig.args,
        alternate = sizeConfig.alternate,
        default_arg = sizeConfig.default_arg,
        values = sizeConfig.values,
        enabled = sizeConfig.enable,
        config = self,
        readonly = self.readonly,
    }


    table.insert(buttons_group, sizeSwitch)
    --table.insert(buttons_group, HorizontalSpan:new{width = self.width / 3})


    --table.insert(buttons_group, button_minus)
    -- table.insert(buttons_group, HorizontalSpan:new{width = self.width * 0.1})
    -- table.insert(buttons_group, button_plus)

    local main = VerticalGroup:new{}
    table.insert(main, schult_table_result)
    table.insert(main, VerticalSpan:new())
    table.insert(main, buttons_group)


    DEBUG("---------")
    --DEBUG("result: " ,schult_table_result)
    DEBUG("vertical span width: " ,self.width / 2)
    DEBUG("screen width: " ,Screen:getWidth())
    DEBUG("screen width by scale: " ,Screen:scaleBySize(Screen:getWidth()))
    DEBUG("NUMBS width: " ,#self.NUMBS[1] + 1)
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
        width = Screen:getWidth(),
        height = Screen:getHeight(),
        main
    }
end
return SchulteTable
