<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>{{ hotspot?.title || '详情' }}</h2>
      <button class="link" @click="exportReport">导出分析报告</button>
    </header>
    <section class="grid">
      <div class="left">
        <template v-if="hotspot">
          <VideoPlayer 
            v-if="hotspot.video || hotspot.audio" 
            :videoUrl="(hotspot as any).video?.url" 
            :audioUrl="(hotspot as any).audio?.url" 
            :description="(hotspot as any).video?.description"
            :audioScript="(hotspot as any).audio?.script"
          />
          <EconomicDataChart 
            v-if="(hotspot as any).economicData" 
            :data="(hotspot as any).economicData" 
          />
          <DynamicModel 
            v-if="(hotspot as any).dynamicModel" 
            :parameters="(hotspot as any).dynamicModel.parameters" 
            :indicators="(hotspot as any).dynamicModel.indicators" 
          />
          <PolicyDebate 
            v-if="(hotspot as any).policyDebate" 
            :pros="(hotspot as any).policyDebate.pros"
            :cons="(hotspot as any).policyDebate.cons"
            :solution="(hotspot as any).policyDebate.solution"
          />
          <ConsumptionSimulator 
            v-if="(hotspot as any).consumptionSimulator" 
            :parameters="(hotspot as any).consumptionSimulator.parameters"
            :heatmapData="(hotspot as any).consumptionHeatmap?.cities"
          />
          <SWOTAnalysis 
            v-if="(hotspot as any).swotAnalysis" 
            :strengths="(hotspot as any).swotAnalysis.strengths"
            :weaknesses="(hotspot as any).swotAnalysis.weaknesses"
            :opportunities="(hotspot as any).swotAnalysis.opportunities"
            :threats="(hotspot as any).swotAnalysis.threats"
            :recommendations="(hotspot as any).swotAnalysis.recommendations"
          />
        </template>
        <h3>地理因素分析</h3>
        <div class="factors" v-if="hotspot">
          <p>地形：{{ hotspot.factors.terrain }}</p>
          <p>气候：{{ hotspot.factors.climate }}</p>
          <p>资源：{{ hotspot.factors.resource }}</p>
        </div>
        <h3>教材关联</h3>
        <ul class="chapters">
          <li v-for="c in hotspot?.chapters || []" :key="c">· {{ c }}</li>
        </ul>
        <h3>案例</h3>
        <CaseCard v-for="c in hotspot?.cases || []" :key="c.id" :item="c" />
        <h3>事件时间轴</h3>
        <HotspotTimeline v-if="(hotspot as any)?.timeline" :events="(hotspot as any).timeline" />
      </div>
      <div class="right">
        <h3>知识图谱</h3>
        <KnowledgeGraph :center="hotspot?.title || ''" :nodes="graphNodes" />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getHotspots } from '../../../services/api';
import KnowledgeGraph from './components/KnowledgeGraph.vue';
import CaseCard from './components/CaseCard.vue';
import VideoPlayer from './components/VideoPlayer.vue';
import EconomicDataChart from './components/EconomicDataChart.vue';
import DynamicModel from './components/DynamicModel.vue';
import PolicyDebate from './components/PolicyDebate.vue';
import ConsumptionSimulator from './components/ConsumptionSimulator.vue';
import SWOTAnalysis from './components/SWOTAnalysis.vue';
import HotspotTimeline from './components/HotspotTimeline.vue';

type HotspotDetail = {
  id: string; 
  title: string;
  factors: { terrain: string; climate: string; resource: string };
  chapters: string[];
  cases: { id: string; title: string; summary: string }[];
  video?: { url: string; duration?: number; description?: string };
  audio?: { url: string; script?: string };
  economicData?: { routeShortening: number; unit: string; cargoIncrease: number; unit2: string; description: string };
  dynamicModel?: { parameters: Array<{ name: string; min: number; max: number; default: number; unit: string }>; indicators: Array<{ name: string; type: string; unit: string }> };
  policyDebate?: { pros: string; cons: string; solution: string };
  consumptionSimulator?: { parameters: Array<{ name: string; min?: number; max?: number; default: number | string; unit?: string; options?: string[] }>; indicators?: any[] };
  consumptionHeatmap?: { cities: Array<{ name: string; orders: number; subsidy: number; income: number }> };
  swotAnalysis?: { strengths: string[]; weaknesses: string[]; opportunities: string[]; threats: string[]; recommendations: string };
  timeline?: Array<{ date: string; event: string; description: string }>;
};

const hotspot = ref<HotspotDetail | null>(null);
const graphNodes = ref<string[]>([]);

onMounted(async () => {
  const url = new URL(location.href);
  const id = url.searchParams.get('id');
  const data = await getHotspots();
  const source: any[] = (data.hotspots && data.hotspots.length)
    ? (data.hotspots as any[])
    : (data.items as any[]);
  const hit = source.find((x) => x.id === id) || source[0];
  hotspot.value = hit as HotspotDetail;
  graphNodes.value = [
    '地形', hit.factors.terrain,
    '气候', hit.factors.climate,
    '资源', hit.factors.resource,
    ...(hit.chapters || [])
  ];
});

function exportReport() {
  const md = `# 分析报告 - ${hotspot.value?.title}\n\n` +
    `## 地理因素\n- 地形：${hotspot.value?.factors.terrain}\n- 气候：${hotspot.value?.factors.climate}\n- 资源：${hotspot.value?.factors.resource}\n\n` +
    `## 教材关联\n${(hotspot.value?.chapters || []).map(c => `- ${c}`).join('\n')}\n\n` +
    `## 案例\n${(hotspot.value?.cases || []).map(c => `- ${c.title}：${c.summary}`).join('\n')}\n`;
  const blob = new Blob([md], { type: 'text/markdown;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `${hotspot.value?.id}-report.md`;
  a.click();
  URL.revokeObjectURL(a.href);
}
</script>

<style scoped>
.feature-page { padding: 16px; }
.feature-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.chapters { padding-left: 16px; }
.left, .right { border: 1px solid #eee; border-radius: 8px; padding: 12px; }
@media (max-width: 768px) {
  .grid { grid-template-columns: 1fr; }
}
</style>


