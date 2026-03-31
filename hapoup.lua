local Menu = {}

Menu.Visible = false
Menu.CurrentCategory = 2
Menu.CurrentItem = 1
Menu.CurrentTab = 1
Menu.OpenedCategory = nil
Menu.ItemScrollOffset = 0
Menu.CategoryScrollOffset = 0
Menu.ItemsPerPage = 9
Menu.Scale = 1.0
Menu.SmoothFactor = 0.2
Menu.SelectorY = 0
Menu.CategorySelectorY = 0
Menu.TabSelectorX = 0
Menu.TabSelectorWidth = 0
Menu.IsLoading = true
Menu.LoadingComplete = false
Menu.LoadingProgress = 0.0
Menu.LoadingDuration = 1500
Menu.LoadingStartTime = nil
Menu.SelectingKey = false
Menu.SelectedKey = 0x31
Menu.SelectedKeyName = "1"
Menu.KeyStates = {}
Menu.ShowKeybinds = false

Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.imgur.com/8wGWjBh.png",
    height = 100
}

Menu.bannerTexture = nil
Menu.bannerWidth = 0
Menu.bannerHeight = 0

Menu.Colors = {
    HeaderPink = { r = 148, g = 0, b = 211 },
    SelectedBg = { r = 148, g = 0, b = 211 },
    TextWhite = { r = 255, g = 255, b = 255 },
    BackgroundDark = { r = 0, g = 0, b = 0 },
    FooterBlack = { r = 0, g = 0, b = 0 }
}

Menu.Position = {
    x = 50,
    y = 100,
    width = 360,
    itemHeight = 34,
    mainMenuHeight = 26,
    headerHeight = 100,
    footerHeight = 26,
    footerSpacing = 5,
    mainMenuSpacing = 5,
    footerRadius = 4,
    itemRadius = 4,
    scrollbarWidth = 10,
    scrollbarPadding = 3,
    headerRadius = 6
}

