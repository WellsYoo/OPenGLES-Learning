precision highp float;

uniform sampler2D inputImageTexture;

varying vec4 inputColor;
varying vec2 textureCoordinate;

void main()
{
    lowp vec4 color = texture2D(inputImageTexture,textureCoordinate);
    gl_FragColor = color;
}
