<template>
  <div class="result-page">
    <header class="page-header">
      <button class="back-btn" @click="$router.back()">← 返回</button>
      <div class="header-title">
        <h2>实验结果分析</h2>
        <p class="experiment-name">{{ config?.name || '实验' }}</p>
      </div>
    </header>

    <div class="result-content">
      <!-- 数据可视化图表 -->
      <section class="chart-section">
        <ResultChart :experiment-id="expId" />
      </section>

      <!-- 数据分析与解读 -->
      <section class="analysis-section">
        <div class="analysis-card">
          <h3>📊 数据分析</h3>
          <div class="analysis-content">
            <div v-for="(item, index) in analysisItems" :key="index" class="analysis-item">
              <div class="analysis-header">
                <span class="analysis-icon">{{ item.icon }}</span>
                <span class="analysis-title">{{ item.title }}</span>
              </div>
              <p class="analysis-text">{{ item.content }}</p>
            </div>
          </div>
        </div>

        <div class="principle-card">
          <h3>📘 实验原理</h3>
          <p class="principle-text">{{ config?.principle || '暂无原理说明' }}</p>
        </div>

        <div class="conclusion-card">
          <h3>💡 实验结论</h3>
          <ul class="conclusion-list">
            <li v-for="(conclusion, index) in conclusions" :key="index">
              {{ conclusion }}
            </li>
          </ul>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getExperiments } from '../../../services/api'
import ResultChart from './components/ResultChart.vue'

const route = useRoute()
const router = useRouter()

const expId = ref<string>('')
const config = ref<any>(null)

// 分析项目
const analysisItems = computed(() => {
  if (!config.value) return []

  if (expId.value === 'heat_circulation') {
    return [
      {
        icon: '🌡️',
        title: '温度差异影响',
        content:
          '热源温度越高，上升气流速度越快，环流范围越大。冷源温度越低，下沉气流越明显，形成更完整的循环系统。',
      },
      {
        icon: '💨',
        title: '环流形成机制',
        content:
          '热源处空气受热膨胀上升，形成低压区；冷源处空气冷却收缩下沉，形成高压区。水平方向上空气从高压流向低压，形成闭合环流。',
      },
      {
        icon: '🔬',
        title: '空间密闭性',
        content:
          '密闭空间有利于形成完整的环流系统，开放空间会受到外部气流干扰，影响环流的稳定性。',
      },
    ]
  } else if (expId.value === 'atmospheric_insulation') {
    return [
      {
        icon: '☀️',
        title: '光照影响',
        content:
          '光照强度直接影响初始升温速度。强光照下，两组温度上升更快，但保温效果的差异在夜间更加明显。',
      },
      {
        icon: '🌡️',
        title: '保温机制',
        content:
          '大气对地面长波辐射有较强的吸收能力。白天吸收热量增温，夜间以长波辐射形式向地面释放热量，起到保温作用。',
      },
      {
        icon: '📈',
        title: '浓度影响',
        content:
          '大气浓度越高，对长波辐射的吸收和释放能力越强，保温效果越明显。这解释了为什么高海拔地区昼夜温差大。',
      },
    ]
  } else if (expId.value === 'soil_erosion') {
    return [
      {
        icon: '🌱',
        title: '植被保护作用',
        content:
          '植被通过根系固定土壤，叶片减缓雨滴冲击力，可显著降低水土流失量。植被覆盖度越高，保护效果越好。',
      },
      {
        icon: '⛰️',
        title: '坡度影响',
        content:
          '坡度越大，水流速度越快，冲击力越大，侵蚀越严重。30°以上的陡坡需要更强的保护措施。',
      },
      {
        icon: '🌧️',
        title: '降水强度',
        content:
          '降水强度直接影响径流速度和侵蚀能力。暴雨条件下，即使有植被保护，也可能发生严重的水土流失。',
      },
      {
        icon: '🏔️',
        title: '土壤性质',
        content:
          '黏质土壤由于颗粒细小、结构紧密，抗侵蚀能力最强。砂质土壤结构松散，最容易被冲刷。',
      },
    ]
  }

  return []
})

// 实验结论
const conclusions = computed(() => {
  if (!config.value) return []

  if (expId.value === 'heat_circulation') {
    return [
      '热力环流是由于地面冷热不均而形成的空气环流现象',
      '温度差异越大，环流强度越大，范围越广',
      '密闭空间有利于形成稳定的环流系统',
      '这一原理解释了海陆风、山谷风等自然现象的形成',
    ]
  } else if (expId.value === 'atmospheric_insulation') {
    return [
      '大气对地面具有保温作用，主要通过吸收和释放长波辐射实现',
      '大气浓度越高，保温效果越明显',
      '夜间保温效果比白天更明显，这解释了为什么高海拔地区昼夜温差大',
      '这一原理是理解温室效应和全球气候变化的基础',
    ]
  } else if (expId.value === 'soil_erosion') {
    return [
      '水土流失是多种因素共同作用的结果，包括植被、坡度、降水和土壤性质',
      '植被覆盖是最有效的保护措施，可以显著降低流失量',
      '坡度越大、降水越强，水土流失越严重',
      '合理规划土地利用，加强植被保护，是防治水土流失的关键',
    ]
  }

  return []
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
    }
  } catch (error) {
    console.error('加载实验配置失败:', error)
  }
})

</script>

<style scoped>
.result-page {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--color-bg-primary) 0%, #F7F0E6 100%);
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

.back-btn {
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

.back-btn:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
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

.experiment-name {
  margin: 0;
  font-size: 14px;
  color: var(--color-text-secondary);
}

.result-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-large);
}

.chart-section {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
}

.analysis-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-base);
}

.analysis-card,
.principle-card,
.conclusion-card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
}

.analysis-card h3,
.principle-card h3,
.conclusion-card h3 {
  margin: 0 0 var(--spacing-base) 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
  padding-bottom: var(--spacing-small);
  border-bottom: 2px solid var(--color-primary);
}

.analysis-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.analysis-item {
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border-left: 4px solid var(--color-primary);
}

.analysis-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-small);
}

.analysis-icon {
  font-size: 20px;
}

.analysis-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.analysis-text {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.principle-text {
  margin: 0;
  font-size: 14px;
  line-height: 1.8;
  color: var(--color-text-primary);
  text-align: justify;
}

.conclusion-list {
  margin: 0;
  padding-left: var(--spacing-large);
  list-style-type: disc;
}

.conclusion-list li {
  margin-bottom: var(--spacing-small);
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.conclusion-list li:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .result-page {
    padding: var(--spacing-small);
  }

  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .header-title {
    text-align: left;
  }

  .analysis-section {
    grid-template-columns: 1fr;
  }
}
</style>
