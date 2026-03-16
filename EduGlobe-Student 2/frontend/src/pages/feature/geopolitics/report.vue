<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>经纬瞰政 · 自动报告</h2>
      <button class="link" @click="exportAll">导出 Markdown</button>
    </header>
    <section>
      <textarea v-model="content" class="editor"></textarea>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
const content = ref(`# 分析报告（示例）

## 热点与知识映射
- 示例热点 A -> 章节 B
- 示例热点 C -> 章节 D

## 答题反馈
- 正确率：80%
- 盲区：锋面识别
`);

function exportAll() {
  const blob = new Blob([content.value], { type: 'text/markdown;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'geopolitics-report.md';
  a.click();
  URL.revokeObjectURL(a.href);
}
</script>

<style scoped>
.feature-page { padding: 16px; }
.editor {
  width: 100%;
  min-height: 360px;
  padding: 12px;
  border: 1px solid #eee;
  border-radius: 8px;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
}
</style>