Menu.KeyNames = {
    [0x08] = "Backspace", [0x09] = "Tab", [0x0D] = "Enter", [0x10] = "Shift",
    [0x11] = "Ctrl", [0x12] = "Alt", [0x1B] = "ESC", [0x20] = "Space",
    [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down",
    [0x30] = "0", [0x31] = "1", [0x32] = "2", [0x33] = "3", [0x34] = "4",
    [0x35] = "5", [0x36] = "6", [0x37] = "7", [0x38] = "8", [0x39] = "9",
    [0x41] = "A", [0x42] = "B", [0x43] = "C", [0x44] = "D", [0x45] = "E",
    [0x46] = "F", [0x47] = "G", [0x48] = "H", [0x49] = "I", [0x4A] = "J",
    [0x4B] = "K", [0x4C] = "L", [0x4D] = "M", [0x4E] = "N", [0x4F] = "O",
    [0x50] = "P", [0x51] = "Q", [0x52] = "R", [0x53] = "S", [0x54] = "T",
    [0x55] = "U", [0x56] = "V", [0x57] = "W", [0x58] = "X", [0x59] = "Y",
    [0x5A] = "Z",
    [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4", [0x74] = "F5",
    [0x75] = "F6", [0x76] = "F7", [0x77] = "F8", [0x78] = "F9", [0x79] = "F10",
    [0x7A] = "F11", [0x7B] = "F12"
}

local function clamp(v, minV, maxV)
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

function Menu.GetKeyName(keyCode)
    return Menu.KeyNames[keyCode] or ("Key 0x" .. string.format("%02X", keyCode))
end

function Menu.LoadBannerTexture(url)
    if not url or url == "" then return end
    if not Susano or not Susano.HttpGet or not Susano.LoadTextureFromBuffer then return end

    CreateThread(function()
        local ok = pcall(function()
            local status, body = Susano.HttpGet(url)
            if status == 200 and body and #body > 0 then
                local textureId, width, height = Susano.LoadTextureFromBuffer(body)
                if textureId and textureId ~= 0 then
                    Menu.bannerTexture = textureId
                    Menu.bannerWidth = width or 0
                    Menu.bannerHeight = height or 0
                end
            end
        end)
        if not ok then
            Menu.bannerTexture = nil
        end
    end)
end

function Menu.ApplyTheme(themeName)
    local name = string.lower(tostring(themeName or "purple"))

    if name == "red" then
        Menu.Colors.HeaderPink = { r = 255, g = 0, b = 0 }
        Menu.Colors.SelectedBg = { r = 255, g = 0, b = 0 }
        Menu.Banner.imageUrl = "https://i.imgur.com/cOFPinI.gif"
    elseif name == "gray" then
        Menu.Colors.HeaderPink = { r = 128, g = 128, b = 128 }
        Menu.Colors.SelectedBg = { r = 128, g = 128, b = 128 }
        Menu.Banner.imageUrl = "https://i.imgur.com/iZnBhaR.jpeg"
    elseif name == "pink" then
        Menu.Colors.HeaderPink = { r = 255, g = 20, b = 147 }
        Menu.Colors.SelectedBg = { r = 255, g = 20, b = 147 }
        Menu.Banner.imageUrl = "https://i.imgur.com/BbABj2n.png"
    else
        Menu.Colors.HeaderPink = { r = 148, g = 0, b = 211 }
        Menu.Colors.SelectedBg = { r = 148, g = 0, b = 211 }
        Menu.Banner.imageUrl = "https://i.imgur.com/8wGWjBh.png"
    end

    if Menu.Banner.enabled then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end
end

function Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    return {
        x = Menu.Position.x,
        y = Menu.Position.y,
        width = Menu.Position.width * scale,
        itemHeight = Menu.Position.itemHeight * scale,
        mainMenuHeight = Menu.Position.mainMenuHeight * scale,
        headerHeight = Menu.Position.headerHeight * scale,
        footerHeight = Menu.Position.footerHeight * scale,
        footerSpacing = Menu.Position.footerSpacing * scale,
        mainMenuSpacing = Menu.Position.mainMenuSpacing * scale,
        footerRadius = Menu.Position.footerRadius * scale,
        itemRadius = Menu.Position.itemRadius * scale,
        scrollbarWidth = Menu.Position.scrollbarWidth * scale,
        scrollbarPadding = Menu.Position.scrollbarPadding * scale,
        headerRadius = Menu.Position.headerRadius * scale
    }
end

function Menu.DrawRect(x, y, width, height, r, g, b, a)
    a = a or 1.0
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0

    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x, y, width, height, r, g, b, a, 0)
    elseif Susano and Susano.DrawFilledRect then
        Susano.DrawFilledRect(x, y, width, height, r, g, b, a)
    elseif Susano and Susano.FillRect then
        Susano.FillRect(x, y, width, height, r, g, b, a)
    elseif Susano and Susano.DrawRect then
        for i = 0, height - 1 do
            Susano.DrawRect(x, y + i, width, 1, r, g, b, a)
        end
    end
end

function Menu.DrawRoundedRect(x, y, width, height, r, g, b, a, radius)
    local rr = r or 255
    local gg = g or 255
    local bb = b or 255
    local aa = a or 255

    if rr <= 1.0 then rr = rr * 255 end
    if gg <= 1.0 then gg = gg * 255 end
    if bb <= 1.0 then bb = bb * 255 end
    if aa <= 1.0 then aa = aa * 255 end

    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x, y, width, height, rr / 255.0, gg / 255.0, bb / 255.0, aa / 255.0, radius or 0)
    else
        Menu.DrawRect(x, y, width, height, rr, gg, bb, aa)
    end
end

function Menu.DrawText(x, y, text, size_px, r, g, b, a)
    local scale = Menu.Scale or 1.0
    size_px = (size_px or 16) * scale
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0
    a = a or 1.0

    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    if Susano and Susano.DrawText then
        Susano.DrawText(x, y, tostring(text or ""), size_px, r, g, b, a)
    end
end

