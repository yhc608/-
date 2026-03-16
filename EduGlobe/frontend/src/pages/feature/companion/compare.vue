<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>名师 vs 学生 · 思维对比</h2>
    </header>
    <CompareView :teacher="teacher" :student="student" teacher-label="名师思维树" student-label="学生思维树" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getResources } from '../../../services/api';
import CompareView from './components/CompareView.vue';

const teacher = ref<any>({ name: '加载中', children: [] });
const student = ref<any>({ name: '加载中', children: [] });

onMounted(async () => {
  const data = await getResources();
  teacher.value = data.mind.teacher;
  student.value = data.mind.student;
});
</script>

