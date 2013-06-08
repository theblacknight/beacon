extern vec3 light_pos;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
   float distance = length(light_pos - vec3(pixel_coords, 0));

   if(distance < 100) {
      return texture2D(texture, texture_coords) * vec4(1.3, 1.3, 1.0, distance * 0.005);
   }
   return texture2D(texture, texture_coords);
}