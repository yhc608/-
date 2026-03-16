<template>
  <div class="consumption-simulator">
    <h4>🛒 消费地理模拟器</h4>
    <p class="description">拖动滑块，观察消费行为变化</p>
    
    <div class="simulator-content">
      <div class="controls-panel">
        <h5>参数调节</h5>
        <div 
          v-for="(param, index) in parameters" 
          :key="index"
          class="control-item"
        >
          <label>{{ param.name }}</label>
          <div v-if="param.options" class="select-container">
            <select 
              :value="paramValues[index]"
              @change="updateParameter(index, ($event.target as HTMLSelectElement).value)"
            >
              <option v-for="opt in param.options" :key="opt" :value="opt">{{ opt }}</option>
            </select>
          </div>
          <div v-else class="slider-container">
            <input 
              type="range" 
              :min="param.min" 
              :max="param.max" 
              :value="paramValues[index]"
              @input="updateParameter(index, ($event.target as HTMLInputElement).value)"
              class="slider"
            />
            <span class="value-display">{{ paramValues[index] }}{{ param.unit }}</span>
          </div>
        </div>
      </div>
      
      <div class="charts-panel">
        <h5>动态变化</h5>
        <div class="charts-container">
          <div class="chart-item" ref="pieChartRef"></div>
          <div class="chart-item" ref="flowChartRef"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';

const props = defineProps<{
  parameters: Array<{ 
    name: string; 
    min?: number; 
    max?: number; 
    default: number | string; 
    unit?: string;
    options?: string[];
  }>;
  heatmapData?: Array<{ name: string; orders: number; subsidy: number; income: number }>;
}>();

const paramValues = ref<(number | string)[]>([]);
const pieChartRef = ref<HTMLDivElement | null>(null);
const flowChartRef = ref<HTMLDivElement | null>(null);
let pieChart: echarts.ECharts | null = null;
let flowChart: echarts.ECharts | null = null;

onMounted(() => {
  paramValues.value = props.parameters.map(p => p.default);
  renderCharts();
});

onBeforeUnmount(() => {
  if (pieChart) pieChart.dispose();
  if (flowChart) flowChart.dispose();
});

watch(() => paramValues.value, renderCharts, { deep: true });

function updateParameter(index: number, value: string | number) {
  paramValues.value[index] = typeof value === 'string' && !isNaN(Number(value)) 
    ? Number(value) 
    : value;
}

function renderCharts() {
  const subsidy = Number(paramValues.value[0]) || 2000;
  const productType = paramValues.value[1] || '家电';
  
  // 渲染饼状图：不同收入群体购买偏好
  if (pieChartRef.value) {
    if (!pieChart) {
      pieChart = echarts.init(pieChartRef.value);
    }
    
    const baseRatio = subsidy / 2000;
    pieChart.setOption({
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
      },
      legend: {
        bottom: 10
      },
      series: [{
        type: 'pie',
        radius: ['40%', '70%'],
        data: [
          { value: Math.round(30 * baseRatio), name: '高收入群体' },
          { value: Math.round(45 * baseRatio), name: '中等收入群体' },
          { value: Math.round(25 * baseRatio), name: '低收入群体' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }]
    });
  }
  
  // 渲染流向图：京津冀三地物流企业订单分配
  if (flowChartRef.value) {
    if (!flowChart) {
      flowChart = echarts.init(flowChartRef.value);
    }
    
    const baseOrders = props.heatmapData || [];
    const multiplier = subsidy / 2000;
    
    flowChart.setOption({
      tooltip: {
        trigger: 'axis'
      },
      xAxis: {
        type: 'category',
        data: baseOrders.map(d => d.name)
      },
      yAxis: {
        type: 'value',
        name: '订单量'
      },
      series: [{
        type: 'bar',
        data: baseOrders.map(d => Math.round(d.orders * multiplier)),
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        },
        label: {
          show: true,
          position: 'top'
        }
      }]
    });
  }
}
</script>

<style scoped lang="scss">
.consumption-simulator {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  .description {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 12px;
    color: var(--color-text-secondary);
  }
}

.simulator-content {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: var(--spacing-base);
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.controls-panel,
.charts-panel {
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  
  h5 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.control-item {
  margin-bottom: var(--spacing-base);
  
  label {
    display: block;
    margin-bottom: var(--spacing-small);
    font-size: 13px;
    color: var(--color-text-primary);
    font-weight: 500;
  }
}

.select-container {
  select {
    width: 100%;
    padding: var(--spacing-small);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    background: white;
    font-size: 13px;
    cursor: pointer;
  }
}

.slider-container {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
}

.slider {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: var(--color-border);
  outline: none;
  
  &::-webkit-slider-thumb {
    appearance: none;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--color-primary);
    cursor: pointer;
  }
}

.value-display {
  min-width: 60px;
  text-align: right;
  font-size: 14px;
  font-weight: 600;
  color: var(--color-primary);
}

.charts-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-base);
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.chart-item {
  width: 100%;
  height: 250px;
}
</style>


