// Creates cached canvas-based text sprites for node and edge labels.
import * as THREE from 'three';

const EDGE_LABEL_HEIGHT = 28;
const EDGE_LABEL_FONT_SIZE = 13;
const EDGE_LABEL_SCALE = 0.004;
const NODE_LABEL_HEIGHT = 28;
const NODE_LABEL_FONT_SIZE = 13;
const NODE_LABEL_SCALE = 0.004;

const CANVAS_TEXT_PADDING = 6;
const LABEL_RENDER_ORDER = 4;

const FONT_WEIGHT_BOLD = 'bold ';
const labelTextureCache = new Map();

/** Disposes all cached label textures and clears the cache. */
export function clearLabelCache() {
  for (const { texture } of labelTextureCache.values()) {
    texture.dispose();
  }
  labelTextureCache.clear();
}

/** Creates a canvas-rendered text sprite, using a texture cache for repeat labels. */
export function createTextSprite(text, { fontSize, height, scale, color, bold }) {
  const cacheKey = `${text}:${fontSize}:${color}`;
  if (labelTextureCache.has(cacheKey)) {
    const cached = labelTextureCache.get(cacheKey);
    const mat = new THREE.SpriteMaterial({
      map: cached.texture,
      transparent: true,
      depthTest: false,
    });
    const sprite = new THREE.Sprite(mat);
    sprite.scale.set(cached.width * scale, height * scale, 1);
    sprite.renderOrder = LABEL_RENDER_ORDER;
    return sprite;
  }

  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  const weight = bold ? FONT_WEIGHT_BOLD : '';
  const font = `${weight}${fontSize}px sans-serif`;
  ctx.font = font;
  const metrics = ctx.measureText(text);
  const padding = CANVAS_TEXT_PADDING;
  const w = Math.ceil(metrics.width) + padding * 2;
  canvas.width = w;
  canvas.height = height;

  ctx.font = font;
  ctx.fillStyle = color;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(text, w / 2, height / 2);

  const texture = new THREE.CanvasTexture(canvas);
  texture.minFilter = THREE.LinearFilter;
  labelTextureCache.set(cacheKey, { texture, width: w });

  const material = new THREE.SpriteMaterial({ map: texture, transparent: true, depthTest: false });
  const sprite = new THREE.Sprite(material);
  sprite.scale.set(w * scale, height * scale, 1);
  sprite.renderOrder = 4;
  return sprite;
}

/** Creates a semi-transparent text sprite for edge relationship labels. */
export function createEdgeLabelSprite(text, darkMode = true) {
  return createTextSprite(text, {
    fontSize: EDGE_LABEL_FONT_SIZE,
    height: EDGE_LABEL_HEIGHT,
    scale: EDGE_LABEL_SCALE,
    color: darkMode ? 'rgba(255, 255, 255, 0.5)' : 'rgba(0, 0, 0, 0.6)',
    bold: false,
  });
}

/** Creates a bold text sprite for node name labels. */
export function createNodeLabelSprite(text, darkMode = true, sizeMultiplier = 1) {
  return createTextSprite(text, {
    fontSize: NODE_LABEL_FONT_SIZE,
    height: NODE_LABEL_HEIGHT,
    scale: NODE_LABEL_SCALE * sizeMultiplier,
    color: darkMode ? 'rgba(255, 255, 255, 0.85)' : 'rgba(0, 0, 0, 0.85)',
    bold: true,
  });
}
