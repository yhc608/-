<template>
  <div class="feature-page">
    <header class="feature-header">
      <h2>AI地理伴学 · 学情总览</h2>
      <nav class="links">
        <button class="link" @click="$router.push('/feature/companion/question')">引导答疑</button>
        <button class="link" @click="$router.push('/feature/companion/compare')">思维对比</button>
        <button class="link" @click="$router.push('/feature/companion/resource')">本地资源</button>
      </nav>
    </header>
    <section class="grid">
      <ProgressRadar :overview="overview" />
      <div class="box">
        <h3>认知盲区</h3>
        <ul><li v-for="w in overview.weakness" :key="w">· {{ w }}</li></ul>
        <h3>能力短板</h3>
        <ul><li v-for="s in overview.shortboard" :key="s">· {{ s }}</li></ul>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getResources } from '../../../services/api';
import ProgressRadar from './components/ProgressRadar.vue';

const overview = ref<any>({ progress:{ class:0, you:0 }, weakness:[], shortboard:[] });

onMounted(async () => {
  const data = await getResources();
  overview.value = data.overview;
});
</script>

<style scoped>
.feature-page { padding: 16px; }
.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.box { border: 1px solid #eee; border-radius: 8px; padding: 12px; }
@media (max-width: 768px) { .grid { grid-template-columns: 1fr; } }
</style>


