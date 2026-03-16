<template>
  <div class="learning-report">
    <!-- 学习概览 -->
    <div class="overview card">
      <div class="section-header">
        <h3>学习概览</h3>
        <div class="time-selector">
          <button 
            v-for="period in ['周', '月', '学期']" 
            :key="period"
            :class="{ active: selectedPeriod === period }"
            class="btn-text"
            @click="selectedPeriod = period"
          >
            {{ period }}
          </button>
        </div>
      </div>

      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-value">{{ stats.learningTime }}</div>
          <div class="stat-label">学习时长</div>
          <div class="stat-trend up">
            <span class="material-icons">trending_up</span>
            较上{{ selectedPeriod }}增长12%
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ stats.completedTasks }}</div>
          <div class="stat-label">完成任务</div>
          <div class="stat-trend up">
            <span class="material-icons">trending_up</span>
            较上{{ selectedPeriod }}增长8%
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ stats.correctRate }}%</div>
          <div class="stat-label">正确率</div>
          <div class="stat-trend down">
            <span class="material-icons">trending_down</span>
            较上{{ selectedPeriod }}下降3%
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ stats.ranking }}</div>
          <div class="stat-label">班级排名</div>
          <div class="stat-trend up">
            <span class="material-icons">trending_up</span>
            较上{{ selectedPeriod }}提升2名
          </div>
        </div>
      </div>
    </div>

    <!-- 知识掌握 -->
    <div class="knowledge-mastery card">
      <div class="section-header">
        <h3>知识掌握</h3>
        <button class="btn-text" @click="showKnowledgeDetail">
          查看详情
          <span class="material-icons">chevron_right</span>
        </button>
      </div>

      <div class="mastery-chart" ref="masteryChart"></div>

      <div class="weak-points">
        <h4>薄弱知识点</h4>
        <div class="points-list">
          <div 
            v-for="point in weakPoints" 
            :key="point.id"
            class="point-item"
            @click="startReview(point)"
          >
            <div class="point-info">
              <div class="point-name">{{ point.name }}</div>
              <div class="point-meta">
                <span class="mastery">掌握度 {{ point.mastery }}%</span>
                <span class="chapter">{{ point.chapter }}</span>
              </div>
            </div>
            <button class="btn-text">
              开始复习
              <span class="material-icons">play_circle</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 学习建议 -->
    <div class="learning-suggestions card">
      <div class="section-header">
        <h3>学习建议</h3>
      </div>

      <div class="suggestions-list">
        <div 
          v-for="suggestion in suggestions" 
          :key="suggestion.id"
          class="suggestion-item"
        >
          <div class="suggestion-icon">
            <span class="material-icons" :style="{ color: suggestion.color }">
              {{ suggestion.icon }}
            </span>
          </div>
          <div class="suggestion-content">
            <div class="suggestion-title">{{ suggestion.title }}</div>
            <div class="suggestion-desc">{{ suggestion.description }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 学习时段分析 -->
    <div class="time-analysis card">
      <div class="section-header">
        <h3>学习时段分析</h3>
      </div>

      <div class="time-chart" ref="timeChart"></div>

      <div class="time-insights">
        <div class="insight-item">
          <span class="material-icons">schedule</span>
          <div class="insight-content">
            <div class="insight-title">最佳学习时段</div>
            <div class="insight-value">19:00 - 21:00</div>
          </div>
        </div>
        <div class="insight-item">
          <span class="material-icons">timer</span>
          <div class="insight-content">
            <div class="insight-title">平均单次时长</div>
            <div class="insight-value">45分钟</div>
          </div>
        </div>
        <div class="insight-item">
          <span class="material-icons">auto_graph</span>
          <div class="insight-content">
            <div class="insight-title">效率最高时段</div>
            <div class="insight-value">上午9:00 - 10:00</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts/core'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import { RadarChart, BarChart } from 'echarts/charts'
import { CanvasRenderer } from 'echarts/renderers'

echarts.use([
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  RadarChart,
  BarChart,
  CanvasRenderer
])

const router = useRouter()
const selectedPeriod = ref('周')
const masteryChart = ref<HTMLElement | null>(null)
const timeChart = ref<HTMLElement | null>(null)

// 模拟数据
const stats = ref({
  learningTime: '12.5h',
  completedTasks: 28,
  correctRate: 85,
  ranking: 6
})

const weakPoints = ref([
  {
    id: 'w1',
    name: '地球运动',
    mastery: 65,
    chapter: '自然地理'
  },
  {
    id: 'w2',
    name: '气压带和风带',
    mastery: 70,
    chapter: '自然地理'
  }
])

const suggestions = ref([
  {
    id: 's1',
    icon: 'schedule',
    color: '#1890ff',
    title: '合理安排学习时间',
    description: '建议将重点学习时间安排在上午9-10点，这是你的最佳学习效率时段。'
  },
  {
    id: 's2',
    icon: 'psychology',
    color: '#52c41a',
    title: '针对性复习',
    description: '地球运动相关知识点掌握度较低，建议重点复习太阳高度角计算方法。'
  },
  {
    id: 's3',
    icon: 'timer',
    color: '#faad14',
    title: '调整学习节奏',
    description: '单次学习时长建议控制在45分钟内，注意适时休息，保持专注度。'
  }
])

// 初始化知识掌握雷达图
function initMasteryChart() {
  if (!masteryChart.value) return
  
  const chart = echarts.init(masteryChart.value)
  const option = {
    radar: {
      indicator: [
        { name: '自然地理', max: 100 },
        { name: '人文地理', max: 100 },
        { name: '区域地理', max: 100 },
        { name: '地理技能', max: 100 },
        { name: '地理实践', max: 100 }
      ],
      radius: '65%'
    },
    series: [{
      type: 'radar',
      data: [{
        value: [85, 90, 75, 95, 80],
        name: '知识掌握度',
        areaStyle: {
          color: 'rgba(24, 144, 255, 0.2)'
        },
        lineStyle: {
          color: '#1890ff'
        },
        itemStyle: {
          color: '#1890ff'
        }
      }]
    }]
  }
  
  chart.setOption(option)
}

// 初始化学习时段柱状图
function initTimeChart() {
  if (!timeChart.value) return
  
  const chart = echarts.init(timeChart.value)
  const option = {
    xAxis: {
      type: 'category',
      data: ['6-8', '8-10', '10-12', '14-16', '16-18', '19-21', '21-23']
    },
    yAxis: {
      type: 'value',
      name: '学习时长(小时)'
    },
    series: [{
      data: [1.5, 2.8, 2.0, 1.2, 1.8, 2.5, 0.7],
      type: 'bar',
      itemStyle: {
        color: '#1890ff'
      }
    }]
  }
  
  chart.setOption(option)
}

// 查看知识点详情
function showKnowledgeDetail() {
  router.push('/review/knowledge-detail')
}

// 开始复习
function startReview(point: any) {
  router.push(`/review/practice/${point.id}`)
}

// 监听时间周期变化
watch(selectedPeriod, () => {
  // TODO: 根据选择的时间周期更新数据
})

onMounted(() => {
  initMasteryChart()
  initTimeChart()
  
  // 响应窗口大小变化
  window.addEventListener('resize', () => {
    if (masteryChart.value) {
      echarts.getInstanceByDom(masteryChart.value)?.resize()
    }
    if (timeChart.value) {
      echarts.getInstanceByDom(timeChart.value)?.resize()
    }
  })
})
</script>

<style scoped lang="scss">
.learning-report {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

.card {
  margin-bottom: var(--spacing-base);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);

  h3 {
    margin: 0;
  }

  .time-selector {
    display: flex;
    gap: var(--spacing-small);
    background: #f5f5f5;
    padding: 4px;
    border-radius: 20px;

    .btn-text {
      padding: 4px 12px;
      border-radius: 16px;

      &.active {
        background: white;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }
    }
  }
}

// 统计卡片网格
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-base);
}

