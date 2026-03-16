<template>
  <div class="dynamic-model">
    <h4>🔬 动态模型构建</h4>
    <p class="description">调节参数，观察指标变化</p>
    
    <div class="model-content">
      <div class="parameters-panel">
        <h5>参数调节</h5>
        <div 
          v-for="(param, index) in parameters" 
          :key="index"
          class="parameter-item"
        >
          <label>{{ param.name }}</label>
          <div class="slider-container">
            <input 
              type="range" 
              :min="param.min" 
              :max="param.max" 
              :value="paramValues[index]"
              @input="updateParameter(index, ($event.target as HTMLInputElement).value)"
              class="slider"
            />
            <span class="value-display">
              {{ paramValues[index] }}{{ param.unit }}
            </span>
          </div>
        </div>
      </div>
      
      <div class="indicators-panel">
        <h5>指标变化</h5>
        <div class="indicators-container" ref="indicatorsRef"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';

const props = defineProps<{
  parameters: Array<{ name: string; min: number; max: number; default: number; unit: string }>;
  indicators: Array<{ name: string; type: string; unit: string }>;
}>();

const paramValues = ref<number[]>([]);
const indicatorsRef = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;

onMounted(() => {
  // 初始化参数值
  paramValues.value = props.parameters.map(p => p.default);
  renderIndicators();
});

onBeforeUnmount(() => {
  if (chart) {
    chart.dispose();
  }
});

watch(() => paramValues.value, renderIndicators, { deep: true });

function updateParameter(index: number, value: string) {
  paramValues.value[index] = Number(value);
}

function renderIndicators() {
  if (!indicatorsRef.value) return;
  
  if (!chart) {
    chart = echarts.init(indicatorsRef.value);
  }
  
  const greenEnergyRatio = paramValues.value[0] || 30;
  const envInvestment = paramValues.value[1] || 50;
  
  // 计算指标值（模拟计算）
  const emission = 100 - greenEnergyRatio * 0.8 - envInvestment * 0.2;
  const pm25 = 80 - greenEnergyRatio * 0.6 - envInvestment * 0.3;
  
  chart.setOption({
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['烟囱排放量', 'PM2.5浓度']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['当前值', '预测值']
    },
    yAxis: [
      {
        type: 'value',
        name: '排放量（万吨/年）',
        position: 'left'
      },
      {
        type: 'value',
        name: 'PM2.5（μg/m³）',
        position: 'right'
      }
    ],
    series: [
      {
        name: '烟囱排放量',
        type: 'bar',
        yAxisIndex: 0,
        data: [100, Math.max(0, emission)],
        itemStyle: {
          color: '#f56c6c'
        },
        label: {
          show: true,
          formatter: (params: any) => `${params.value.toFixed(1)}万吨/年`
        }
      },
      {
        name: 'PM2.5浓度',
        type: 'line',
        yAxisIndex: 1,
        data: [80, Math.max(0, pm25)],
        itemStyle: {
          color: '#409eff'
        },
        label: {
          show: true,
          formatter: (params: any) => `${params.value.toFixed(1)}μg/m³`
        }
      }
    ]
  });
}
</script>

<style scoped lang="scss">
.dynamic-model {
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

.model-content {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: var(--spacing-base);
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.parameters-panel,
.indicators-panel {
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

.parameter-item {
  margin-bottom: var(--spacing-base);
  
  label {
    display: block;
    margin-bottom: var(--spacing-small);
    font-size: 13px;
    color: var(--color-text-primary);
    font-weight: 500;
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
  
  &::-moz-range-thumb {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--color-primary);
    cursor: pointer;
    border: none;
  }
}

.value-display {
  min-width: 60px;
  text-align: right;
  font-size: 14px;
  font-weight: 600;
  color: var(--color-primary);
}

.indicators-container {
  width: 100%;
  height: 300px;
}
</style>







