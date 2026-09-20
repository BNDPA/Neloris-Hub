-- Загрузка библиотеки Obsidian UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianUI/Obsidian/main/Source.lua"))()

-- Создание окна системы ключа
local KeyWindow = Library:CreateWindow({
    Name = "NelorisHubFree | Key System",
    Theme = "Dark"
})

local KeyTab = KeyWindow:AddTab("Авторизация")

-- Распределение ключей и соответствующих им файлов
local ValidKeys = {
    ["NelorisHubFree"] = "Hub.lua",
    ["NelorisHub.cc_7h66k5"] = "HubCC.lua",
    ["NelorisHub.cc_jc727k"] = "HubCC.lua",
    ["NelorisHub.cc_01421"] = "HubCC.lua",
    ["NelorisHub.cc_3757b"] = "HubCC.lua",
    ["NelorisHub.cc_3774j"] = "HubCC.lua"
}

local EnteredKey = ""

-- Поле ввода ключа
KeyTab:AddTextbox({
    Name = "Введите ключ",
    Placeholder = "Вставьте ключ сюда...",
    Callback = function(value)
        EnteredKey = value
    end
})

-- Кнопка проверки ключа
KeyTab:AddButton({
    Name = "Проверить ключ",
    Callback = function()
        local targetFile = ValidKeys[EnteredKey]
        
        if targetFile then
            Library:Notify({
                Title = "Успешно!",
                Content = "Ключ принят. Загрузка " .. targetFile .. "...",
                Duration = 3
            })
            
            -- Закрываем окно ключа
            KeyWindow:Close()
            
            -- Загружаем и запускаем нужный файл из репозитория BNDPA/NelorisHub
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/BNDPA/NelorisHub/main/" .. targetFile))()
            end)
            
            if not success then
                warn("Не удалось загрузить " .. targetFile .. ": " .. tostring(err))
            end
        else
            Library:Notify({
                Title = "Ошибка",
                Content = "Неверный ключ! Попробуйте ещё раз.",
                Duration = 3
            })
        end
    end
})
