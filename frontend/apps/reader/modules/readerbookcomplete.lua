local InputContainer = require("ui/widget/container/inputcontainer")
local FrameContainer = require("ui/widget/container/framecontainer")
local UIManager = require("ui/uimanager")
local InputText = require("ui/widget/inputtext")
local TimeVal = require("ui/timeval")
local CenterContainer = require("ui/widget/container/centercontainer")
local RenderText = require("ui/rendertext")
local RightContainer = require("ui/widget/container/rightcontainer")
local ToggleSwitch = require("ui/widget/toggleswitch")
local Button = require("ui/widget/button")
local ProgressWidget = require("ui/widget/progresswidget")
local LineWidget = require("ui/widget/linewidget")
local TextWidget = require("ui/widget/textwidget")
local HorizontalSpan = require("ui/widget/horizontalspan")
local VerticalSpan = require("ui/widget/verticalspan")
local LeftContainer = require("ui/widget/container/leftcontainer")
local ImageWidget = require("ui/widget/imagewidget")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local VerticalGroup = require("ui/widget/verticalgroup")
local Geom = require("ui/geometry")
local Blitbuffer = require("ffi/blitbuffer")
local Screen = require("device").screen
local Font = require("ui/font")
local DEBUG = require("dbg")
local util = require("util")
local _ = require("gettext")

--[[
--Save into sdr folder addtional section
["summary"] = {
    ["rating"] = 5,
    ["note"] = "Some text",
    ["status"] = "Reading"
    ["modified"] = "24.01.2016"
},]]

local ReaderBookComplete = InputContainer:new {
    -- identify itself
    pages = 0,
    progress = 0,
    review = "",
    complete = false,
    dimen = nil,
    document = nil,
    thumbnail = nil,
    props = nil,
    star = {},
    book_state = 2,
    summary = {
        rating = 0,
        note = nil,
        status = "",
        modified = "",
    }
}

function ReaderBookComplete:init()
    DEBUG("CONFIG:", self.doc_settings)
    --self.summary = self.ui.doc_settings:readSetting("summary")

    self.small_font_face = Font:getFace("ffont", 15)
    self.medium_font_face = Font:getFace("ffont", 20)
    self.large_font_face = Font:getFace("ffont", 25)

    self.star = Button:new {
        icon = "resources/icons/stats.star.empty.png",
        bordersize = 0,
        radius = 0,
        margin = 0,
        enabled = true,
        show_parent = self,
    }

    self.status = FrameContainer:new {
        dimen = Screen:getSize(),
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 0,
        padding = 0,
        self:showStatus(),
    }
    self[1] = self.status
end

function ReaderBookComplete:showStatus()
    local main_group = VerticalGroup:new { align = "left" }
    if self.thumbnail then
        local screen_width = Screen:getWidth()
        local img_width = self.thumbnail:getWidth() * 0.3
        local img_height = self.thumbnail:getHeight() * 0.3

        local thumb = ImageWidget:new {
            image = self.thumbnail,
            width = img_width,
            height = img_height,
            autoscale = false,
        }

        local cover_with_title_and_author_container = CenterContainer:new {
            dimen = Geom:new { w = screen_width, h = thumb:getSize().h },
        }

        local cover_with_title_and_author_group = HorizontalGroup:new { align = "top" }

        local span = HorizontalSpan:new { width = screen_width * 0.05 }

        table.insert(cover_with_title_and_author_group, span)
        table.insert(cover_with_title_and_author_group, thumb)
        table.insert(cover_with_title_and_author_group,
            self:generateTitleAuthorProgressGroup(screen_width - span.width - thumb:getSize().w,
                thumb:getSize().h,
                self.props.title,
                self.props.authors, 80, 600))
        table.insert(cover_with_title_and_author_container, cover_with_title_and_author_group)

        --portrait mode
        local rateHeight = 60
        local statisticsHeight = 60
        local summaryHeight = 140
        local statusHeight = 50

        --landscape mode
        if Screen:getScreenMode() == "landscape" then
            summaryHeight = 80
        end


        table.insert(main_group, self:addHeader(screen_width, 25, _("Progress")))
        table.insert(main_group, cover_with_title_and_author_container)
        table.insert(main_group, self:addHeader(screen_width, 25, _("Rate")))
        table.insert(main_group, self:generateRateGroup(screen_width, rateHeight))
        table.insert(main_group, self:addHeader(screen_width, 35, _("Statistics")))
        table.insert(main_group, self:generateStatisticsGroup(screen_width, statisticsHeight, '8', '09:12:40', '633'))
        table.insert(main_group, self:addHeader(screen_width, 35, _("Summary")))
        table.insert(main_group, self:generateSummaryGroup(screen_width, summaryHeight, "Some long text"))
        table.insert(main_group, self:addHeader(screen_width, 25, _("Status")))
        table.insert(main_group, self:generateSwitchGroup(screen_width, statusHeight))
    end
    return main_group
