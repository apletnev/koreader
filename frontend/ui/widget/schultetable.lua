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
local ToggleSwitch = require("ui/widget/toggleswitch")
local UIManager = require("ui/uimanager")

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
    table_height = Screen:getWidth(),
    medium_font_face = Font:getFace("ffont"),
    table_cells_count = 5, --cells count
    padding = Size.padding.small,
    screen_width = Screen:getWidth(),
    screen_height = Screen:getHeight()
}

function SchulteTable:init()
    self:generateNumbers()
    self:createUI(true)
end

function SchulteTable:generateNumbers()
    local numbs = {}
    for i = 1, self.table_cells_count * self.table_cells_count do
        numbs[i] = false
    end

    self.CELLS = {}
    math.randomseed(os.time())
    for i = 1, self.table_cells_count do
        self.CELLS[i] = {}
        for j = 1, self.table_cells_count do
            local numb
            local repeatUntil
            repeat
                repeatUntil = false
                numb = math.random(1, self.table_cells_count * self.table_cells_count);
                if not numbs[numb] then
                    numbs[numb] = true
                    self.CELLS[i][j] = numb
                    break
                end
            until repeatUntil ~= false
        end
    end
end

function SchulteTable:generateTable()
    local base_cell_width =  math.floor((self.table_width - (#self.CELLS[1] + 1)*self.cell_padding - 2*self.table_padding)/#self.CELLS[1])
    local base_cell_height =  math.floor((self.table_height - (#self.CELLS + 1)*self.cell_padding - 2*self.table_padding)/#self.CELLS)
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
    table.insert(schult_table_result, HorizontalSpan:new{width = (self.screen_width - self.table_width)/2})
    table.insert(schult_table_result, CenterContainer:new{
        dimen = Geom:new{
            w = self.table_width - 2*self.bordersize -2*self.table_padding - 4,
            h = self.table_height - 2*self.bordersize -2*self.table_padding - 4,
        },
        vertical_group})
    table.insert(schult_table_result, HorizontalSpan:new{width = (self.screen_width - self.table_width)/2})

    return schult_table_result
end

function SchulteTable:createTableSizeButton()
    local size_buttons_group = HorizontalGroup:new{}
    table.insert(size_buttons_group, TextWidget:new{text = _("Cells count"), face = Font:getFace("infont")})
    table.insert(size_buttons_group, HorizontalSpan:new{width = self.cell_padding * 2})
    table.insert(size_buttons_group, ToggleSwitch:new{
        width = self.screen_width/2,
        default_value = 0,
        event = "ChangeCellsCount",
        toggle = { _("decrease"), _("increase") },
        args = { "decCount", "incCount" },
        alternate = false,
        default_arg = "",
        values = { 1, 2 },
        enabled = true,
        config = self,
        readonly = false,
    })
    return size_buttons_group
end

function SchulteTable:createCellsSizeButton()
    local cells_buttons_group = HorizontalGroup:new{}
    table.insert(cells_buttons_group, TextWidget:new{text = _("Cells size"), face = Font:getFace("infont")})
    table.insert(cells_buttons_group, HorizontalSpan:new{width = self.cell_padding * 2})
    table.insert(cells_buttons_group, ToggleSwitch:new{
        width = self.screen_width/2 ,
        default_value = 0,
        event = "ChangeCellsSize",
        toggle = { _("decrease"), _("increase") },
        args = { "decSize", "incSize" },
        alternate = false,
        default_arg = "",
        values = {1, 2},
        enabled = true,
        config = self,
        readonly = false,
    })
    return cells_buttons_group
end

function SchulteTable:createUI(readSettings)

    local main = VerticalGroup:new{width = self.screen_width}
    table.insert(main, self:generateTable())
    table.insert(main, VerticalSpan:new{width = ((self.screen_height - self.table_height)) - (self.screen_height * 0.11)})
    table.insert(main, self:createTableSizeButton())
    table.insert(main, VerticalSpan:new{width = 5})
    table.insert(main, self:createCellsSizeButton())

    self[1] = FrameContainer:new{
        margin = 2,
        bordersize = 0,
        background = Blitbuffer.COLOR_WHITE,
        radius = 0,
        padding = self.padding,
        width = self.screen_width,
        height = self.screen_height,
        main
    }
end

function SchulteTable:onConfigChoose(values, name, event, args, events, position)
    UIManager:scheduleIn(0.05, function()
        if event == "ChangeCellsCount" then
                local delta = args[position] == "decCount" and -1 or 1
            if self.table_cells_count + delta >= 3 and self.table_cells_count + delta <= 7 then
                self.table_cells_count = self.table_cells_count + delta
                self:generateNumbers()
            end
            self:createUI()
            UIManager:setDirty(nil, "partial")
            return true
        end
        if event == "ChangeCellsSize" then
            if args[position] == "decSize" then
                if self.table_height > (self.screen_width * 0.4) then
                    self.table_width = self.table_width - (self.screen_width * 0.1)
                end
            else
                if self.table_width + self.table_width * 0.1 < self.screen_width then
                    self.table_width = self.table_width + (self.screen_width * 0.1)
                end
            end
            self.table_height = self.table_width
            UIManager:setDirty(nil, "partial")
            self:createUI()
            return true
        end
    end)
end

return SchulteTable
