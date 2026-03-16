export async function getHotspots() {
  const mod = await import('../mock/hotspots.json');
  return mod.default;
}

export async function getExperiments() {
  const mod = await import('../mock/experiments.json');
  return mod.default;
}

export async function getTasks() {
  const mod = await import('../mock/tasks.json');
  return mod.default;
}

export async function getResources() {
  const mod = await import('../mock/resources.json');
  return mod.default;
}

export async function getAvatars() {
  const mod = await import('../mock/avatars.json');
  return mod.default;
}


