<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>引导式答疑</h2>
    </header>
    <section class="grid">
      <div class="box">
        <h3>你的问题</h3>
        <textarea v-model="q" placeholder="请输入地理问题，例如：为什么沿海地区更湿润？"></textarea>
        <button @click="buildTree">生成思维树</button>
      </div>
      <MindTree :data="tree" />
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import MindTree from './components/MindTree.vue';
const q = ref('');
const tree = ref<any>({ name: '问题', children: [] });

function buildTree() {
  tree.value = {
    name: q.value || '地理问题',
    children: [
      { name: '已知条件', children: [{ name: '纬度/海陆位置' }, { name: '季风/气压' }] },
      { name: '推理路径', children: [{ name: '热力环流' }, { name: '水汽输送' }] },
      { name: '结论', children: [{ name: '沿海更湿润' }] }
    ]
  };
}
</script>

<style scoped>
.feature-page { padding: 16px; }
textarea { width: 100%; min-height: 120px; padding: 8px; }
.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.box { border: 1px solid #eee; border-radius: 8px; padding: 12px; }
@media (max-width: 768px) { .grid { grid-template-columns: 1fr; } }
</style>


