<template>
  <div class="scene-map">
    <article
      v-for="item in items"
      :key="item.id"
      class="scene-card"
      @click="() => emit('enter', item.id)"
    >
      <header>
        <h3>{{ item.name }}</h3>
        <span class="tag">{{ tagText(item.id) }}</span>
      </header>
      <p class="desc">
        {{ summary(item) }}
      </p>
      <footer>
        <button class="link">进入探索</button>
      </footer>
    </article>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  items: Array<{ id: string; name: string; tasks?: any[]; knowledge?: any[] }>
}>();
const emit = defineEmits<{ (e: 'enter', id: string): void }>();

function tagText(id: string) {
  if (id.includes('volcano')) return '火山';
  if (id.includes('monsoon')) return '季风';
  if (id.includes('urban')) return '城市';
  return '探索';
}

function summary(item: any) {
  const knowledge = (item.knowledge || [])
    .map((k: any) => k.point)
    .slice(0, 2)
    .join('、');
  return knowledge ? `聚焦知识：${knowledge}` : '点击进入场景';
}
</script>

<style scoped>
.scene-map {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
}
.scene-card {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.08), rgba(103, 194, 58, 0.08));
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.scene-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 24px rgba(64, 158, 255, 0.18);
}
.scene-card header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.scene-card h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}
.tag {
  font-size: 12px;
  color: #409eff;
  background: rgba(64, 158, 255, 0.12);
  border-radius: 999px;
  padding: 2px 10px;
}
.desc {
  flex: 1;
  color: #4b5563;
  margin: 0 0 16px;
  line-height: 1.6;
}
.scene-card footer {
  display: flex;
  justify-content: flex-end;
}
.link {
  border: none;
  background: #409eff;
  color: #fff;
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 14px;
}
@media (max-width: 768px) {
  .scene-map {
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  }
}
</style>


