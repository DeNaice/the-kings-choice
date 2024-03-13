shader_type canvas_item;
const float baseValue = 0.6;
const float blueness = 0.3;
const float factorSin = 0.1;
const float rateOfChange = 6.0;
uniform bool isActive = false;


void vertex() {
	
	// Called for every vertex the material is visible on.
}

void fragment() {
	float timeFactor = factorSin * sin(TIME*rateOfChange);
	if (isActive)
	COLOR = vec4(baseValue-timeFactor,baseValue-timeFactor,baseValue+blueness-timeFactor,1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
