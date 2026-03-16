<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>本地化地理资源</h2>
    </header>
    <LocalDataPanel v-if="local" :data="local" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getResources } from '../../../services/api';
import LocalDataPanel from './components/LocalDataPanel.vue';
const local = ref<any>(null);
onMounted(async () => {
  const data = await getResources();
  local.value = data.local;
});
</script>

