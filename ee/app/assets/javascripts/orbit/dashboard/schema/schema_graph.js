import { formatNumber } from '~/locale';
import { ENTITY_TYPE_ICONS, DEFAULT_NODE_COLOR } from 'ee/orbit/constants';
import { SCHEMA_DOMAINS } from './constants';

export const VIEWBOX_CENTER = 50;
const RING_START_ANGLE = -90;
const INNER_RING_SCALE = 0.75;

function entityStyle(node) {
  return {
    name: node.name,
    icon: ENTITY_TYPE_ICONS[node.name.toLowerCase()] || null,
    color: node.style?.color || DEFAULT_NODE_COLOR,
  };
}

export function normalizeSchema(schema) {
  return { ...schema, nodes: schema.nodes || [], edges: schema.edges || [] };
}

export function schemaDomains({ nodes }) {
  const domains = [...new Set(nodes.map((node) => node.domain))];
  const knownDomains = SCHEMA_DOMAINS.filter((domain) => domains.includes(domain.key));
  const unknownDomains = domains
    .filter((key) => !SCHEMA_DOMAINS.some((domain) => domain.key === key))
    .sort()
    .map((key) => ({ key, label: key }));

  return [...knownDomains, ...unknownDomains].map((domain) => {
    const entities = nodes.filter((node) => node.domain === domain.key).map(entityStyle);
    const entry =
      entities.find((entity) => entity.name.toLowerCase() === domain.entryType) || entities[0];

    return {
      key: domain.key,
      label: domain.label,
      icon: domain.icon || entry.icon,
      color: entry.color,
      entryEntity: entry.name,
      entities,
    };
  });
}

export function filterDomains(domains, search) {
  const term = search.trim().toLowerCase();
  if (!term) return domains;

  return domains
    .map((domain) =>
      domain.label.toLowerCase().includes(term)
        ? domain
        : {
            ...domain,
            entities: domain.entities.filter((entity) => entity.name.toLowerCase().includes(term)),
          },
    )
    .filter((domain) => domain.entities.length);
}

export function itemCount(itemCounts, name) {
  return itemCounts?.[name.toLowerCase()] ?? null;
}

export function formatItemCount(itemCounts, name) {
  const count = itemCount(itemCounts, name);
  return count === null ? '' : formatNumber(count);
}

export function entityRelationships({ nodes, edges }, name) {
  const nodeNames = new Set(nodes.map((node) => node.name));
  const variants = edges
    .flatMap((edge) =>
      (edge.variants || []).map((variant) => ({
        edge: edge.name,
        description: edge.description,
        source: variant.source_type,
        target: variant.target_type,
      })),
    )
    .filter(({ source, target }) => nodeNames.has(source) && nodeNames.has(target));

  return {
    outgoing: variants
      .filter(({ source }) => source === name)
      .map(({ edge, description, target }) => ({ edge, description, entity: target })),
    incoming: variants
      .filter(({ source, target }) => target === name && source !== name)
      .map(({ edge, description, source }) => ({ edge, description, entity: source })),
  };
}

export function groupByEntity(relationships) {
  const groups = relationships.reduce((map, { entity, edge, description }) => {
    const edges = map.get(entity) || new Map();
    return map.set(entity, edges.set(edge, description));
  }, new Map());

  return [...groups.entries()].map(([entity, edges]) => ({
    entity,
    edges: [...edges.entries()].map(([edge, description]) => ({ name: edge, description })),
  }));
}

export function entityNeighbors({ domains, relationships, name }) {
  const { outgoing, incoming } = relationships;
  const others = [...outgoing, ...incoming].filter(({ entity }) => entity !== name);
  const ordered = domains.flatMap((domain) => domain.entities);
  const rank = (entityName) => ordered.findIndex((entity) => entity.name === entityName);

  return groupByEntity(others)
    .map((group) => ({ ...ordered[rank(group.entity)], edges: group.edges }))
    .sort((a, b) => rank(a.name) - rank(b.name));
}

export function ringPositions(count, radius, { alternate = false } = {}) {
  return Array.from({ length: count }, (_, index) => {
    const angle = ((360 / count) * index + RING_START_ANGLE) * (Math.PI / 180);
    const ringRadius = alternate && index % 2 ? radius * INNER_RING_SCALE : radius;
    return {
      x: VIEWBOX_CENTER + Math.cos(angle) * ringRadius,
      y: VIEWBOX_CENTER + Math.sin(angle) * ringRadius,
    };
  });
}

export function scaleFromCenter({ x, y }, factor) {
  return {
    x: VIEWBOX_CENTER + (x - VIEWBOX_CENTER) * factor,
    y: VIEWBOX_CENTER + (y - VIEWBOX_CENTER) * factor,
  };
}

export function placementStyle({ x, y }) {
  return { left: `${x}%`, top: `${y}%` };
}
