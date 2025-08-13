Config = {}

Config.Consumables = {
    Eat = { -- default food items
        ['bread'] = {
            item = 'bread',
            hunger = 25,
            thirst = 0,
            stress = 5,
            propname = 'p_bread_14_ab_s_a',
            poison = 15,
            poisonRate = 0.4,
        },
    },
    Drink = { -- default drink items
        ['water'] = {
            item = 'water',
            hunger = 0,
            thirst = 25,
            stress = 5,
            alcohol = -10,
            propname = 'p_bottlebeer01a'
        },
        ['beer'] = {
            item = 'beer',
            hunger = 0,
            thirst = 0,
            stress = 65,
            alcohol = 8,
            propname = 'p_bottlebeer01a'
        },
        ['moonshine_jug'] = {
            item = 'moonshine_jug',
            hunger = 0,
            thirst = 0,
            stress = -45,
            alcohol = 65,
            propname = 'p_masonjarmoonshine01x'
        },
    },
    Stew = { -- default stew items
        ['stew'] = {
            item = 'stew',
            hunger = 50,
            thirst = 25,
            stress = 20,
            propname = 'p_bowl04x_stew'
       },
    },
    Hotdrinks = { -- default hot drink items
        ['coffee'] = {
            item = 'coffee',
            hunger = 0,
            thirst = 25,
            stress = 20,
            alcohol = -10,
        },
    },
    Eatcanned = { -- canned food items
        ['canned_apricots'] = {
            item = 'canned_apricots',
            hunger = 50,
            thirst = 20,
            stress = 10,
            propname = 's_canrigapricots01x',
        },
    },
}

-- Alchol System Configuration
Config.AlcoholSystem = {
    DrunkThreshold = 50,      -- Drunk threshold (when effects start)
    PassOutThreshold = 200,   -- Stage where player passes out
    WakeUpLevel = 55,         -- Level upon waking up (just below drunk threshold)
    DecreaseAmount = 1,       -- Points removed per cycle
    DecreaseInterval = 5000,  -- Decrease interval (ms)
    MaxAlcoholLevel = 500,    -- Maximum level (safety)
}

-- Visual Effects Configuration
Config.AlcoholEffects = {
    DrunkEffect = true,
    DrunkEffectName = "PlayerDrunk01",
    PassOutEffect = "PlayerDrunk01_PassOut",
    WakeUpEffect = "PlayerWakeUpDrunk",
    VomitDuration = 10000,
    SleepDuration = 30000,
    FadeOutDuration = 10000,
    FadeInDuration = 10000,
    
    -- Notifications
    DrunkNotification = {
        title = '🍺 Drunk',
        description = 'You feel drunk...',
        type = 'inform',
        duration = 3000,
        position = 'top-right'
    },
    PassOutNotification = {
        title = '💀 Fainting',
        description = 'You pass out!',
        type = 'error',
        duration = 5000,
        position = 'top-right'
    },
    SoberNotification = {
        title = '✨ Recovery',
        description = 'You regain your senses.',
        type = 'success',
        duration = 2000,
        position = 'top-right'
    }
}