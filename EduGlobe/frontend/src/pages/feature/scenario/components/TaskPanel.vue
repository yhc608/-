<template>
  <div class="panel">
    <header>
      <h3>任务进度</h3>
      <span class="score">总分 {{ totalScore }}</span>
    </header>
    <ul>
      <li
        v-for="item in tasks"
        :key="item.id"
        :class="{ done: completed.includes(item.id) }"
        @click="toggle(item.id)"
      >
        <div>
          <h4>{{ item.title }}</h4>
          <p>分值 {{ item.score }}</p>
        </div>
        <span class="status">{{ completed.includes(item.id) ? '已完成' : '待完成' }}</span>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  tasks: Array<{ id: string; title: string; score: number }>;
  completed: string[];
}>();
const emit = defineEmits<{ (e: 'update:completed', ids: string[]): void }>();

const totalScore = computed(() => props.tasks.reduce((sum, t) => sum + (props.completed.includes(t.id) ? t.score : 0), 0));

function toggle(id: string) {
  const next = props.completed.includes(id)
    ? props.completed.filter((item) => item !== id)
    : [...props.completed, id];
  emit('update:completed', next);
}
</script>

<style scoped>
.panel {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  background: rgba(241, 245, 249, 0.82);
  display: flex;
  flex-direction: column;
  gap: 12px;
}
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
li {
  border: 1px solid #cbd5f5;
  border-radius: 12px;
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  transition: background 0.2s ease, transform 0.2s ease;
}
li:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-2px);
}
li.done {
  background: rgba(134, 239, 172, 0.25);
  border-color: rgba(22, 163, 74, 0.45);
}
h4 {
  margin: 0 0 4px;
}
p {
  margin: 0;
  color: #6b7280;
  font-size: 14px;
}
.status {
  font-size: 14px;
  color: #2563eb;
}
</style>


