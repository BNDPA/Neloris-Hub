-- Загрузка библиотеки Obsidian UI (популярный шаблон для майнкрафт/роблокс эксплоитов)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianUI/Obsidian/main/Source.lua"))()

-- Создание окна системы ключа
local KeyWindow = Library:CreateWindow({
    Name = "Neloris Hub | Key System",
    Theme = "Dark",
    Logo = "rbxassetid://0000000000" -- Замени при необходимости на свой кастомный ID иконки
})

local KeyTab = KeyWindow:AddTab("Авторизация")

local CorrectKey = "NelorisHub.cc_278283"
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
        if EnteredKey == CorrectKey then
            Library:Notify({
                Title = "Успешно!",
                Content = "Ключ принят. Добро пожаловать в Neloris Hub!",
                Duration = 3
            })
            
            -- Закрываем окно ключа и открываем основной интерфейс читов/хаба
            KeyWindow:Close()
            CreateMainHub()
        else
            Library:Notify({
                Title = "Ошибка",
                Content = "Неверный ключ! Попробуйте ещё раз.",
                Duration = 3
            })
        end
    end
})

-- Функция основного меню хаба (появляется после ввода ключа)
function CreateMainHub()
    local MainWindow = Library:CreateWindow({
        Name = "Neloris Hub | Main",
        Theme = "Dark"
    })

    local MainTab = MainWindow:AddTab("Главная")

    MainTab:AddLabel("Добро пожаловать в Neloris Hub!")
    
    MainTab:AddButton({
        Name = "Пример функции",
        Callback = function()
            print("Функция активирована!")
        end
    })
end
