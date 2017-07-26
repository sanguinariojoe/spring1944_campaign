-- Author: Jose Luis Cercos-Pita
-- License: GNU General Public License v3

gadget.config = {
    teams = {
        [1] = { -- Player
            ally = 0,
            faction = "us",
            color = {0.0, 0.5, 0.0},
            units = { -- nil to use the default ones
            },
        },
        [2] = {
            ally = 1,
            faction = "ger",
            color = {0.3, 0.3, 0.3},
            units = { -- nil to use the default ones
            },
        },
    },
}

gadget.missions = {
    -- Machine guns
    -- ============
    [1] = {
        events = {  -- Ensure they are sorted in time
            {0, [[CreateUnit("usparatrooper", 300, 250, 100, "south", 1)]]},
            {0, [[SyncedFunction("LoadUnits", {'LuaRules/Configs/gerunits.lua', config.teams[2].teamID})]]},
        },

        triggers = {
            { -- Setup the paratrooper data (see LuaRules/Gadgets/game_paratroopers.lua)
             [[#FilterUnitsByName(Spring.GetTeamUnits(Spring.GetMyTeamID()), "usparatrooper") > 0]],
             [[local u = FilterUnitsByName(Spring.GetTeamUnits(Spring.GetMyTeamID()), "usparatrooper")[1]
               SyncedFunction("Spring.MoveCtrl.Enable", {u})
               SyncedFunction("Spring.MoveCtrl.SetPosition", {u, 300, 250, 100})
               SyncedFunction("Spring.MoveCtrl.SetVelocity", {u, 0.1, 0, 0.1})
               SyncedFunction("Spring.MoveCtrl.SetGravity", {u, 1})
               SyncedFunction("Spring.MoveCtrl.SetWindFactor", {u, 0.025})
               SyncedFunction("Spring.MoveCtrl.SetDrag", {u, 0.06})
               SyncedFunction("Spring.MoveCtrl.SetTrackGround", {u, true})
               SyncedFunction("Spring.MoveCtrl.SetCollideStop", {u, true})
               SyncedFunction("Spring.MoveCtrl.SetRelativeVelocity",
                    {u, (math.random() - 0.5) * 0.25,
                        (math.random() - 0.5),
                        (math.random() - 0.5) * 0.25})
               _G["Ryan"] = u]],
             once = true
            },
            { -- Replace him when arrives the ground (see LuaRules/Gadgets/game_paratroopers.lua)
             [[_G["Ryan"] ~= nil]],  -- Execute this code every single frame
             [[local x, y, z = Spring.GetUnitPosition(_G["Ryan"])
               local groundHeight = Spring.GetGroundHeight(x, z)
               if y <= groundHeight then
                   CreateUnit("uspararifle", x, groundHeight, z, "south", 1)
                   SyncedFunction("Spring.DestroyUnit", {_G["Ryan"], false, true})
                   _G["Ryan"] = nil
                   Success()
               end]],
             once = false
            },
        },
        callins = {
        },
    },
}