end


function ReaderBookComplete:addHeader(width, height, title)
    local group = HorizontalGroup:new {
        align = "center",
        bordersize = 0
    }

    local bold = false

    local titleWidget = TextWidget:new {
        text = title,
        face = self.large_font_face,
        bold = bold,
    }
    local titleSize = RenderText:sizeUtf8Text(0, Screen:getWidth(), self.large_font_face, title, true, bold)
    local lineWidth = ((width - titleSize.x) * 0.5)

    local line_container = LeftContainer:new {
        dimen = Geom:new { w = lineWidth, h = height },
        LineWidget:new {
            background = Blitbuffer.gray(0.2),
            dimen = Geom:new {
                w = lineWidth,
                h = 2,
            }
        }
    }

    local text_container = CenterContainer:new {
        dimen = Geom:new { w = titleSize.x, h = height },
        titleWidget,
    }

    table.insert(group, line_container)
    table.insert(group, text_container)
    table.insert(group, line_container)
    return group
end

function ReaderBookComplete:generateSwitchGroup(width, height)
    local switch_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
    }

    local config = {
        event = "ChangeBookStatus",
        default_value = 2,
        toggle = {
            [1] = _("Complete"),
            [2] = _("Reading"),
            [3] = _("Abandone"),
        },
        args = {
            [1] = "complete",
            [2] = "reading",
            [3] = "abandone",
        },
        default_arg = "reading",
        values = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
        },
        name = "book_status",
        alternate = false,
        enabled = true,
    }

    local switch = ToggleSwitch:new {
        width = width * 0.6,
        default_value = config.default_value,
        name = config.name,
        name_text = config.name_text,
        event = config.event,
        toggle = config.toggle,
        args = config.args,
        alternate = config.alternate,
        default_arg = config.default_arg,
        values = config.values,
        enabled = config.enable,
        config = self,
    }

    switch:setPosition(self.book_state)

    table.insert(switch_container, switch)
    return switch_container
end

function ReaderBookComplete:onChangeBookStatus(option_name, option_value)
    local curr_time = TimeVal:now()
    self.summary.status = option_name[option_value]
    self.summary.modified = os.date("%Y-%m-%d", curr_time.sec)
    self:saveSummary()
    return true
end

function ReaderBookComplete:onUpdateNote()
    --DEBUG("UPDATE NOTE", self.input_note:getText())
    self.summary.note = self.input_note:getText()
    self:saveSummary()
    return true
end


function ReaderBookComplete:saveSummary()
    --self.doc_settings:saveSetting("summary", self.summary)
    DEBUG("SAVE SUMMARY", self.summary)
end

function ReaderBookComplete:onConfigChoose(values, name, event, args, events, position)
    UIManager:scheduleIn(0.05, function()
        if values then
            self:onChangeBookStatus(args, position)
        end
        UIManager:setDirty("all")
    end)
end

