precision mediump float;

uniform float u_time;
uniform float u_blocks;
uniform vec2 u_resolution;
uniform vec2 u_textureResolution;
uniform sampler2D u_texture;

uniform vec2 u_mouse;

varying vec2 v_texcoord;

vec2 getAspectRatio(vec2 uv, float canvas_ratio, float texture_ratio) {
    //stretch the image as needed
    if(texture_ratio > canvas_ratio) {
        //image is wider than canvas
        float ratio_diff = canvas_ratio/texture_ratio;
        uv.x *= ratio_diff;
        uv.x += (1.0 - ratio_diff) / 2.0;
    } else {
        float ratio_diff = texture_ratio/canvas_ratio;
        uv.x *= ratio_diff;
        uv.x += (1.0 - ratio_diff) / 2.0;
    }
    return uv;
}

void main(void)
{
    vec2 uv = v_texcoord;
    
    //get aspect ratios
    float canvas_ratio = u_resolution.x/u_resolution.y;
    float texture_ratio = u_textureResolution.x/u_textureResolution.y;
    uv = getAspectRatio(uv, canvas_ratio, texture_ratio);

    //have a safe border around the image to distort into / zoom the image in
    uv = mix(vec2(0.1), vec2(0.9), uv);

    //get mouse position relative to canvas coords
    vec2 mouse = u_mouse/u_resolution;

    //sample block instead of individual pixel
    vec2 block = vec2(
        floor(uv.x * u_blocks)/u_blocks,
        floor(uv.y * u_blocks)/u_blocks
    );

    vec2 distortion = 0.1 * vec2(
        sin(u_time*0.3 + block.x*5.0 + block.y*2.0 + mouse.x*2.0+mouse.y*0.6), 
        cos(u_time*0.2 + block.x*5.5 + block.y*2.5 + mouse.x*0.5+mouse.y*1.5)
        );

    vec4 textureColor = texture2D(u_texture, uv + distortion);
    
    gl_FragColor = textureColor;
}