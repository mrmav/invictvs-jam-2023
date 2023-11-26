local genisys = require("genisys")

local game = genisys.create_application("game")

game.name = "Croccantini Game Bundle"
game.version = "0.0.91"
game.fullscreen = true
game.description = "First bundle to test monitors layout."
game.thumbnail = genisys.get_path("thumbnail.png")

local launcher = game:create_process()
launcher.command = { genisys.get_path("launcher.x86_64"), "--rendering-driver", "opengl3"}

return game
