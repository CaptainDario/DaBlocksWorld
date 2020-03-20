extends AudioStreamPlayer

var tracks = []

func _ready():
	randomize()
	
	self.tracks.append("res://music/01_imagine.ogg")
	self.tracks.append("res://music/02_Tetanus.ogg")
	self.tracks.append("res://music/03_Flora.ogg")
	self.tracks.append("res://music/04_spheres.ogg")
	self.tracks.append("res://music/05_cascades.ogg")

func _process(delta):
	if(self.is_playing() == false):
		print("new track")
		self.tracks.shuffle()
		self.stream = load(self.tracks.front())
		self.play()