.stat-card {
  background: #f9f9f9;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  text-align: center;

  .stat-value {
    font-size: 1.5em;
    font-weight: 500;
    margin-bottom: 4px;
  }

  .stat-label {
    color: var(--color-text-secondary);
    margin-bottom: 8px;
  }

  .stat-trend {
    font-size: 0.9em;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;

    &.up {
      color: #52c41a;
    }

    &.down {
      color: #ff4d4f;
    }

    .material-icons {
      font-size: 1em;
    }
  }
}

// 知识掌握
.mastery-chart {
  height: 300px;
  margin-bottom: var(--spacing-base);
}

.weak-points {
  h4 {
    margin: 0 0 var(--spacing-base);
    color: var(--color-text-secondary);
  }
}

.points-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.point-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  .point-info {
    flex: 1;
  }

  .point-name {
    margin-bottom: 4px;
  }

  .point-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);
  }

  .btn-text {
    color: var(--color-primary);
    display: flex;
    align-items: center;
    gap: 4px;

    .material-icons {
      font-size: 1.2em;
    }
  }
}

// 学习建议
.suggestions-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.suggestion-item {
  display: flex;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  .suggestion-icon {
    width: 40px;
    height: 40px;
    background: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .suggestion-content {
    flex: 1;
  }

  .suggestion-title {
    font-weight: 500;
    margin-bottom: 4px;
  }

  .suggestion-desc {
    color: var(--color-text-secondary);
    font-size: 0.9em;
    line-height: 1.5;
  }
}

// 时间分析
.time-chart {
  height: 250px;
  margin-bottom: var(--spacing-base);
}

.time-insights {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
}

.insight-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  .material-icons {
    color: var(--color-primary);
  }

  .insight-title {
    color: var(--color-text-secondary);
    font-size: 0.9em;
    margin-bottom: 2px;
  }

  .insight-value {
    font-weight: 500;
  }
}

// 适配大字体模式
:global(.large-text) {
  .suggestion-desc,
  .point-meta,
  .insight-title {
    font-size: 1em;
  }

  .stat-value {
    font-size: 1.6em;
  }
}

:global(.xlarge-text) {
  .suggestion-desc,
  .point-meta,
  .insight-title {
    font-size: 1.1em;
  }

  .stat-value {
    font-size: 1.8em;
  }
}
</style>