function Menu.GetTextWidth(text, size)
    local scaled = (size or 16) * (Menu.Scale or 1.0)
    if Susano and Susano.GetTextWidth then
        return Susano.GetTextWidth(tostring(text or ""), scaled)
    end
    return string.len(tostring(text or "")) * scaled * 0.5
end

function Menu.IsKeyJustPressed(keyCode)
    if not (Susano and Susano.GetAsyncKeyState) then
        return false
    end

    local down, pressed = Susano.GetAsyncKeyState(keyCode)
    local wasDown = Menu.KeyStates[keyCode] or false
    Menu.KeyStates[keyCode] = (down == true)

    if pressed == true then return true end
    if down == true and not wasDown then return true end
    return false
end

function Menu.GetCurrentItems()
    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        if category and category.hasTabs and category.tabs and category.tabs[Menu.CurrentTab] then
            return category.tabs[Menu.CurrentTab].items or {}
        end
        return {}
    end
    return Menu.Categories or {}
end

function Menu.EnsureSelection()
    local items = Menu.GetCurrentItems()
    if #items == 0 then
        Menu.CurrentItem = 1
        return
    end

    Menu.CurrentItem = clamp(Menu.CurrentItem, 1, #items)
    local attempts = 0
    while items[Menu.CurrentItem] and items[Menu.CurrentItem].isSeparator and attempts < #items do
        Menu.CurrentItem = Menu.CurrentItem + 1
        if Menu.CurrentItem > #items then
            Menu.CurrentItem = 1
        end
        attempts = attempts + 1
    end
end

function Menu.DrawHeader()
    local pos = Menu.GetScaledPosition()
    local x, y, w = pos.x, pos.y, pos.width - 1
    local h = Menu.Banner.enabled and Menu.Banner.height * (Menu.Scale or 1.0) or pos.headerHeight

    if Menu.Banner.enabled and Menu.bannerTexture and Menu.bannerTexture > 0 and Susano and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, w, h, 1, 1, 1, 1, 0)
    else
        Menu.DrawRoundedRect(x, y, w, h, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255, pos.headerRadius)
        local logo = "P"
        local logoSize = 44
        local tx = x + (w / 2) - (Menu.GetTextWidth(logo, logoSize) / 2)
        local ty = y + (h / 2) - ((logoSize * (Menu.Scale or 1.0)) / 2)
        Menu.DrawText(tx, ty, logo, logoSize, 1.0, 1.0, 1.0, 1.0)
    end
end

