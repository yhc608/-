<template>
  <div class="cyberlab-page">
    <header class="page-header">
      <div class="header-content">
        <h1>🧪 赛博实验</h1>
        <p class="page-subtitle">虚拟地理实验平台 - 通过高仿真可视化交互场景探索地理原理</p>
      </div>
    </header>
    <ExperimentSelector :items="experiments" @start="startExperiment" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { getExperiments } from '../../../services/api'
import ExperimentSelector from './components/ExperimentSelector.vue'

const router = useRouter()
const experiments = ref<any[]>([])

onMounted(async () => {
  try {
    const data = await getExperiments()
    experiments.value = data.experiments || []
  } catch (error) {
    console.error('加载实验数据失败:', error)
    experiments.value = []
  }
})

function startExperiment(id: string) {
  router.push({
    path: '/feature/cyberlab/experiment',
    query: { id, autoStart: '1' },
  })
}
</script>

<style scoped>
.cyberlab-page {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--color-bg-primary) 0%, #E8F4EA 100%);
  padding: var(--spacing-base);
}

.page-header {
  margin-bottom: var(--spacing-large);
  text-align: center;
}

.header-content h1 {
  margin: 0 0 var(--spacing-small) 0;
  font-size: 32px;
  font-weight: 700;
  color: var(--color-text-primary);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-forest) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  margin: 0;
  font-size: 14px;
  color: var(--color-text-secondary);
  line-height: 1.6;
}

@media (max-width: 768px) {
  .cyberlab-page {
    padding: var(--spacing-small);
  }

  .header-content h1 {
    font-size: 24px;
  }

  .page-subtitle {
    font-size: 12px;
  }
}
</style>
