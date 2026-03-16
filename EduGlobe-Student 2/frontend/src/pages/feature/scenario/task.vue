<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>任务与成就 · {{ scenario?.name || '加载中' }}</h2>
    </header>
    <section v-if="scenario" class="layout">
      <TaskPanel
        :tasks="scenario.tasks"
        v-model:completed="completed"
      />
      <aside class="knowledge">
        <h3>知识要点</h3>
        <ul>
          <li v-for="k in scenario.knowledge" :key="k.point">
            <strong>{{ k.point }}</strong>
            <p>{{ k.desc }}</p>
          </li>
        </ul>
        <div class="achievements">
          <h3>成就奖励</h3>
          <p>完成所有任务即可解锁“情景大师”徽章。</p>
          <p>最高分：{{ maxScore }} 分</p>
        </div>
      </aside>
    </section>
    <p v-else class="empty">正在加载任务...</p>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { getTasks } from '../../../services/api';
import TaskPanel from './components/TaskPanel.vue';

type ScenarioTask = {
  id: string;
  name: string;
  tasks: Array<{ id: string; title: string; score: number }>;
  knowledge: Array<{ point: string; desc: string }>;
};

const scenario = ref<ScenarioTask | null>(null);
const completed = ref<string[]>([]);

const maxScore = computed(() => scenario.value?.tasks.reduce((sum, t) => sum + t.score, 0) ?? 0);

onMounted(async () => {
  try {
    const data = await getTasks();
    const id = new URL(location.href).searchParams.get('id') || 'volcano_observation';
    scenario.value = (data.scenarios || []).find((item: ScenarioTask) => item.id === id) || data.scenarios?.[0];
  } catch (error) {
    console.error('加载任务数据失败:', error);
  }
});

function completedScore() {
  if (!scenario.value) return 0;
  return scenario.value.tasks.reduce((sum, t) => {
    return sum + (completed.value.includes(t.id) ? t.score : 0);
  }, 0);
}
</script>

<style scoped>
.feature-page {
  padding: 16px;
}
.layout {
  display: grid;
  grid-template-columns: minmax(280px, 1fr) minmax(260px, 0.9fr);
  gap: 20px;
}
.knowledge {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  background: #f8fafc;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.knowledge h3 {
  margin: 0;
}
.knowledge ul {
  padding: 0;
  margin: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.knowledge li {
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(148, 163, 184, 0.18);
}
.knowledge li strong {
  display: block;
  margin-bottom: 4px;
}
.knowledge li p {
  margin: 0;
  color: #475569;
  font-size: 14px;
  line-height: 1.5;
}
.achievements {
  border-radius: 12px;
  padding: 12px;
  background: rgba(99, 102, 241, 0.12);
  color: #312e81;
}
.achievements h3 {
  margin: 0 0 8px;
}
.empty {
  color: #94a3b8;
  text-align: center;
}
@media (max-width: 768px) {
  .layout {
    grid-template-columns: 1fr;
  }
}
</style>


