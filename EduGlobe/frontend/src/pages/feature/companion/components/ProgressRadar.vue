<template>
  <div class="radar" ref="el"></div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';
const props = defineProps<{ overview: any }>();
const el = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
function render(){
  if(!el.value) return;
  if(!chart) chart = echarts.init(el.value);
  const c = props.overview?.progress?.class ?? 0;
  const y = props.overview?.progress?.you ?? 0;
  chart.setOption({
    tooltip: {},
    radar: { indicator: [{ name:'知识掌握', max:1 },{ name:'能力达成', max:1 },{ name:'进度匹配', max:1 }] },
    series: [{ type:'radar', data:[ { value:[c,c,c], name:'班级' }, { value:[y,y,y], name:'你' } ] }]
  });
}
onMounted(()=>{ render(); window.addEventListener('resize', resize); });
onBeforeUnmount(()=>{ window.removeEventListener('resize', resize); chart?.dispose(); });
watch(()=>props.overview, render, { deep:true });
function resize(){ chart?.resize(); }
</script>

<style scoped>
.radar { width: 100%; height: 360px; border: 1px solid #eee; border-radius: 8px; }
</style>


