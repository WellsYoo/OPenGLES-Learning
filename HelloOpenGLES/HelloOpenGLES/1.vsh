attribute vec3 position;
attribute vec4 color;

varying vec4 inputColor;

void main()
{
    gl_Position = vec4(position, 1.0);
    inputColor = color;
}
