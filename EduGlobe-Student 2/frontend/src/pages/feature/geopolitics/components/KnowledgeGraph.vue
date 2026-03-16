<template>
  <div class="knowledge-graph-container">
    <div class="graph-header">
      <h4>知识关联图谱</h4>
      <div class="graph-controls">
        <button 
          class="control-btn" 
          :class="{ active: layout === 'force' }"
          @click="layout = 'force'"
        >
          力导向
        </button>
        <button 
          class="control-btn" 
          :class="{ active: layout === 'circular' }"
          @click="layout = 'circular'"
        >
          环形
        </button>
      </div>
    </div>
    <div class="graph" ref="el"></div>
    <div class="graph-info">
      <div class="info-item">
        <span class="info-label">核心概念：</span>
        <span class="info-value">{{ center }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">关联知识点：</span>
        <span class="info-value">{{ nodes.length }} 个</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';

const props = defineProps<{ 
  center: string; 
  nodes: string[];
  knowledgeChain?: Array<{ from: string; to: string; relation: string }>;
}>();

const emit = defineEmits<{
  (e: 'nodeClick', nodeName: string): void;
}>();

const el = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
const layout = ref<'force' | 'circular'>('force');

// 构建知识链条（如果提供了knowledgeChain，使用它；否则自动生成）
function buildKnowledgeChain() {
  if (props.knowledgeChain && props.knowledgeChain.length > 0) {
    return props.knowledgeChain;
  }
  
  // 自动生成知识链条：中心节点连接到所有其他节点
  return props.nodes.map(node => ({
    from: props.center,
    to: node,
    relation: '关联'
  }));
}

function render() {
  if (!el.value) return;
  if (!chart) chart = echarts.init(el.value);
  
  const allNodes = [props.center, ...(props.nodes || [])];
  const knowledgeChain = buildKnowledgeChain();
  
  // 构建节点数据
  const data = allNodes.map((n, i) => ({
    id: String(i),
    name: n,
    symbolSize: i === 0 ? 60 : 35,
    category: i === 0 ? 0 : 1,
    itemStyle: {
      color: i === 0 ? '#f56c6c' : '#409eff'
    },
    label: {
      show: true,
      fontSize: i === 0 ? 14 : 12,
      fontWeight: i === 0 ? 'bold' : 'normal'
    }
  }));
  
  // 构建连接关系
  const links = knowledgeChain.map(chain => {
    const fromIndex = allNodes.indexOf(chain.from);
    const toIndex = allNodes.indexOf(chain.to);
    return {
      source: String(fromIndex),
      target: String(toIndex),
      value: chain.relation,
      label: {
        show: true,
        formatter: chain.relation,
        fontSize: 10
      },
      lineStyle: {
        width: 2,
        curveness: 0.3
      }
    };
  });
  
  chart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: (params: any) => {
        if (params.dataType === 'node') {
          return `<strong>${params.data.name}</strong><br/>${params.data.category === 0 ? '核心概念' : '关联知识点'}`;
        }
        return `${params.data.source} → ${params.data.target}<br/>关系：${params.data.value}`;
      }
    },
    legend: {
      data: ['核心概念', '关联知识点'],
      bottom: 10
    },
    series: [{
      type: 'graph',
      layout: layout.value,
      roam: true,
      focusNodeAdjacency: true,
      data: data,
      links: links,
      categories: [
        { name: '核心概念', itemStyle: { color: '#f56c6c' } },
        { name: '关联知识点', itemStyle: { color: '#409eff' } }
      ],
      force: {
        repulsion: 150,
        edgeLength: 100,
        gravity: 0.1
      },
      circular: {
        radius: 150
      },
      label: {
        show: true,
        position: 'right',
        formatter: '{b}'
      },
      lineStyle: {
        color: 'source',
        curveness: 0.3
      },
      emphasis: {
        focus: 'adjacency',
        lineStyle: {
          width: 4
        }
      }
    }]
  });
  
  // 点击节点事件
  chart.off('click');
  chart.on('click', (params: any) => {
    if (params.dataType === 'node') {
      emit('nodeClick', params.data.name);
    }
  });
}

onMounted(() => {
  render();
  window.addEventListener('resize', resize);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', resize);
  chart?.dispose();
});

watch(() => [props.center, props.nodes, layout.value], render, { deep: true });

function resize() {
  chart?.resize();
}
</script>

<style scoped lang="scss">
.knowledge-graph-container {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
}

.graph-header {
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

.graph-controls {
  display: flex;
  gap: var(--spacing-small);
}

.control-btn {
  padding: 4px var(--spacing-small);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-small);
  background: var(--color-bg-tertiary);
  color: var(--color-text-secondary);
  font-size: 12px;
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover {
    border-color: var(--color-primary);
  }
  
  &.active {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.graph {
  width: 100%;
  height: 450px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
}

.graph-info {
  display: flex;
  gap: var(--spacing-base);
  margin-top: var(--spacing-base);
  padding: var(--spacing-small);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  font-size: 12px;
}

.info-item {
  display: flex;
  gap: var(--spacing-small);
  
  .info-label {
    color: var(--color-text-secondary);
  }
  
  .info-value {
    color: var(--color-primary);
    font-weight: 600;
  }
}
</style>


