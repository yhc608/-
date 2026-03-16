<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>探索日志 · {{ scenarioName }}</h2>
    </header>
    <section class="layout">
      <div class="log">
        <h3>互动时间线</h3>
        <ul>
          <li v-for="item in logs" :key="item.id">
            <time>{{ item.time }}</time>
            <div>
              <strong>{{ item.title }}</strong>
              <p>{{ item.detail }}</p>
            </div>
          </li>
        </ul>
      </div>
      <aside class="summary">
        <h3>总结</h3>
        <textarea v-model="summary" placeholder="请输入对本次探索的反思与总结"></textarea>
      </aside>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';

type LogItem = {
  id: string;
  time: string;
  title: string;
  detail: string;
};

const logs = ref<LogItem[]>([
  { id: 'l1', time: '09:10', title: '进入火山坡面', detail: '观察到新鲜的熔岩流痕迹，记录海拔差异。' },
  { id: 'l2', time: '09:18', title: '分析喷发物', detail: '采集浮石样本并拍照上传，确认为安山岩质地。' },
  { id: 'l3', time: '09:30', title: '环境评估', detail: '评估下游居民点风险，提出临时疏散建议。' }
]);
const summary = ref('本次探索重点关注了火山喷发影响范围，对地貌演变及灾害防范提出建议。');

const scenarioName = computed(() => {
  const id = new URL(location.href).searchParams.get('id') || 's-volcano';
  return ({ 's-volcano': '火山喷发', 's-monsoon': '季风环流', 's-urban': '城市功能区' } as Record<string, string>)[id] || id;
});

</script>

<style scoped>
.feature-page {
  padding: 16px;
}
.layout {
  display: grid;
  grid-template-columns: minmax(320px, 2fr) minmax(240px, 1fr);
  gap: 20px;
}
.log {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  background: #f8fafc;
}
.log h3 {
  margin-top: 0;
}
.log ul {
  margin: 0;
  padding: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.log li {
  display: flex;
  gap: 16px;
  align-items: flex-start;
}
time {
  font-size: 12px;
  color: #2563eb;
  background: rgba(59, 130, 246, 0.1);
  padding: 4px 10px;
  border-radius: 999px;
}
.log strong {
  display: block;
}
.log p {
  margin: 4px 0 0;
  color: #475569;
  line-height: 1.6;
}
.summary {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: rgba(226, 232, 240, 0.6);
}
.summary textarea {
  width: 100%;
  min-height: 220px;
  border-radius: 12px;
  border: 1px solid #cbd5f5;
  padding: 12px;
  resize: vertical;
}
@media (max-width: 768px) {
  .layout {
    grid-template-columns: 1fr;
  }
}
</style>