function ReaderBookComplete:generateSummaryGroup(width, height, text)
    local note_group = VerticalGroup:new { align = "center" }

    self.input_note = InputText:new {
        text = text,
        face = self.medium_font_face,
        width = width * 0.95,
        height = height * 0.55,
        scroll = true,
        margin = 5,
        padding = 0,
        parent = self,
    }

    local update_button = Button:new {
        text = _("Update"),
        margin = 5,
        radius = 5,
        bordersize = 1,
        enabled = true,
        show_parent = self,
        callback = function()
            self:onUpdateNote()
        end,
    }

    local button_container = RightContainer:new {
        dimen = Geom:new { w = width, h = update_button:getSize().h },
        bordersize = 0,
        padding = 5,
        margin = 0,
        update_button
    }

    table.insert(note_group, self.input_note)
    table.insert(note_group, button_container)

    local note_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
        note_group
    }
    return note_container
end

function ReaderBookComplete:generateRateGroup(width, height)

    local stars_group = HorizontalGroup:new { align = "center" }

    table.insert(stars_group, self.star:new { callback = function() self:setStar(1) end })
    table.insert(stars_group, self.star:new { callback = function() self:setStar(2) end })
    table.insert(stars_group, self.star:new { callback = function() self:setStar(3) end })
    table.insert(stars_group, self.star:new { callback = function() self:setStar(4) end })
    table.insert(stars_group, self.star:new { callback = function() self:setStar(5) end })

    self.stars_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
        stars_group
    }

    return self.stars_container
end

function ReaderBookComplete:setStar(num)
    DEBUG("GOT NUMB", num)
    --clear previous data
    self.stars_container:clear()

    local stars_group = HorizontalGroup:new { align = "center" }
    for i = 1, num do
        table.insert(stars_group, self.star:new { icon = "resources/icons/stats.star.full.png", callback = function() self:setStar(i) end })
    end

    for i = num + 1, 5 do
        table.insert(stars_group, self.star:new { callback = function() self:setStar(i) end })
    end

    table.insert(self.stars_container, stars_group)

    UIManager:setDirty("all")
    self.summary.rating = num
    self:saveSummary()
    return true
end

--TODO generate by data from table
function ReaderBookComplete:generateStatisticsGroup(width, height, days, average, pages)
    local statistics_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
    }

    local statistics_group = VerticalGroup:new { align = "left" }
    local titles_group = HorizontalGroup:new { align = "center" }
    local data_group = HorizontalGroup:new { align = "center" }

    local tile_width = width * 0.33333
    local tile_height = height * 0.5

    local title_days_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = _("Days"),
            face = self.small_font_face,
        },
    }
    local title_time_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = _("Time"),
            face = self.small_font_face,
        },
    }
    local title_read_pages_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = _("Read pages"),
            face = self.small_font_face,
        }
    }

    table.insert(titles_group, title_days_container)
    table.insert(titles_group, title_time_container)
    table.insert(titles_group, title_read_pages_container)


    local days_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = days,
            face = self.medium_font_face,
        },
    }
    local average_time_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = average,
            face = self.medium_font_face,
        },
    }
    local read_pages_container = CenterContainer:new {
        dimen = Geom:new { w = tile_width, h = tile_height },
        TextWidget:new {
            text = pages,
            face = self.medium_font_face,
        }
    }

    table.insert(data_group, days_container)
    table.insert(data_group, average_time_container)
    table.insert(data_group, read_pages_container)

    table.insert(statistics_group, titles_group)
    table.insert(statistics_group, data_group)

    table.insert(statistics_container, statistics_group)
    return statistics_container
end

