@tool
extends Control

@onready var pie_char_texture_rect: TextureRect = %PieChartTextureRect
@onready var labels_parent_anchor: Control = %LabelsParentAnchor

@export var tag_array:Array[String] = ["apple", "banana", "grape", "orange", "watermelon"]:
    get:
        return tag_array
    set(value):
        tag_array = value
        refresh_params()
@export var value_array:Array[float] = [30, 40, 10, 10, 10]:
    get:
        return value_array
    set(value):
        value_array = value
        refresh_params()
@export var color_array:Array[Color] = [Color(1, 0, 0, 1), Color(0, 1, 0, 1), Color(0, 0, 1, 1), Color(0, 0, 0, 1), Color(0, 0, 0, 1)]:
    get:
        return color_array
    set(value):
        color_array = value
        refresh_params()
@export_range(0, 1) var relative_size: float = 0.4:
    get:
        return relative_size
    set(value):
        relative_size = value
        refresh_params()
@export var label_radius_bias: int = 0:
    get:
        return label_radius_bias
    set(value):
        label_radius_bias = value
        refresh_params()

@export var label_font_size: int = 32:
    get:
        return label_font_size
    set(value):
        label_font_size = value
        refresh_params()

@export_range(-2 * PI, 2 * PI) var label_rotate_bias_angle:float = 0:
    get:
        return label_rotate_bias_angle
    set(value):
        label_rotate_bias_angle = value
        refresh_params()

@export var label_center_anchor_bias: Vector2 = Vector2(0, 0):
    get:
        return label_center_anchor_bias
    set(value):
        label_center_anchor_bias = value
        refresh_params()

@export var designated_index_rotate_bias: Array[float] = [0, 0, 0, 0, 0]:
    get:
        return designated_index_rotate_bias
    set(value):
        designated_index_rotate_bias = value
        refresh_params()

@export var label_font: Font = null:
    get:
        return label_font
    set(value):
        label_font = value
        refresh_params()

@export var font_color:Color = Color(0, 0, 0, 1):
    get:
        return font_color
    set(value):
        font_color = value
        refresh_params()


var using_share_num:int
var normalized_share_list:Array[float]
var each_part_midpoint_angle_list:Array[float]

func _ready() -> void:
    refresh_params()

func refresh_params() -> void:
    self.using_share_num = len(tag_array)
    normalized_share_list = []
    var total_value:float = 0
    for i in range(len(value_array)):
        total_value += value_array[i]
    for i in range(len(value_array)):
        normalized_share_list.append(value_array[i] / total_value)

    each_part_midpoint_angle_list = []
    var start_angle:float = 0
    var end_angle:float = 0
    for i in range(len(normalized_share_list)):
        end_angle = start_angle
        start_angle += normalized_share_list[i] * 2 * PI
        each_part_midpoint_angle_list.append((start_angle + end_angle) / 2 - 0.5 * PI)

    draw()


func draw() -> void:
    if pie_char_texture_rect:
        var material:ShaderMaterial = pie_char_texture_rect.material

        # Set the number of colors (e.g., 3 will use the first 3 elements of the arrays)
        material.set_shader_parameter("using_share_num", self.using_share_num)

        # Set the colors array. Even if you use only 3 colors, you must provide all 5 entries.
        material.set_shader_parameter("colors", self.color_array)

        # Set the shares array (only the first (num_colors - 1) elements are used)
        material.set_shader_parameter("shares", normalized_share_list)

        # Set the relative size and blur strength
        material.set_shader_parameter("relative_size", relative_size)
        material.set_shader_parameter("blur_strength", 0.01)

        for child in labels_parent_anchor.get_children():
            labels_parent_anchor.remove_child(child)
        
        for i in range(self.using_share_num):
            var separate_anchor:Control = Control.new()
            labels_parent_anchor.add_child(separate_anchor)
            separate_anchor.set_position(label_center_anchor_bias)
            var percentage_string:String = str(round(normalized_share_list[i] * 100)) + "%"
            var label:Label = Label.new()
            label.set_text(tag_array[i] + "\n" + percentage_string)
            label.set_horizontal_alignment(1)
            label.set_vertical_alignment(1)
            label.set_size(Vector2(1, 1))
            label.add_theme_font_size_override("font_size", label_font_size)
            label.set_custom_minimum_size(Vector2(100, 20))
            separate_anchor.add_child(label)
            label.position = Vector2(
                cos(each_part_midpoint_angle_list[i]) * relative_size * label_radius_bias, 
                sin(each_part_midpoint_angle_list[i]) * relative_size * label_radius_bias
            )


            separate_anchor.rotation = label_rotate_bias_angle
            if len(designated_index_rotate_bias) > i and designated_index_rotate_bias[i]:
                separate_anchor.rotation += designated_index_rotate_bias[i]

            label.rotation = -separate_anchor.rotation
            
            if label_font:
                label.add_theme_font_override("font", label_font)
            
            label.add_theme_color_override("font_color", font_color)
            label.global_position -= label.get_size() / 2

            # draw a line between the label and the labels_parent_anchor
            var line:Line2D = Line2D.new()
            line.add_point(label.get_global_position())
            line.add_point(labels_parent_anchor.get_global_position())


func _process(delta) -> void:
    pass
