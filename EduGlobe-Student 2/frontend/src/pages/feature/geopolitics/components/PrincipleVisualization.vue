<template>
  <div class="principle-viz">
    <div class="viz-header">
      <h4>原理可视化推演</h4>
      <button class="play-btn" @click="togglePlay">
        {{ isPlaying ? '暂停' : '播放' }}
      </button>
    </div>
    <div class="viz-content">
      <div class="viz-canvas" ref="canvasRef">
        <canvas ref="canvas" width="600" height="400"></canvas>
      </div>
      <div class="viz-controls">
        <div class="control-item">
          <label>演示速度：</label>
          <input 
            type="range" 
            min="1" 
            max="5" 
            v-model="speed"
            @input="updateSpeed"
          />
          <span>{{ speed }}x</span>
        </div>
        <div class="control-item">
          <label>当前步骤：</label>
          <span>{{ currentStep + 1 }} / {{ totalSteps }}</span>
        </div>
      </div>
      <div class="viz-description">
        <p>{{ currentDescription }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';

const props = defineProps<{
  principle: string;
  visualizationType?: 'terrain' | 'climate' | 'resource' | 'transport';
}>();

const canvas = ref<HTMLCanvasElement | null>(null);
const canvasRef = ref<HTMLDivElement | null>(null);
const isPlaying = ref(false);
const speed = ref(2);
const currentStep = ref(0);
const totalSteps = ref(5);
const currentDescription = ref('');

let animationFrame: number | null = null;
let ctx: CanvasRenderingContext2D | null = null;

// 根据可视化类型生成不同的描述
const descriptions: Record<string, string[]> = {
  terrain: [
    '地形对运输路线的影响：等高线显示地形起伏',
    '选择低海拔、平缓的路线可以降低运输成本',
    '地形复杂区域需要绕行或增加基础设施投入',
    '最终路线选择：综合考虑地形、距离、成本',
    '地形因素在地理决策中的重要性'
  ],
  climate: [
    '气候变化对地理环境的影响',
    '温度变化导致冰川融化',
    '海平面上升影响沿海地区',
    '极端天气事件频率增加',
    '需要采取适应性措施'
  ],
  resource: [
    '资源分布与产业布局的关系',
    '资源丰富区域吸引产业集聚',
    '运输成本影响资源利用范围',
    '资源枯竭导致产业转型',
    '可持续发展的重要性'
  ],
  transport: [
    '运输路线选择的地理因素',
    '距离、地形、成本综合考量',
    '最优路线确定',
    '路线变化对区域发展的影响',
    '地理因素在交通规划中的作用'
  ]
};

onMounted(() => {
  if (canvas.value) {
    ctx = canvas.value.getContext('2d');
    initVisualization();
  }
});

onBeforeUnmount(() => {
  if (animationFrame) {
    cancelAnimationFrame(animationFrame);
  }
});

function initVisualization() {
  if (!ctx || !canvas.value) return;
  
  const type = props.visualizationType || 'terrain';
  const descs = descriptions[type] || descriptions.terrain;
  totalSteps.value = descs.length;
  currentDescription.value = descs[0];
  
  drawStep(0);
}

function drawStep(step: number) {
  if (!ctx || !canvas.value) return;
  
  const width = canvas.value.width;
  const height = canvas.value.height;
  
  // 清空画布
  ctx.clearRect(0, 0, width, height);
  
  // 绘制背景
  ctx.fillStyle = '#f5f7fa';
  ctx.fillRect(0, 0, width, height);
  
  // 根据步骤绘制不同的内容
  const type = props.visualizationType || 'terrain';
  
  if (type === 'terrain') {
    drawTerrainVisualization(ctx, width, height, step);
  } else if (type === 'climate') {
    drawClimateVisualization(ctx, width, height, step);
  } else if (type === 'resource') {
    drawResourceVisualization(ctx, width, height, step);
  } else {
    drawTransportVisualization(ctx, width, height, step);
  }
}

function drawTerrainVisualization(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  step: number
) {
  // 绘制等高线
  ctx.strokeStyle = '#409eff';
  ctx.lineWidth = 2;
  
  for (let i = 0; i < 5; i++) {
    const y = 100 + i * 60;
    ctx.beginPath();
    ctx.moveTo(50, y);
    ctx.quadraticCurveTo(width / 2, y + (i % 2 === 0 ? -20 : 20), width - 50, y);
    ctx.stroke();
    
    // 标注高度
    ctx.fillStyle = '#666';
    ctx.font = '12px Arial';
    ctx.fillText(`${1000 - i * 200}m`, 20, y + 5);
  }
  
  // 绘制路线
  if (step >= 1) {
    ctx.strokeStyle = '#52c41a';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(50, 200);
    ctx.quadraticCurveTo(width / 2, 180, width - 50, 200);
    ctx.stroke();
    
    // 标注路线
    if (step >= 2) {
      ctx.fillStyle = '#52c41a';
      ctx.font = '14px Arial';
      ctx.fillText('最优路线', width / 2 - 40, 170);
    }
  }
}

function drawClimateVisualization(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  step: number
) {
  // 绘制温度变化曲线
  ctx.strokeStyle = '#f56c6c';
  ctx.lineWidth = 3;
  ctx.beginPath();
  
  const startY = height - 100;
  const tempIncrease = step * 10;
  
  for (let x = 50; x < width - 50; x += 10) {
    const y = startY - (x / 10) - tempIncrease;
    if (x === 50) {
      ctx.moveTo(x, y);
    } else {
      ctx.lineTo(x, y);
    }
  }
  ctx.stroke();
  
  // 标注
  ctx.fillStyle = '#f56c6c';
  ctx.font = '14px Arial';
  ctx.fillText(`温度上升: +${tempIncrease}°C`, 50, 50);
}

function drawResourceVisualization(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  step: number
) {
  // 绘制资源点
  const resources = [
    { x: 150, y: 150, size: 20 },
    { x: 300, y: 200, size: 15 },
    { x: 450, y: 180, size: 25 }
  ];
  
  resources.forEach((res, i) => {
    if (i <= step) {
      ctx.fillStyle = '#faad14';
      ctx.beginPath();
      ctx.arc(res.x, res.y, res.size, 0, Math.PI * 2);
      ctx.fill();
      
      ctx.fillStyle = '#fff';
      ctx.font = '12px Arial';
      ctx.fillText('资源', res.x - 20, res.y + 5);
    }
  });
  
  // 绘制连接线
  if (step >= 2) {
    ctx.strokeStyle = '#409eff';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(resources[0].x, resources[0].y);
    ctx.lineTo(resources[1].x, resources[1].y);
    ctx.lineTo(resources[2].x, resources[2].y);
    ctx.stroke();
  }
}

function drawTransportVisualization(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  step: number
) {
  // 绘制起点和终点
  ctx.fillStyle = '#52c41a';
  ctx.beginPath();
  ctx.arc(100, height / 2, 15, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillText('起点', 70, height / 2 - 25);
  
  ctx.fillStyle = '#f56c6c';
  ctx.beginPath();
  ctx.arc(width - 100, height / 2, 15, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillText('终点', width - 100, height / 2 - 25);
  
  // 绘制路线
  if (step >= 1) {
    ctx.strokeStyle = '#409eff';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(115, height / 2);
    ctx.lineTo(width - 115, height / 2);
    ctx.stroke();
    
    if (step >= 2) {
      ctx.fillStyle = '#409eff';
      ctx.font = '12px Arial';
      ctx.fillText('运输路线', width / 2 - 40, height / 2 - 10);
    }
  }
}

function togglePlay() {
  isPlaying.value = !isPlaying.value;
  if (isPlaying.value) {
    animate();
  } else {
    if (animationFrame) {
      cancelAnimationFrame(animationFrame);
    }
  }
}

function animate() {
  if (!isPlaying.value) return;
  
  const type = props.visualizationType || 'terrain';
  const descs = descriptions[type] || descriptions.terrain;
  
  if (currentStep.value < totalSteps.value - 1) {
    currentStep.value++;
    currentDescription.value = descs[currentStep.value];
    drawStep(currentStep.value);
    
    const delay = 2000 / speed.value;
    setTimeout(() => {
      if (isPlaying.value) {
        animate();
      }
    }, delay);
  } else {
    isPlaying.value = false;
    // 重新开始
    setTimeout(() => {
      currentStep.value = 0;
      currentDescription.value = descs[0];
      drawStep(0);
    }, 1000);
  }
}

function updateSpeed() {
  // 速度更新
}

watch(() => props.visualizationType, () => {
  initVisualization();
});
</script>

<style scoped lang="scss">
.principle-viz {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
}

.viz-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.play-btn {
  padding: var(--spacing-small) var(--spacing-base);
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  font-size: 14px;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-primary-dark);
  }
}

.viz-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.viz-canvas {
  width: 100%;
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  overflow: hidden;
  
  canvas {
    width: 100%;
    height: auto;
    display: block;
  }
}

.viz-controls {
  display: flex;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  font-size: 12px;
}

.control-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  
  label {
    color: var(--color-text-secondary);
  }
  
  input[type="range"] {
    width: 100px;
  }
  
  span {
    color: var(--color-primary);
    font-weight: 600;
  }
}

.viz-description {
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-primary);
  
  p {
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
    color: var(--color-text-primary);
  }
}
</style>







