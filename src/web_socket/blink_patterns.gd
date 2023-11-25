extends SocketServiceMessage

func _init():	
	id = "v1/hardware/outputs/add_blink_patterns"
	payload = [
	  {
		"group": "croccantini",
		"patterns": [
		  {
			"frames": [
			  {
				"duration": 300000,
				"outputs": [
				  "bet_2", "play_8", "play_18", "bet_6", "play_88", "play_68", "bet_1", "bet_10", "play"
				]
			  }
			],
			"id": "menu_pattern"
		  },
		  {
			"frames": [
			  {
				"duration": 300000,
				"outputs": [
				  17
				]
			  }
			],
			"id": "light_tower_red"
		  },
		  {
			"frames": [
			  {
				"duration": 300000,
				"outputs": [
				  21
				]
			  }
			],
			"id": "light_tower_green"
		  }
		]
	  }
	]
