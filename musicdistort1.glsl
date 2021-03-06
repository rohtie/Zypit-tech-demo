float sphere (vec3 point, float radius) {
    return mix(length(point) - radius, length(max(abs(point)-vec3(0.2, 0.3, 3.0),0.0)), clamp(sin(iGlobalTime), 0.0, 0.5));
}

float map (vec3 point) {
    float angle = sin(iGlobalTime);
    point *= mat3(1.0, 0.0, 0.0,
                  0.0, cos(angle), -sin(angle),
                  0.0, sin(angle), cos(angle))

           * mat3(cos(angle), 0.0, sin(angle),
                  0.0, 1.0, 0.0,
                  -sin(angle), 0.0, cos(angle));

    // Works better for all songs
    return length(point) -
           smoothstep(
                0.0,
                1.0,
                texture(iChannel0, point.xx * point.yy * point.zz + 0.1).r
            ) * 0.5;

    // Works best for "experiment" song
    //return length(point) - clamp(0.0, 0.5, texture(iChannel0, point.xx * point.yy * point.zz + 0.1).r) * 1.25;
}

float intersect (vec3 rayOrigin, vec3 rayDirection) {
    const float maxDistance = 10.0;
    const float distanceTreshold = 0.001;
    const int maxIterations = 50;

    float distance = 0.0;
    float currentDistance = 1.0;

    for (int i = 0; i < maxIterations; i++) {
        if (currentDistance < distanceTreshold || distance > maxDistance) {
            break;
        }

        currentDistance = map(rayOrigin + rayDirection * distance);

        distance += currentDistance;
    }

    if (distance > maxDistance) {
        return -1.0;
    }

    return distance;
}

vec3 getNormal(vec3 point) {
    vec2 extraPolate = vec2(0.002, 0.0);

    return normalize(vec3(
        map(point + extraPolate.xyy),
        map(point + extraPolate.yxy),
        map(point + extraPolate.yyx)
    ) - map(point));
}

vec3 light = normalize(vec3(0.0, 2.0, 3.0));

void mainImage (out vec4 color, in vec2 point) {
    point /= iResolution.xy;
    point = 2.0 * point - 1.0;
    point.x *= iResolution.x / iResolution.y;

    vec3 cameraPosition = vec3(0.0, 0.0, 0.9);
    vec3 rayDirection = normalize(vec3(point, -1.0));

    float distance = intersect(cameraPosition, rayDirection);

    vec3 col = vec3(0.0);

    if (distance > 0.0) {
        vec3 point = cameraPosition + rayDirection * distance;
        vec3 normal = getNormal(point);

        col += vec3(0.05, 0.01, 0.35);
        col += vec3(0.7, 1.0, 0.95) * max(dot(normal, light), 0.0);

        vec3 halfVector = normalize(light + normal);
        col += vec3(1.0) * pow(max(dot(normal, halfVector), 0.0), 1024.0);
    }

    color.rgb = col;
}
