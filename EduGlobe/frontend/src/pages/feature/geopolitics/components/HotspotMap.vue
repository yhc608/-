<template>
  <div class="hotspot-map-container">
    <div class="map-controls">
      <div class="layer-selector">
        <label>数据层：</label>
        <select v-model="selectedLayer" @change="updateLayer">
          <option value="heat">舆情热度</option>
          <option value="economic">经济指标</option>
          <option value="climate">气候变化</option>
          <option value="conflict">冲突分布</option>
        </select>
      </div>
      <div class="viz-mode">
        <label>可视化：</label>
        <select v-model="vizMode" @change="render">
          <option value="bar">柱形图</option>
          <option value="map">地图</option>
          <option value="network">网状图</option>
        </select>
      </div>
      <div class="time-range">
        <label>时间范围：</label>
        <select v-model="timeRange" @change="updateTimeRange">
          <option value="all">全部</option>
          <option value="week">近一周</option>
          <option value="month">近一月</option>
          <option value="year">近一年</option>
        </select>
      </div>
    </div>
    <div class="map" ref="el"></div>
    <div class="map-legend" v-if="vizMode==='map'">
      <div class="legend-item">
        <span class="legend-color" style="background: #f56c6c;"></span>
        <span>高值</span>
      </div>
      <div class="legend-item">
        <span class="legend-color" style="background: #faad14;"></span>
        <span>中值</span>
      </div>
      <div class="legend-item">
        <span class="legend-color" style="background: #52c41a;"></span>
        <span>低值</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';

type Item = { 
  id: string; 
  title: string; 
  lat: number; 
  lng: number; 
  heat: number;
  category?: string;
  economic?: number;
  climate?: number;
  conflict?: number;
};

const props = defineProps<{ items: Item[] }>();
const emit = defineEmits<{ (e: 'select', id: string): void }>();

const el = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
const selectedLayer = ref<'heat' | 'economic' | 'climate' | 'conflict'>('heat');
const vizMode = ref<'bar' | 'map' | 'network'>('bar');
const timeRange = ref<string>('all');

// 根据选择的数据层获取对应的数值
function getLayerValue(item: Item): number {
  switch (selectedLayer.value) {
    case 'economic':
      return item.economic || item.heat * 0.8;
    case 'climate':
      return item.climate || item.heat * 0.6;
    case 'conflict':
      return item.conflict || item.heat * 0.9;
    default:
      return item.heat;
  }
}

// 获取数据层的最大值
function getMaxValue(): number {
  const values = props.items.map(item => getLayerValue(item));
  return Math.max(...values, 100);
}

function render() {
  if (!el.value) return;
  if (!chart) chart = echarts.init(el.value);

  if (vizMode.value === 'bar') {
    renderBar();
  } else if (vizMode.value === 'network') {
    renderNetwork();
  } else {
    renderMap();
  }
}

function renderBar() {
  const data = (props.items || []).map(i => ({ id: i.id, name: i.title, value: getLayerValue(i) }));
  const sorted = [...data].sort((a,b)=> b.value - a.value);
  const colorMap: Record<string, string> = {
    heat: '#f56c6c',
    economic: '#409eff',
    climate: '#52c41a',
    conflict: '#faad14'
  };
  const barColor = colorMap[selectedLayer.value] || '#409eff';
  const barItemStyle = (() => {
    if (selectedLayer.value === 'economic') {
      return { color: barColor, borderRadius: [4,4,0,0] };
    }
    if (selectedLayer.value === 'climate') {
      return {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#52c41a' },
            { offset: 1, color: '#2db7f5' }
          ]
        }
      };
    }
    if (selectedLayer.value === 'conflict') {
      return {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#faad14' },
            { offset: 1, color: '#f56c6c' }
          ]
        }
      };
    }
    // heat 默认红色渐变
    return {
      color: {
        type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
        colorStops: [
          { offset: 0, color: '#ff9c9c' },
          { offset: 1, color: '#f56c6c' }
        ]
      }
    };
  })();
  chart!.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 40, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: sorted.map(d=>d.name), axisLabel: { interval: 0, rotate: 20 } },
    yAxis: { type: 'value' },
    series: [{
      type: 'bar',
      data: sorted.map(d=>({ value: d.value })),
      itemStyle: barItemStyle,
      label: { show: true, position: 'top' }
    }]
  } as any);
  chart!.off('click');
  chart!.on('click', (p: any) => {
    const idx = p.dataIndex;
    const id = sorted[idx]?.id;
    if (id) emit('select', id);
  });
}

