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
            alcohol = -5,
            propname = 'p_bottlebeer01a'
        },
        ['beer'] = {
            item = 'beer',
            hunger = -3,
            thirst = 0,
            stress = -10,
            alcohol = 25,
            propname = 'p_bottlebeer01a'
        },
    },
    Stew = { -- default stew items
        ['stew'] = {
            item = 'stew',
            hunger = 50,
            thirst = 25,
            stress = 20,
            alcohol = -10,
            propname = 'p_bowl04x_stew'
       },
    },
    Hotdrinks = { -- default hot drink items
        ['coffee'] = {
            item = 'coffee',
            hunger = 0,
            thirst = 25,
            stress = 20,
            alcohol = -15,
        },
    },
    Eatcanned = { -- canned food items
        ['canned_apricots'] = {
            item = 'canned_apricots',
            hunger = 50,
            thirst = 20,
            stress = 10,
            alcohol = -3,
            propname = 's_canrigapricots01x',
        },
    },
}

-- AlcoholSystem Configuration
Config.AlcoholSystem = {
    DrunkThreshold = 50,      -- Threshold to be considered drunk
    PassOutThreshold = 200,   -- Threshold to pass out
    WakeUpLevel = 55,         -- Alcohol level upon waking up (just below the drunk threshold)
    DecreaseAmount = 1,       -- Points removed per cycle
    DecreaseInterval = 5000,  -- Decrement interval (in ms)
    MaxAlcoholLevel = 500,    -- Maximum alcohol level (safety)
}

Config.AlcoholEffects = {
    -- Visual Effects Configuration
    DrunkEffect = true,                                 -- Enable or disable the drunk post-fx effect
    DrunkEffectName = "PlayerDrunk01",                  -- The name of the visual effect for being drunk
    PassOutEffect = "PlayerDrunk01_PassOut",            -- The name of the visual effect for passing out
    WakeUpEffect = "PlayerWakeUpDrunk",                 -- The name of the visual effect for waking up
    GroggyEffectName = "PlayerHealthPoorCS",            -- The visual effect for the hangover/groggy state

    -- Timings & Durations (in milliseconds)
    GroggyDuration = 15000,                             -- How long the hangover state lasts after waking up (ms)
    VomitDuration = 10000,                              -- How long the vomit animation plays (ms)
    SleepDuration = 20000,                              -- How long the character sleeps on the ground (ms)
    FadeOutDuration = 10000,                            -- Duration of the screen fading to black (ms)
    FadeInDuration = 10000,                             -- Duration of the screen fading back in (ms)

    -- Notifications (Translated to English)
    DrunkNotification = {
        title = '🍺 Drunk',
        description = 'You start feeling tipsy...',
        type = 'inform',
        duration = 3000,
        position = 'top-right'
    },
    PassOutNotification = {
        title = '💀 Feeling Unwell',
        description = 'You don’t feel so good...',
        type = 'error',
        duration = 5000,
        position = 'top-right'
    },
    WakeUpNotification = {
        title = '🤕 Rough Awakening',
        description = 'You wake up with a terrible headache...',
        type = 'inform',
        duration = 5000,
        position = 'top-right'
    },
    SoberNotification = {
        title = '✨ Recovered',
        description = 'You feel clear-headed again.',
        type = 'success',
        duration = 2000,
        position = 'top-right'
    }
}