function ReaderBookComplete:generateTitleAuthorProgressGroup(width, height, title, authors, percentage, total_pages)

    local title_author_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = height },
    }

    local title_author_progressbar_group = VerticalGroup:new { align = "left" }

    table.insert(title_author_progressbar_group, VerticalSpan:new { width = height * 0.2 })

    local title_text = self:_getVerticalList(title, width, self.medium_font_face, false)

    for i = 1, util.tablelength(title_text) do
        local row = {}
        for y = 1, util.tablelength(title_text[i]) do
            table.insert(row, title_text[i][y].word)
        end

        local text_title = TextWidget:new {
            text = table.concat(row),
            face = self.medium_font_face,
        }
        local title_text_container = CenterContainer:new {
            dimen = Geom:new { w = width, h = text_title:getSize().h },
            text_title
        }
        table.insert(title_author_progressbar_group, title_text_container)
    end

    local text_author = TextWidget:new {
        text = authors,
        face = self.small_font_face,
        padding = 2,
    }

    local author_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = text_author:getSize().h },
        text_author
    }

    table.insert(title_author_progressbar_group, author_container)

    local progressWidget = ProgressWidget:new {
        width = width * 0.7,
        height = 10,
        percentage = percentage / 100,
        ticks = {},
        tick_width = 0,
        last = total_pages,
    }

    local progress_bar_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = progressWidget:getSize().h },
        progressWidget
    }

    table.insert(title_author_progressbar_group, progress_bar_container)
    local text_complete = TextWidget:new {
        text = percentage .. _("% Completed"),
        face = self.small_font_face,
    }

    local progress_bar_text_container = CenterContainer:new {
        dimen = Geom:new { w = width, h = text_complete:getSize().h },
        text_complete
    }

    table.insert(title_author_progressbar_group, progress_bar_text_container)
    table.insert(title_author_container, title_author_progressbar_group)
    return title_author_container
end

--[[
function ReaderBookComplete:restoreScreenMode()
    local screen_mode = G_reader_settings:readSetting("fm_screen_mode")
    if Screen:getScreenMode() ~= screen_mode then
        Screen:setScreenMode(screen_mode or "portrait")
    end
    UIManager:setDirty(self, "full")
end

function ReaderBookComplete:show(path)
    local doc = DocumentRegistry:openDocument(path)
    local thumbnail
    local total_pages
    local props
    if doc then
        thumbnail = doc:getCoverPageImage()
        total_pages = doc:getPageCount()
        props = doc:getProps()
        doc:close()
    end

    self.restoreScreenMode()
    local book_complete = ReaderBookComplete:new {
        dimen = Screen:getSize(),
        thumbnail = thumbnail,
        total_pages = total_pages,
        props = props,
        onExit = function()
            self.instance = nil
        end
    }
    UIManager:show(book_complete)
    self.instance = book_complete
end
]]

--[[
function ReaderBookComplete:onShow()
    UIManager:setDirty(self, function()
        return "ui", self.mycontainer.dimen
    end)
end
]]




--TODO: MOVE TO UTILS AND CHANGE ALSO TEXTBOXWIDGET
function ReaderBookComplete:_wrapGreedyAlg(h_list, width)
    --local line_height = (1 + self.line_height) * self.face.size
    local cur_line_width = 0
    local cur_line = {}
    local v_list = {}

    for k, w in ipairs(h_list) do
        w.box = {
            x = cur_line_width,
            w = w.width,
        }
        cur_line_width = cur_line_width + w.width
        if w.word == "\n" then
            if cur_line_width > 0 then
                -- hard line break
                table.insert(v_list, cur_line)
                cur_line = {}
                cur_line_width = 0
            end
        elseif cur_line_width > width then
            -- wrap to next line
            table.insert(v_list, cur_line)
            cur_line = {}
            cur_line_width = w.width
            table.insert(cur_line, w)
        else
            table.insert(cur_line, w)
        end
    end
    -- handle last line
    table.insert(v_list, cur_line)

    return v_list
end

--TODO: MOVE TO UTILS AND CHANGE ALSO TEXTBOXWIDGET
function ReaderBookComplete:_getVerticalList(text, width, face, bold)
    -- build horizontal list
    local h_list = {}
    for line in util.gsplit(text, "\n", true) do
        for words in line:gmatch("[\32-\127\192-\255]+[\128-\191]*") do
            for word in util.gsplit(words, "%s+", true) do
                for w in util.gsplit(word, "%p+", true) do
                    local word_box = {}
                    word_box.word = w
                    word_box.width = RenderText:sizeUtf8Text(0, Screen:getWidth(), face, w, true, bold).x
                    table.insert(h_list, word_box)
                end
            end
        end
        if line:sub(-1) == "\n" then table.insert(h_list, { word = '\n', width = 0 }) end
    end

    -- @TODO check alg here 25.04 2012 (houqp)
    -- @TODO replace greedy algorithm with K&P algorithm  25.04 2012 (houqp)
    return self:_wrapGreedyAlg(h_list, width)
end

return ReaderBookComplete