async function renderMap() {
  await ensureWorldMapRegistered();
  const data = (props.items || []).map(i => ({
    name: i.title,
    value: [i.lng, i.lat, getLayerValue(i)],
    id: i.id,
  }));
  const maxValue = getMaxValue();
  const heatmapData = data.map(d => ({ value: [d.value[0], d.value[1], d.value[2]], name: d.name }));
  chart!.setOption({
    tooltip: {
      trigger: 'item',
      formatter: (params: any) => `${params.data?.name || params.name}<br/>${getLayerLabel()}: ${Array.isArray(params.value)? params.value[2]?.toFixed?.(1) ?? params.value[2] : params.value}`
    },
    visualMap: {
      min: 0,
      max: maxValue,
      left: 'left',
      bottom: 20,
      text: ['高', '低'],
      inRange: { color: ['#a0cfff', '#faad14', '#f56c6c'] },
      calculable: true
    },
    geo: {
      map: 'world', roam: true, zoom: 1.2,
      itemStyle: { areaColor: '#f5f7fa', borderColor: '#dcdfe6', borderWidth: 0.5 },
      emphasis: { itemStyle: { areaColor: '#e6f7ff' } }
    },
    series: [
      { type: 'scatter', coordinateSystem: 'geo', symbolSize: (v: any) => Math.max(8, v[2] / 5), data },
      { type: 'heatmap', coordinateSystem: 'geo', data: heatmapData, pointSize: 20, blurSize: 30, opacity: 0.6 }
    ]
  } as any);
  chart!.off('click');
  chart!.on('click', (p: any) => { if (p.data?.id) emit('select', p.data.id); });
}

function renderNetwork() {
  const nodes = (props.items || []).map(i => ({ id: i.id, name: i.title, value: getLayerValue(i), symbolSize: Math.max(10, (i.heat||0)/3) }));
  // 简易：无边或使用同类目连接（此处留空边，保持整洁）
  chart!.setOption({
    tooltip: { formatter: (p: any)=> `${p.data?.name}<br/>${getLayerLabel()}: ${p.data?.value}` },
    series: [{
      type: 'graph', layout: 'force', roam: true,
      data: nodes,
      force: { repulsion: 120, edgeLength: 60 },
      label: { show: true, position: 'right' },
      itemStyle: { color: '#73c0de' }
    }]
  } as any);
  chart!.off('click');
  chart!.on('click', (p: any) => { const id = p?.data?.id; if (id) emit('select', id); });
}

function getLayerLabel(): string {
  const labels: Record<string, string> = {
    heat: '舆情热度',
    economic: '经济指标',
    climate: '气候变化指数',
    conflict: '冲突风险'
  };
  return labels[selectedLayer.value] || '热度';
}

function updateLayer() {
  render();
}

function updateTimeRange() {
  // 根据时间范围筛选数据
  render();
}

async function ensureWorldMapRegistered() {
  // 如果已经注册过，跳过
  // @ts-ignore
  const anyE: any = echarts as any;
  if (anyE && anyE._maps && anyE._maps.world) return;
  try {
    const sources = [
      'https://fastly.jsdelivr.net/npm/echarts@5/map/json/world.json',
      'https://cdn.jsdelivr.net/npm/echarts@5/map/json/world.json',
      'https://unpkg.com/echarts@5/map/json/world.json'
    ];
    let ok = false;
    for (const url of sources) {
      try {
        const resp = await fetch(url, { mode: 'cors' });
        if (!resp.ok) continue;
        const geojson = await resp.json();
        echarts.registerMap('world', geojson as any);
        ok = true;
        break;
      } catch {}
    }
    if (!ok) throw new Error('All CDN sources failed');
  } catch (e) {
    console.warn('加载世界地图失败，将尝试继续渲染：', e);
  }
}

onMounted(async () => {
  render();
  window.addEventListener('resize', resize);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', resize);
  chart?.dispose();
});

watch(() => props.items, render, { deep: true });
watch(() => selectedLayer.value, render);
watch(() => vizMode.value, render);

function resize() {
  chart?.resize();
}

// 保留：仅在地图模式下按需注册世界底图
</script>

<style scoped lang="scss">
.hotspot-map-container {
  position: relative;
}

.map-controls {
  display: flex;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  padding: var(--spacing-small);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  
  label {
    font-size: 12px;
    color: var(--color-text-secondary);
    margin-right: var(--spacing-small);
  }
  
  select {
    padding: 4px var(--spacing-small);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-small);
    background: white;
    font-size: 12px;
    cursor: pointer;
  }
}

.map {
  width: 100%;
  height: 500px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: var(--color-bg-secondary);
}

.map-legend {
  display: flex;
  gap: var(--spacing-base);
  margin-top: var(--spacing-small);
  padding: var(--spacing-small);
  justify-content: center;
  font-size: 12px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  color: var(--color-text-secondary);
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: var(--radius-small);
  display: inline-block;
}
</style>


