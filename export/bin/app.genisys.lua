local genisys = require("genisys")

local game = genisys.create_application("game")

game.name = "CROCCANTINI - 13 PUNCH MAN"
game.version = "0.9.99"
game.fullscreen = true
game.description = "Croccantini game entry for the INVICTVS GAME JAM 2023."
game.thumbnail = genisys.get_path("icon.png")
game.cover = genisys.get_path("cover.png")

local launcher = game:create_process()
launcher.command = { genisys.get_path("launcher.x86_64"), "--rendering-driver", "opengl3"}

return game
