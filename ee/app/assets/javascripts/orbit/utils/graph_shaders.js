// GLSL vertex and fragment shaders for graph node markers, edge impulses,
// globe atmosphere, and city lights.

// Renders graph nodes as circular point sprites with soft glow edge.
export const NODE_VERTEX_SHADER = `
  attribute vec3 color;
  attribute float size;
  varying vec3 vColor;
  uniform float pixelRatio;
  void main() {
    vColor = color;
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = size * pixelRatio;
    gl_Position = projectionMatrix * mvPosition;
  }
`;

export const NODE_FRAGMENT_SHADER = `
  varying vec3 vColor;
  uniform float darkMode;
  void main() {
    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) discard;
    float body = 1.0 - smoothstep(0.36, 0.39, dist);
    // Dark mode: subtle bright glow. Light mode: thin dark border.
    float ring = smoothstep(0.33, 0.36, dist) * (1.0 - smoothstep(0.39, 0.42, dist));
    vec3 ringColor = darkMode > 0.5 ? vColor * 1.3 : vColor * 0.4;
    float ringAlpha = darkMode > 0.5 ? 0.15 : 0.5;
    vec3 col = mix(ringColor, vColor, body);
    float alpha = max(body, ring * ringAlpha);
    gl_FragColor = vec4(col, alpha);
  }
`;

// Renders animated impulse particles traveling along edges.
export const IMPULSE_VERTEX_SHADER = `
  uniform float pixelRatio;
  uniform float size;
  void main() {
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = size * pixelRatio;
    gl_Position = projectionMatrix * mvPosition;
  }
`;

export const IMPULSE_FRAGMENT_SHADER = `
  uniform vec3 color;
  void main() {
    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) discard;
    float glow = 1.0 - smoothstep(0.0, 0.5, dist);
    gl_FragColor = vec4(color, glow);
  }
`;

// Renders the globe's atmospheric glow on the back face (dark mode).
export const ATMOSPHERE_VERTEX_SHADER = `
  varying vec3 vNormal;
  void main() {
    vNormal = normalize(normalMatrix * normal);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`;

export const ATMOSPHERE_FRAGMENT_SHADER = `
  varying vec3 vNormal;
  void main() {
    float rim = pow(0.7 - dot(vNormal, vec3(0.0, 0.0, 1.0)), 2.5);
    vec3 warmGlow = vec3(0.95, 0.6, 0.3);
    vec3 coolGlow = vec3(0.4, 0.3, 0.8);
    vec3 color = mix(warmGlow, coolGlow, rim);
    gl_FragColor = vec4(color, 1.0) * rim * 0.4;
  }
`;

// Light mode atmosphere: soft purple/blue rim glow
export const ATMOSPHERE_LIGHT_FRAGMENT_SHADER = `
  varying vec3 vNormal;
  void main() {
    float rim = pow(0.7 - dot(vNormal, vec3(0.0, 0.0, 1.0)), 2.5);
    vec3 color = mix(vec3(0.6, 0.4, 0.9), vec3(0.9, 0.55, 0.4), rim);
    gl_FragColor = vec4(color, rim * 0.35);
  }
`;

// Light mode globe surface: gradient from warm white to cool lavender
export const GRID_VERTEX_SHADER = `
  varying vec3 vNormal;
  varying vec3 vPosition;
  void main() {
    vNormal = normalize(normalMatrix * normal);
    vPosition = position;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`;

export const GRID_FRAGMENT_SHADER = `
  varying vec3 vNormal;
  varying vec3 vPosition;
  void main() {
    float fresnel = 1.0 - max(dot(vNormal, vec3(0.0, 0.0, 1.0)), 0.0);
    // Richer base: soft peach top to saturated lavender bottom
    float yFactor = (vPosition.y + 5.0) / 10.0;
    vec3 peach = vec3(0.95, 0.91, 0.88);
    vec3 lavender = vec3(0.85, 0.82, 0.94);
    vec3 base = mix(lavender, peach, yFactor);
    // Strong rim darkening for 3D depth
    vec3 rimColor = vec3(0.72, 0.68, 0.82);
    vec3 color = mix(base, rimColor, fresnel * fresnel * 0.8);
    gl_FragColor = vec4(color, 1.0);
  }
`;

// Renders scattered city-light particles on the globe surface.
export const CITY_LIGHT_VERTEX_SHADER = `
  attribute float size;
  attribute vec3 color;
  varying vec3 vColor;
  uniform float pixelRatio;
  void main() {
    vColor = color;
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = size * pixelRatio * (300.0 / -mvPosition.z);
    gl_Position = projectionMatrix * mvPosition;
  }
`;

export const CITY_LIGHT_FRAGMENT_SHADER = `
  varying vec3 vColor;
  void main() {
    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) discard;
    float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
    gl_FragColor = vec4(vColor, alpha * 0.8);
  }
`;
