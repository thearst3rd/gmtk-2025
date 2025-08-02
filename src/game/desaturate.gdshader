shader_type canvas_item;

uniform float desaturation_amount = 0.0;
uniform float opacity = 1.0;

void vertex() {

}

void fragment() {
	COLOR.r = COLOR.r + (1.0 - COLOR.r) * desaturation_amount;
	COLOR.g = COLOR.g + (1.0 - COLOR.g) * desaturation_amount;
	COLOR.b = COLOR.b + (1.0 - COLOR.b) * desaturation_amount;
	COLOR.a = min(COLOR.a, opacity);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
