<template>
  <div class="economic-data-chart">
    <h4>📊 经济数据可视化</h4>
    <div class="chart-container" ref="chartRef"></div>
    <div class="data-summary">
      <div class="summary-item">
        <span class="label">航程缩短：</span>
        <span class="value highlight">{{ data.routeShortening }}{{ data.unit }}</span>
      </div>
      <div class="summary-item">
        <span class="label">货运量提升：</span>
        <span class="value highlight">{{ data.cargoIncrease }}{{ data.unit2 }}</span>
      </div>
    </div>
    <p class="description">{{ data.description }}</p>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';

const props = defineProps<{
  data: {
    routeShortening: number;
    unit: string;
    cargoIncrease: number;
    unit2: string;
    description: string;
  };
}>();

const chartRef = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;

onMounted(() => {
  if (chartRef.value) {
    chart = echarts.init(chartRef.value);
    renderChart();
  }
});

onBeforeUnmount(() => {
  if (chart) {
    chart.dispose();
  }
});

watch(() => props.data, renderChart, { deep: true });

function renderChart() {
  if (!chart || !props.data) return;
  
  chart.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['传统航线', '北极航线'],
      axisLabel: {
        fontSize: 12
      }
    },
    yAxis: [
      {
        type: 'value',
        name: '航程（公里）',
        position: 'left',
        axisLabel: {
          formatter: '{value}'
        }
      },
      {
        type: 'value',
        name: '货运量提升（%）',
        position: 'right',
        axisLabel: {
          formatter: '{value}%'
        }
      }
    ],
    series: [
      {
        name: '航程',
        type: 'bar',
        yAxisIndex: 0,
        data: [21000, 14000],
        itemStyle: {
          color: '#409eff'
        },
        label: {
          show: true,
          position: 'top',
          formatter: (params: any) => `${params.value}公里`
        }
      },
      {
        name: '货运量提升',
        type: 'line',
        yAxisIndex: 1,
        data: [0, props.data.cargoIncrease],
        itemStyle: {
          color: '#52c41a'
        },
        label: {
          show: true,
          formatter: `+${props.data.cargoIncrease}%`
        }
      }
    ]
  });
}
</script>

<style scoped lang="scss">
.economic-data-chart {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.chart-container {
  width: 100%;
  height: 300px;
  margin-bottom: var(--spacing-base);
}

.data-summary {
  display: flex;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-base);
}

.summary-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
  
  .label {
    font-size: 12px;
    color: var(--color-text-secondary);
  }
  
  .value {
    font-size: 20px;
    font-weight: 600;
    color: var(--color-text-primary);
    
    &.highlight {
      color: var(--color-primary);
    }
  }
}

.description {
  margin: 0;
  font-size: 13px;
  color: var(--color-text-secondary);
  line-height: 1.6;
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-primary);
}
</style>







