<template>
  <div class="feature-page">
    <header class="feature-header">
      <h2>情景互动 · 场景大厅</h2>
    </header>
    <SceneMap :items="scenarios" @enter="enter" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getTasks } from '../../../services/api';
import SceneMap from './components/SceneMap.vue';

const scenarios = ref<any[]>([]);

onMounted(async () => {
  try {
    const data = await getTasks();
    scenarios.value = data.scenarios || [];
  } catch (error) {
    console.error('加载场景数据失败:', error);
    scenarios.value = [];
  }
});

function enter(id: string) {
  history.pushState({}, '', `/feature/scenario/explore?id=${encodeURIComponent(id)}`);
  window.dispatchEvent(new PopStateEvent('popstate'));
}
</script>

<style scoped>
.feature-page { padding: 16px; }
</style>


