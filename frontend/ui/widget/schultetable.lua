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
    cell_padding = Size.padding.default,
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
    cell_padding = Screen:scaleBySize(5),
    table_padding = Screen:scaleBySize(2),
    table_width = Screen:getWidth(), -- width
    table_height = Screen:getWidth() / 2,
    medium_font_face = Font:getFace("ffont"),
    table_size = 2, --cells count
    padding = Size.padding.small,
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

    self.CELLS = {}
    math.randomseed(os.time())
    for i = 1, self.table_size do
        self.CELLS[i] = {}
        for j = 1, self.table_size do
            local numb
            local repeatUntil
            repeat
                repeatUntil = false
                numb = math.random(1, self.table_size * self.table_size);
                if not numbs[numb] then
                    numbs[numb] = true
                    self.CELLS[i][j] = numb
                    break
                end
            until repeatUntil ~= false
        end
    end
end

function SchulteTable:createUI(readSettings)
    local base_cell_width =  math.floor((self.table_width - (#self.CELLS[1] + 1)*self.cell_padding - 2*self.table_padding)/#self.CELLS[1])
    local base_cell_height =  math.floor((self.table_height - (#self.CELLS + 1)*self.cell_padding - 2*self.table_padding)/#self.CELLS)
    DEBUG('CELL WIDHT HEIGHT', base_cell_width, base_cell_height)
    local h_cell_padding = HorizontalSpan:new{width = self.cell_padding }
    local v_cell_padding = VerticalSpan:new{width = self.cell_padding}
    local vertical_group = VerticalGroup:new{}

    for i = 1, #self.CELLS do
        local horizontal_group = HorizontalGroup:new{}
        for j = 1, #self.CELLS[i] do
            local schult_number = SchulteNumber:new{
                label = self.CELLS[i][j],
                width = math.floor(base_cell_width + self.cell_padding) - self.cell_padding,
                height = base_cell_height,
            }
            table.insert(horizontal_group, schult_number)
            if j ~= #self.CELLS[i] then
                table.insert(horizontal_group, h_cell_padding)
            end
        end
        table.insert(vertical_group, horizontal_group)
        if i ~= #self.CELLS then
            table.insert(vertical_group, v_cell_padding)
        end
    end

    local schult_table_result = HorizontalGroup:new{}
    --table.insert(schult_table_result, HorizontalSpan:new{width = self.width / 2}) --TODO: use in case when table is small
    table.insert(schult_table_result, CenterContainer:new{
        dimen = Geom:new{
            w = self.table_width - 2*self.bordersize -2*self.table_padding - 4,
            h = self.table_height - 2*self.bordersize -2*self.table_padding - 4,
        },
        bordersize = 1,
        vertical_group})

    --DEBUG('TABLE', vertical_group)

    local size_buttons_group = HorizontalGroup:new {}

    local sizeSwitch = CenterContainer:new {
        dimen = Geom:new{
            w = Screen:getWidth() / 2,
            h = Screen:getHeight() * 0.5,
        },
        ToggleSwitch:new {
        width = Screen:getWidth(),
        default_value = 0,
        name = "Table Size",
        name_text = "My text name",
        event = "ChangeTableSize",
        toggle = { _("decrease"), _("increase") },
        args = { "incSize", "decSize" },
        alternate = false,
        default_arg = "",
        values = { 1, 2 },
        enabled = true,
        config = self,
        readonly = false,
    } }

    table.insert(size_buttons_group, sizeSwitch)


    local cells_buttons_group = HorizontalGroup:new{}
    local cellsSwitch = CenterContainer:new{
        dimen = Geom:new{
            w = Screen:getWidth() / 2,
            h = Screen:getHeight() * 0.5,
        },
        ToggleSwitch:new{
        width = Screen:getWidth(),
        default_value = 0,
        name = "Cells count",
        name_text = "Cells count",
        event = "ChangeCellsCount",
        toggle = { _("decrease"), _("increase") },
        args = { "incCells", "decCells" },
        alternate = false,
        default_arg = "",
        values = {1, 2},
        enabled = true,
        config = self,
        readonly = false,
    }
    }
    table.insert(cells_buttons_group, cellsSwitch)


    --table.insert(buttons_group, HorizontalSpan:new{width = self.width / 3})


    --table.insert(buttons_group, button_minus)
    -- table.insert(buttons_group, HorizontalSpan:new{width = self.width * 0.1})
    -- table.insert(buttons_group, button_plus)

    local main = VerticalGroup:new{HorizontalGroup:new{schult_table_result}}
    --table.insert(main, schult_table_result)
    table.insert(main, VerticalSpan:new{width = self.cell_padding})
    table.insert(main, HorizontalGroup:new{size_buttons_group})
    --table.insert(main, VerticalSpan:new{width = self.cell_padding})
    --table.insert(main, cells_buttons_group)


    DEBUG("---------")
    --DEBUG("result: " ,schult_table_result)
    DEBUG("vertical span width: " ,self.table_width / 2)
    DEBUG("screen width: " ,Screen:getWidth())
    DEBUG("screen width by scale: " ,Screen:scaleBySize(Screen:getWidth()))
    DEBUG("CELLS width: " ,#self.CELLS[1] + 1)
    DEBUG("widht: " ,self.table_width)
    DEBUG("height: ",self.table_height)
    DEBUG("bordersize: ",self.bordersize)
    DEBUG("padding: ",self.table_padding)
    DEBUG("---------")
    self[1] = FrameContainer:new{
        margin = 2,
        bordersize = 0,
        background = Blitbuffer.COLOR_WHITE,
        radius = 0,
        padding = self.padding,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
        main
    }
end
return SchulteTable
