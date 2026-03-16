<template>
  <div class="experiment-page">
    <header class="page-header">
      <button class="back-btn" @click="$router.back()">← 返回</button>
      <div class="header-title">
        <h2>{{ config?.name || '加载中...' }}</h2>
        <p class="experiment-info">
          <span>{{ config?.knowledgeModule }}</span>
          <span>·</span>
          <span>{{ config?.textbookChapter }}</span>
        </p>
      </div>
      <button class="result-btn" @click="goToResult">查看结果 →</button>
    </header>

    <div class="experiment-layout">
      <!-- 左侧变量控制面板 -->
      <aside class="control-panel">
        <VariableControlPanel
          :variables="variables"
          v-model="variableValues"
          @update:modelValue="handleVariableChange"
          @start="onStart"
        />
      </aside>

      <!-- 右侧实验场景 -->
      <main class="scene-area">
        <ExperimentScene
          :id="expId"
          :values="variableValues"
          ref="sceneRef"
          @showPrinciple="showPrinciple = true"
        />
      </main>
    </div>

    <!-- 实验原理弹窗 -->
    <PrinciplePopup
      v-if="config"
      :visible="showPrinciple"
      :principle="config.principle"
      @close="showPrinciple = false"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getExperiments } from '../../../services/api'
import VariableControlPanel from './components/VariableControlPanel.vue'
import ExperimentScene from './components/ExperimentScene.vue'
import PrinciplePopup from './components/PrinciplePopup.vue'

const route = useRoute()
const router = useRouter()

const expId = ref<string>('')
const config = ref<any>(null)
const variableValues = ref<Record<string, string | number>>({})
const showPrinciple = ref(false)
const sceneRef = ref<any>(null)

const variables = computed(() => {
  return config.value?.variables || []
})

onMounted(async () => {
  // 从 URL 获取实验 ID
  const id = route.query.id as string
  if (id) {
    expId.value = id
  } else {
    expId.value = 'heat_circulation' // 默认实验
  }

  // 加载实验配置
  try {
    const data = await getExperiments()
    const experiment = data.experiments?.find((exp: any) => exp.id === expId.value)
    if (experiment) {
      config.value = experiment
      // 初始化变量值
      const initialValues: Record<string, string | number> = {}
      experiment.variables?.forEach((variable: any) => {
        if (variable.default !== undefined) {
          initialValues[variable.key] = variable.default
        }
      })
      variableValues.value = initialValues
      // 如需自动开始（来自列表点击）
      if (route.query.autoStart === '1') {
        // 等待下一帧确保子组件挂载
        requestAnimationFrame(() => onStart())
      }
    } else {
      console.error('未找到实验配置:', expId.value)
    }
  } catch (error) {
    console.error('加载实验配置失败:', error)
  }
})

function handleVariableChange(values: Record<string, string | number>) {
  variableValues.value = { ...values }
}

function goToResult() {
  router.push({
    path: '/feature/cyberlab/result',
    query: { id: expId.value },
  })
}

function onStart() {
  sceneRef.value?.start?.()
}
</script>

<style scoped>
.experiment-page {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--color-bg-primary) 0%, #E6F0F7 100%);
  padding: var(--spacing-base);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-large);
  padding: var(--spacing-base);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  box-shadow: var(--shadow-base);
  flex-wrap: wrap;
  gap: var(--spacing-base);
}

.back-btn,
.result-btn {
  padding: var(--spacing-small) var(--spacing-base);
  background: var(--color-bg-tertiary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  color: var(--color-text-primary);
  font-size: 14px;
  cursor: pointer;
  transition: var(--transition-base);
  white-space: nowrap;
}

.back-btn:hover,
.result-btn:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.result-btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: white;
  border: none;
  box-shadow: 0 2px 8px rgba(123, 107, 82, 0.3);
}

.result-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(123, 107, 82, 0.4);
}

.header-title {
  flex: 1;
  text-align: center;
}

.header-title h2 {
  margin: 0 0 var(--spacing-small) 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.experiment-info {
  margin: 0;
  font-size: 13px;
  color: var(--color-text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-small);
}

.experiment-layout {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: var(--spacing-base);
  align-items: start;
}

.control-panel {
  position: sticky;
  top: var(--spacing-base);
}

.scene-area {
  min-height: 600px;
}

@media (max-width: 1024px) {
  .experiment-layout {
    grid-template-columns: 280px 1fr;
  }
}

@media (max-width: 768px) {
  .experiment-page {
    padding: var(--spacing-small);
  }

  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .header-title {
    text-align: left;
  }

  .experiment-layout {
    grid-template-columns: 1fr;
  }

  .control-panel {
    position: static;
  }

  .scene-area {
    min-height: 400px;
  }
}
</style>
