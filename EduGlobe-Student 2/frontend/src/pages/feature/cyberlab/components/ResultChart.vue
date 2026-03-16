<template>
  <div class="result-chart">
    <div class="chart-container" ref="chartContainer"></div>
    <div v-if="comparisonData" class="comparison-summary">
      <h4>对比分析</h4>
      <div class="summary-items">
        <div v-for="(item, index) in summaryItems" :key="index" class="summary-item">
          <span class="summary-label">{{ item.label }}：</span>
          <span :class="['summary-value', item.trend]">
            {{ item.value }}
            <span v-if="item.arrow" class="trend-arrow">{{ item.arrow }}</span>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts'
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'

interface ComparisonData {
  control: number[]
  experiment: number[]
  labels: string[]
  controlLabel: string
  experimentLabel: string
  unit: string
}

const props = defineProps<{
  experimentId: string
  comparisonData?: ComparisonData
  timeSeries?: Array<{ time: string; control: number; experiment: number }>
}>()

const chartContainer = ref<HTMLDivElement | null>(null)
let chart: echarts.ECharts | null = null
const comparisonData = ref<ComparisonData | null>(null)
const summaryItems = ref<Array<{ label: string; value: string; trend: string; arrow?: string }>>([])

// 生成模拟数据
function generateMockData() {
  if (props.comparisonData) {
    comparisonData.value = props.comparisonData
    return
  }

  // 根据实验 ID 生成不同的数据
  if (props.experimentId === 'heat_circulation') {
    comparisonData.value = {
      control: [45, 52, 48, 55, 50],
      experiment: [60, 68, 65, 72, 70],
      labels: ['环流范围', '上升速度', '下降速度', '循环强度', '温度梯度'],
      controlLabel: '对照组',
      experimentLabel: '实验组',
      unit: '单位',
    }
  } else if (props.experimentId === 'atmospheric_insulation') {
    comparisonData.value = {
      control: [15, 20, 18, 16, 17],
      experiment: [22, 28, 25, 24, 26],
      labels: ['初始温度', '最高温度', '平均温度', '最低温度', '保温效果'],
      controlLabel: '无大气组',
      experimentLabel: '有大气组',
      unit: '℃',
    }
  } else if (props.experimentId === 'soil_erosion') {
    comparisonData.value = {
      control: [85, 90, 88, 92, 87],
      experiment: [35, 40, 38, 42, 36],
      labels: ['流失量', '径流量', '泥沙量', '侵蚀深度', '土壤损失'],
      controlLabel: '对照组',
      experimentLabel: '实验组',
      unit: 'g',
    }
  } else {
    // 默认数据
    comparisonData.value = {
      control: [50, 55, 52, 58, 54],
      experiment: [60, 65, 62, 68, 64],
      labels: ['指标1', '指标2', '指标3', '指标4', '指标5'],
      controlLabel: '对照组',
      experimentLabel: '实验组',
      unit: '单位',
    }
  }

  // 生成时间序列数据
  if (!props.timeSeries && comparisonData.value) {
    const times: string[] = []
    const controlSeries: number[] = []
    const experimentSeries: number[] = []

    for (let i = 0; i < 20; i++) {
      times.push(`${i * 5}秒`)
      controlSeries.push(comparisonData.value.control[0] + Math.sin(i / 3) * 5 + Math.random() * 3)
      experimentSeries.push(
        comparisonData.value.experiment[0] + Math.sin(i / 3) * 5 + Math.random() * 3
      )
    }
  }

  // 计算摘要数据
  calculateSummary()
}

