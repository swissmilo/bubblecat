void main(void)
{
    vec2 uv = v_tex_coord;
    //vec2 uv = gl_FragCoord.xy / size.xy;

    vec4 val = texture2D(u_texture, uv);

    /*if(val.a == 0.0) {
        gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    } else {
        gl_FragColor = vec4(0.0,1.0,0.0,1.0);
    }*/
    
    //gl_FragColor = vec4(color.r,color.g,color.b,1.0);
    if(val.a == 0.0) {
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
    } else {
        gl_FragColor = vec4(0.2 + val.a * color.r * 2.0, 0.2 + val.a * color.g * 2.0, 0.2 + val.a * color.b * 2.0,val.a);
    }
}