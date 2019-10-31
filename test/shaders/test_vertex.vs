#version 330

layout (location=0) in vec2 position;
layout (location=1) in vec3 colour;

out vec4 fColour;

uniform mat2 PVWMatrix;
uniform vec2 offset;
uniform float colourShift;
uniform int screenwidth;

void main() {
    vec2 pos = PVWMatrix * (offset + position);
    gl_Position = vec4(pos, screenwidth, 1.0);
    fColour = vec4(colour * colourShift, 1.0);
}