function calculateSummary() {
  if (!comparisonData.value) return

  const controlAvg =
    comparisonData.value.control.reduce((a, b) => a + b, 0) / comparisonData.value.control.length
  const experimentAvg =
    comparisonData.value.experiment.reduce((a, b) => a + b, 0) /
    comparisonData.value.experiment.length
  const difference = experimentAvg - controlAvg
  const percentage = ((difference / controlAvg) * 100).toFixed(1)

  summaryItems.value = [
    {
      label: '对照组平均值',
      value: `${controlAvg.toFixed(1)}${comparisonData.value.unit}`,
      trend: 'neutral',
    },
    {
      label: '实验组平均值',
      value: `${experimentAvg.toFixed(1)}${comparisonData.value.unit}`,
      trend: 'neutral',
    },
    {
      label: '差值',
      value: `${difference > 0 ? '+' : ''}${difference.toFixed(1)}${comparisonData.value.unit}`,
      trend: difference > 0 ? 'up' : 'down',
      arrow: difference > 0 ? '↑' : '↓',
    },
    {
      label: '变化率',
      value: `${percentage}%`,
      trend: difference > 0 ? 'up' : 'down',
      arrow: difference > 0 ? '↑' : '↓',
    },
  ]
}

function renderChart() {
  if (!chartContainer.value || !comparisonData.value) return

  if (!chart) {
    chart = echarts.init(chartContainer.value)
  }

  const option: echarts.EChartsOption = {
    title: {
      text: '实验结果对比分析',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 600,
        color: '#2C3E50',
      },
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow',
      },
    },
    legend: {
      data: [comparisonData.value.controlLabel, comparisonData.value.experimentLabel],
      top: 40,
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '20%',
      containLabel: true,
    },
    xAxis: {
      type: 'category',
      data: comparisonData.value.labels,
      axisLabel: {
        rotate: 45,
        fontSize: 12,
      },
    },
    yAxis: {
      type: 'value',
      name: comparisonData.value.unit,
      axisLabel: {
        fontSize: 12,
      },
    },
    series: [
      {
        name: comparisonData.value.controlLabel,
        type: 'bar',
        data: comparisonData.value.control,
        itemStyle: {
          color: '#91CC75',
        },
        label: {
          show: true,
          position: 'top',
          fontSize: 11,
        },
      },
      {
        name: comparisonData.value.experimentLabel,
        type: 'bar',
        data: comparisonData.value.experiment,
        itemStyle: {
          color: '#5470C6',
        },
        label: {
          show: true,
          position: 'top',
          fontSize: 11,
        },
      },
      // 差值标注线
      {
        name: '差值',
        type: 'line',
        data: comparisonData.value.control.map((_, i) => {
          const diff = comparisonData.value!.experiment[i] - comparisonData.value!.control[i]
          return comparisonData.value!.control[i] + diff / 2
        }),
        markLine: {
          data: comparisonData.value.control.map((_, i) => [
            {
              coord: [i, comparisonData.value!.control[i]],
              symbol: 'none',
            },
            {
              coord: [i, comparisonData.value!.experiment[i]],
              symbol: 'arrow',
              symbolSize: [8, 12],
            },
          ]),
          lineStyle: {
            color: '#FF6B6B',
            width: 2,
            type: 'dashed',
          },
          label: {
            formatter: (params: any) => {
              const diff =
                comparisonData.value!.experiment[params.dataIndex] -
                comparisonData.value!.control[params.dataIndex]
              return `+${diff.toFixed(1)}`
            },
            position: 'middle',
            fontSize: 10,
          },
        },
        lineStyle: {
          opacity: 0,
        },
        symbol: 'none',
      },
    ],
  }

  chart.setOption(option)
}

function handleResize() {
  chart?.resize()
}

watch(
  () => [props.experimentId, props.comparisonData],
  () => {
    generateMockData()
    renderChart()
  },
  { deep: true }
)

onMounted(() => {
  generateMockData()
  renderChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  chart?.dispose()
})
</script>

<style scoped>
.result-chart {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.chart-container {
  width: 100%;
  height: 400px;
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
}

.comparison-summary {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
}

.comparison-summary h4 {
  margin: 0 0 var(--spacing-base) 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.summary-items {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-base);
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-small);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
}

.summary-label {
  font-size: 13px;
  color: var(--color-text-secondary);
}

.summary-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.summary-value.up {
  color: var(--color-success);
}

.summary-value.down {
  color: var(--color-error);
}

.summary-value.neutral {
  color: var(--color-text-primary);
}

.trend-arrow {
  margin-left: 4px;
  font-size: 12px;
}

@media (max-width: 768px) {
  .chart-container {
    height: 300px;
  }

  .summary-items {
    grid-template-columns: 1fr;
  }
}
</style>