function Menu.DrawTabs(category, x, startY, width, tabHeight)
    if not category or not category.hasTabs or not category.tabs or #category.tabs == 0 then
        return
    end

    local scale = Menu.Scale or 1.0
    local count = #category.tabs
    local tabWidth = width / count

    for i, tab in ipairs(category.tabs) do
        local tabX = x + ((i - 1) * tabWidth)
        local isSelected = (i == Menu.CurrentTab)

        Menu.DrawRect(tabX, startY, tabWidth, tabHeight, 0, 0, 0, isSelected and 0.15 or 0.30)

        if isSelected then
            Menu.DrawRect(tabX, startY, 3 * scale, tabHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
        end

        local textSize = 16
        local tw = Menu.GetTextWidth(tab.name, textSize)
        local tx = tabX + (tabWidth / 2) - (tw / 2)
        local ty = startY + (tabHeight / 2) - ((textSize * scale) / 2)
        Menu.DrawText(tx, ty, tab.name, textSize, 1.0, 1.0, 1.0, 1.0)
    end
end

function Menu.DrawScrollbar(x, startY, visibleHeight, selectedIndex, totalItems, isMainMenu, menuWidth)
    if totalItems <= Menu.ItemsPerPage then
        return
    end

    local pos = Menu.GetScaledPosition()
    local w = pos.scrollbarWidth
    local pad = pos.scrollbarPadding
    local width = menuWidth or pos.width
    local sx = x + width + pad
    local sy = startY
    local sh = visibleHeight

    local offset = isMainMenu and Menu.CategoryScrollOffset or Menu.ItemScrollOffset
    local totalScrollable = math.max(1, totalItems - Menu.ItemsPerPage)
    local progress = offset / totalScrollable
    local thumbH = math.max(24 * (Menu.Scale or 1.0), sh * (Menu.ItemsPerPage / totalItems))
    local thumbY = sy + ((sh - thumbH) * progress)

    Menu.DrawRoundedRect(sx, sy, w, sh, 30, 30, 30, 180, w / 2)
    Menu.DrawRoundedRect(sx + 1, thumbY, w - 2, thumbH, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255, (w - 2) / 2)
end

function Menu.DrawItem(x, itemY, width, itemHeight, item, isSelected)
    local scale = Menu.Scale or 1.0

    if item.isSeparator then
        Menu.DrawRect(x, itemY, width, itemHeight, 0, 0, 0, 50)
        local text = item.separatorText or ""
        local tw = Menu.GetTextWidth(text, 14)
        local tx = x + (width / 2) - (tw / 2)
        local ty = itemY + (itemHeight / 2) - ((14 * scale) / 2)
        Menu.DrawText(tx, ty, text, 14, 1.0, 1.0, 1.0, 1.0)
        return
    end

    Menu.DrawRect(x, itemY, width, itemHeight, 0, 0, 0, 50)

    if isSelected then
        Menu.DrawRect(x, itemY, width - 1, itemHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 140)
        Menu.DrawRect(x, itemY, 3 * scale, itemHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
    end

    local textX = x + (16 * scale)
    local textY = itemY + (itemHeight / 2) - ((17 * scale) / 2)
    Menu.DrawText(textX, textY, item.name or "Item", 17, 1.0, 1.0, 1.0, 1.0)

    if item.type == "toggle" then
        local toggleWidth = 36 * scale
        local toggleHeight = 16 * scale
        local toggleX = x + width - toggleWidth - (16 * scale)
        local toggleY = itemY + (itemHeight / 2) - (toggleHeight / 2)
        local bg = item.value and Menu.Colors.SelectedBg or { r = 60, g = 60, b = 60 }

        Menu.DrawRoundedRect(toggleX, toggleY, toggleWidth, toggleHeight, bg.r, bg.g, bg.b, 255, toggleHeight / 2)

        local circleSize = toggleHeight - 4
        local circleX = item.value and (toggleX + toggleWidth - circleSize - 2) or (toggleX + 2)
        Menu.DrawRoundedRect(circleX, toggleY + 2, circleSize, circleSize, 255, 255, 255, 255, circleSize / 2)
    elseif item.type == "selector" and item.options then
        local selectedIndex = item.selected or 1
        local selectedOption = item.options[selectedIndex] or ""
        local txt = "< " .. tostring(selectedOption) .. " >"
        local tw = Menu.GetTextWidth(txt, 16)
        local tx = x + width - tw - (16 * scale)
        Menu.DrawText(tx, textY, txt, 16, 1.0, 1.0, 1.0, 0.9)
    elseif item.type == "slider" then
        local sliderWidth = 90 * scale
        local sliderHeight = 6 * scale
        local sliderX = x + width - sliderWidth - (48 * scale)
        local sliderY = itemY + (itemHeight / 2) - (sliderHeight / 2)
        local minV = item.min or 0.0
        local maxV = item.max or 100.0
        local curV = item.value or minV
        local percent = 0.0
        if maxV > minV then
            percent = (curV - minV) / (maxV - minV)
        end
        percent = clamp(percent, 0.0, 1.0)

        Menu.DrawRoundedRect(sliderX, sliderY, sliderWidth, sliderHeight, 30, 30, 30, 255, 3)
        Menu.DrawRoundedRect(sliderX, sliderY, sliderWidth * percent, sliderHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255, 3)
        Menu.DrawRoundedRect(sliderX + sliderWidth * percent - (5 * scale), sliderY - (2 * scale), 10 * scale, 10 * scale, 255, 255, 255, 255, 5 * scale)

        local valueText = string.format("%.0f", curV)
        Menu.DrawText(sliderX + sliderWidth + (8 * scale), textY, valueText, 12, 1.0, 1.0, 1.0, 0.9)
    end
end

function Menu.DrawFooter()
    local pos = Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    local x = pos.x
    local bannerHeight = Menu.Banner.enabled and (Menu.Banner.height * scale) or pos.headerHeight

    local contentHeight = 0
    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        local count = 0
        if category and category.hasTabs and category.tabs and category.tabs[Menu.CurrentTab] then
            count = #(category.tabs[Menu.CurrentTab].items or {})
        end
        contentHeight = bannerHeight + pos.mainMenuHeight + pos.mainMenuSpacing + (math.min(Menu.ItemsPerPage, count) * pos.itemHeight)
    else
        contentHeight = bannerHeight + pos.mainMenuHeight + pos.mainMenuSpacing + (math.min(Menu.ItemsPerPage, math.max(0, #Menu.Categories - 1)) * pos.itemHeight)
    end

    local footerY = pos.y + contentHeight + pos.footerSpacing
    local footerWidth = pos.width - 1
    Menu.DrawRoundedRect(x, footerY, footerWidth, pos.footerHeight, 0, 0, 0, 255, pos.footerRadius)

    local left = " clean build "
    local right = Menu.OpenedCategory and (tostring(Menu.CurrentItem) .. "/" .. tostring(#Menu.GetCurrentItems())) or (tostring(math.max(1, Menu.CurrentCategory - 1)) .. "/" .. tostring(math.max(1, #Menu.Categories - 1)))
    local ty = footerY + (pos.footerHeight / 2) - ((13 * scale) / 2)

    Menu.DrawText(x + (15 * scale), ty, left, 13, 1.0, 1.0, 1.0, 1.0)
    local rw = Menu.GetTextWidth(right, 13)
    Menu.DrawText(x + footerWidth - rw - (15 * scale), ty, right, 13, 1.0, 1.0, 1.0, 1.0)
end

function Menu.DrawLoadingBar(alpha)
    if alpha <= 0 then return end
    local screenWidth = 1920
    local screenHeight = 1080
    if Susano and Susano.GetScreenWidth and Susano.GetScreenHeight then
        screenWidth = Susano.GetScreenWidth()
        screenHeight = Susano.GetScreenHeight()
    end

    local width = 220
    local height = 8
    local x = (screenWidth / 2) - (width / 2)
    local y = screenHeight - 140
    Menu.DrawRoundedRect(x, y, width, height, 30, 30, 30, math.floor(255 * alpha), 4)
    Menu.DrawRoundedRect(x, y, width * (Menu.LoadingProgress / 100.0), height, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, math.floor(255 * alpha), 4)

    local label = string.format("%.0f%%", Menu.LoadingProgress)
    local tw = Menu.GetTextWidth(label, 16)
    Menu.DrawText((screenWidth / 2) - (tw / 2), y - 24, label, 16, 1.0, 1.0, 1.0, alpha)
end

function Menu.DrawKeySelector(alpha)
    if alpha <= 0 then return end
    local screenWidth = 1920
    local screenHeight = 1080
    if Susano and Susano.GetScreenWidth and Susano.GetScreenHeight then
        screenWidth = Susano.GetScreenWidth()
        screenHeight = Susano.GetScreenHeight()
    end

    local width = 360
    local height = 90
    local x = (screenWidth / 2) - (width / 2)
    local y = screenHeight - 180
    Menu.DrawRoundedRect(x, y, width, height, 0, 0, 0, math.floor(220 * alpha), 8)
    Menu.DrawText(x + 16, y + 14, "KEYBIND", 16, 1.0, 1.0, 1.0, alpha)
    Menu.DrawRect(x + 16, y + 36, width - 32, 2, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, math.floor(255 * alpha))
    Menu.DrawText(x + 16, y + 48, "Current key: " .. tostring(Menu.SelectedKeyName or "1"), 14, 1.0, 1.0, 1.0, alpha)
end

function Menu.DrawCategories()
    local pos = Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    local x = pos.x
    local startY = pos.y + (Menu.Banner.enabled and (Menu.Banner.height * scale) or pos.headerHeight)
    local width = pos.width
    local itemHeight = pos.itemHeight
    local menuBarHeight = pos.mainMenuHeight
    local menuBarSpacing = pos.mainMenuSpacing

    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        if not category or not category.hasTabs or not category.tabs then
            Menu.OpenedCategory = nil
            return
        end

        Menu.DrawTabs(category, x, startY, width, menuBarHeight)

        local items = category.tabs[Menu.CurrentTab].items or {}
        local totalItems = #items
        local maxVisible = Menu.ItemsPerPage

        if Menu.CurrentItem > Menu.ItemScrollOffset + maxVisible then
            Menu.ItemScrollOffset = Menu.CurrentItem - maxVisible
        elseif Menu.CurrentItem <= Menu.ItemScrollOffset then
            Menu.ItemScrollOffset = math.max(0, Menu.CurrentItem - 1)
        end

        local itemY = startY + menuBarHeight + menuBarSpacing
        local visibleCount = 0

        for i = 1, math.min(maxVisible, totalItems) do
            local itemIndex = i + Menu.ItemScrollOffset
            if itemIndex <= totalItems then
                visibleCount = visibleCount + 1
                local drawY = itemY + ((i - 1) * itemHeight)
                Menu.DrawItem(x, drawY, width, itemHeight, items[itemIndex], itemIndex == Menu.CurrentItem)
            end
        end

        Menu.DrawScrollbar(x, itemY, visibleCount * itemHeight, Menu.CurrentItem, totalItems, false, width)
        return
    end

    local totalCategories = math.max(0, #Menu.Categories - 1)
    local maxVisible = Menu.ItemsPerPage

    if Menu.CurrentCategory > Menu.CategoryScrollOffset + maxVisible + 1 then
        Menu.CategoryScrollOffset = Menu.CurrentCategory - maxVisible - 1
    elseif Menu.CurrentCategory <= Menu.CategoryScrollOffset + 1 then
        Menu.CategoryScrollOffset = math.max(0, Menu.CurrentCategory - 2)
    end

    Menu.DrawRect(x, startY, width, menuBarHeight, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 120)
    local title = Menu.Categories[1] and Menu.Categories[1].name or "Menu"
    local titleX = x + (width / 2) - (Menu.GetTextWidth(title, 16) / 2)
    local titleY = startY + (menuBarHeight / 2) - ((16 * scale) / 2)
    Menu.DrawText(titleX, titleY, title, 16, 1.0, 1.0, 1.0, 1.0)

    local visibleCount = 0
    for displayIndex = 1, math.min(maxVisible, totalCategories) do
        local categoryIndex = displayIndex + Menu.CategoryScrollOffset + 1
        local category = Menu.Categories[categoryIndex]
        if category then
            visibleCount = visibleCount + 1
            local itemY = startY + menuBarHeight + menuBarSpacing + ((displayIndex - 1) * itemHeight)
            local isSelected = categoryIndex == Menu.CurrentCategory
            Menu.DrawItem(x, itemY, width, itemHeight, { name = category.name }, isSelected)
            Menu.DrawText(x + width - (24 * scale), itemY + (itemHeight / 2) - ((17 * scale) / 2), ">", 17, 1.0, 1.0, 1.0, 1.0)
        end
    end

    Menu.DrawScrollbar(x, startY + menuBarHeight + menuBarSpacing, visibleCount * itemHeight, Menu.CurrentCategory, totalCategories, true, width)
end

function Menu.Render()
    if not (Susano and Susano.BeginFrame) then
        return
    end

    local dt = 0.016
    if GetFrameTime then
        dt = GetFrameTime()
    end
    local animSpeed = 5.0 * dt

    local loadingAlpha = 0.0
    local keyAlpha = 0.0

    if Menu.IsLoading then
        loadingAlpha = 1.0
    end
    if Menu.SelectingKey then
        keyAlpha = 1.0
    end

    Susano.BeginFrame()

    if Menu.Visible then
        Menu.DrawHeader()
        Menu.DrawCategories()
        Menu.DrawFooter()
    end

    if loadingAlpha > 0 then
        Menu.DrawLoadingBar(loadingAlpha)
    end

    if keyAlpha > 0 then
        Menu.DrawKeySelector(keyAlpha)
    end

    if Susano and Susano.SubmitFrame then
        Susano.SubmitFrame()
    end
end

function Menu.HandleInput()
    if Menu.IsLoading and not Menu.LoadingComplete then
        return
    end

    if Menu.SelectingKey then
        local keysToCheck = {
            0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
            0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A,
            0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54,
            0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x70, 0x71, 0x72, 0x73,
            0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B
        }

        for _, keyCode in ipairs(keysToCheck) do
            if Menu.IsKeyJustPressed(keyCode) then
                Menu.SelectedKey = keyCode
                Menu.SelectedKeyName = Menu.GetKeyName(keyCode)
                Menu.SelectingKey = false
                return
            end
        end
        return
    end

    local toggleKeyCode = Menu.SelectedKey or 0x31
    if Menu.IsKeyJustPressed(toggleKeyCode) then
        Menu.Visible = not Menu.Visible
        if not Menu.Visible and Susano and Susano.ResetFrame then
            Susano.ResetFrame()
        end
        return
    end

    if not Menu.Visible then
        return
    end

    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        local currentTab = category and category.tabs and category.tabs[Menu.CurrentTab] or nil
        local items = currentTab and currentTab.items or {}

        if Menu.IsKeyJustPressed(0x26) then
            Menu.CurrentItem = Menu.CurrentItem - 1
            if Menu.CurrentItem < 1 then Menu.CurrentItem = #items end
            Menu.EnsureSelection()
        elseif Menu.IsKeyJustPressed(0x28) then
            Menu.CurrentItem = Menu.CurrentItem + 1
            if Menu.CurrentItem > #items then Menu.CurrentItem = 1 end
            Menu.EnsureSelection()
        elseif Menu.IsKeyJustPressed(0x41) or Menu.IsKeyJustPressed(0x51) then
            if Menu.CurrentTab > 1 then
                Menu.CurrentTab = Menu.CurrentTab - 1
                Menu.CurrentItem = 1
                Menu.ItemScrollOffset = 0
                Menu.EnsureSelection()
            end
        elseif Menu.IsKeyJustPressed(0x45) then
            if category and category.tabs and Menu.CurrentTab < #category.tabs then
                Menu.CurrentTab = Menu.CurrentTab + 1
                Menu.CurrentItem = 1
                Menu.ItemScrollOffset = 0
                Menu.EnsureSelection()
            end
        elseif Menu.IsKeyJustPressed(0x08) then
            Menu.OpenedCategory = nil
            Menu.CurrentItem = 1
            Menu.CurrentTab = 1
            Menu.ItemScrollOffset = 0
            return
        elseif Menu.IsKeyJustPressed(0x25) or Menu.IsKeyJustPressed(0x27) then
            local item = items[Menu.CurrentItem]
            if item then
                local goRight = Menu.IsKeyJustPressed(0x27)
                if item.type == "selector" and item.options and #item.options > 0 then
                    local idx = item.selected or 1
                    if goRight then
                        idx = idx + 1
                        if idx > #item.options then idx = 1 end
                    else
                        idx = idx - 1
                        if idx < 1 then idx = #item.options end
                    end
                    item.selected = idx
                    if item.onChange then item.onChange(idx, item.options[idx]) end
                elseif item.type == "slider" then
                    local step = item.step or 1
                    if goRight then
                        item.value = math.min(item.max or 100, (item.value or item.min or 0) + step)
                    else
                        item.value = math.max(item.min or 0, (item.value or item.min or 0) - step)
                    end
                    if item.onChange then item.onChange(item.value) end
                end
            end
        end

        if Menu.IsKeyJustPressed(0x0D) then
            local item = items[Menu.CurrentItem]
            if item and not item.isSeparator then
                if item.type == "toggle" then
                    item.value = not item.value
                    if item.onChange then item.onChange(item.value) end
                elseif item.type == "action" then
                    if item.onClick then item.onClick() end
                end
            end
        end

        return
    end

    if Menu.IsKeyJustPressed(0x26) then
        Menu.CurrentCategory = Menu.CurrentCategory - 1
        if Menu.CurrentCategory < 2 then Menu.CurrentCategory = #Menu.Categories end
    elseif Menu.IsKeyJustPressed(0x28) then
        Menu.CurrentCategory = Menu.CurrentCategory + 1
        if Menu.CurrentCategory > #Menu.Categories then Menu.CurrentCategory = 2 end
    elseif Menu.IsKeyJustPressed(0x0D) then
        local category = Menu.Categories[Menu.CurrentCategory]
        if category and category.hasTabs and category.tabs then
            Menu.OpenedCategory = Menu.CurrentCategory
            Menu.CurrentTab = 1
            Menu.CurrentItem = 1
            Menu.ItemScrollOffset = 0
            Menu.EnsureSelection()
        end
    end
end

Menu.Categories = {
    { name = "Simple Menu" },
    {
        name = "Self",
        hasTabs = true,
        tabs = {
            {
                name = "General",
                items = {
                    { isSeparator = true, separatorText = "SELF" },
                    {
                        name = "Menu Scale",
                        type = "slider",
                        min = 80,
                        max = 140,
                        step = 5,
                        value = 100,
                        onChange = function(value)
                            Menu.Scale = value / 100.0
                        end
                    },
                    {
                        name = "Smooth Factor",
                        type = "slider",
                        min = 5,
                        max = 40,
                        step = 1,
                        value = 20,
                        onChange = function(value)
                            Menu.SmoothFactor = value / 100.0
                        end
                    }
                }
            }
        }
    },
    {
        name = "Settings",
        hasTabs = true,
        tabs = {
            {
                name = "UI",
                items = {
                    { isSeparator = true, separatorText = "SETTINGS" },
                    {
                        name = "Menu Theme",
                        type = "selector",
                        options = { "Purple", "Red", "Gray", "Pink" },
                        selected = 1,
                        onChange = function(_, option)
                            Menu.ApplyTheme(option)
                        end
                    },
                    {
                        name = "Show Banner",
                        type = "toggle",
                        value = true,
                        onChange = function(value)
                            Menu.Banner.enabled = value == true
                        end
                    },
                    {
                        name = "Change Menu Keybind",
                        type = "action",
                        onClick = function()
                            Menu.SelectingKey = true
                        end
                    }
                }
            },
            {
                name = "About",
                items = {
                    { isSeparator = true, separatorText = "INFO" },
                    { name = "Simple clean working build", type = "action", onClick = function() end },
                    { name = "No troll functions included", type = "action", onClick = function() end }
                }
            }
        }
    }
}

Menu.ApplyTheme("Purple")
Menu.SelectedKeyName = Menu.GetKeyName(Menu.SelectedKey)

CreateThread(function()
    Menu.LoadingStartTime = GetGameTimer() or 0
    while Menu.IsLoading do
        local currentTime = GetGameTimer() or Menu.LoadingStartTime
        local elapsedTime = currentTime - Menu.LoadingStartTime
        Menu.LoadingProgress = clamp((elapsedTime / Menu.LoadingDuration) * 100.0, 0.0, 100.0)

        if Menu.LoadingProgress >= 100.0 then
            Menu.IsLoading = false
            Menu.LoadingComplete = true
            break
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        Menu.Render()
        if Menu.LoadingComplete then
            Menu.HandleInput()
        end
        Wait(0)
    end
end)

return Menu
