void main(void)
{
    vec2 uv = v_tex_coord;
    //vec2 uv = gl_FragCoord.xy / size.xy;
    
    uv.y += (cos((uv.y + (u_time * 0.05)) * 85.0) * 0.0015) +
    (cos((uv.y + (u_time * 0.04)) * 10.0) * 0.002);
    
    uv.x += (sin((uv.y + (u_time * 0.10)) * 55.0) * 0.0015) +
    (sin((uv.y + (u_time * 0.04)) * 15.0) * 0.002);
    
    
    vec4 texColor = texture2D(customTexture,uv);
    gl_FragColor = texColor;
}