extends RigidBody

#is the player currently dragging a cube
var isDragging = false
#mouse offset to cube grid
var z = 0

var camera



func _ready():
    camera = get_viewport().get_camera()

func _input_event(camera, event, click_position, click_normal, shape_idx):
    #get the position if on the cube was clicked
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT:
            if event.pressed:
                print(click_position)
                isDragging = true

func _input(event):
    #when the left button is released let the cube drop
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT:
            if !event.pressed:
                print("released")
                isDragging = false

func _physics_process(delta):

    #move the cube when it was clicked and the button is stille being pressed
    if(isDragging):
        # get the mouse movement on a plane
        var position2D = get_viewport().get_mouse_position()
        var dropPlane  = Plane(Vector3(0, 0, 10), z)
        var position3D = dropPlane.intersects_ray(camera.project_ray_origin(position2D),camera.project_ray_normal(position2D))
        #round the calculated coordinates to move the cube on a grid
        position3D = Vector3(int(round(position3D.x)),
                            int(round(position3D.y)),
                            0)
        #set the cube to the rounded mouse position
        var t = get_transform()
        t.origin = position3D
        set_transform(t)
