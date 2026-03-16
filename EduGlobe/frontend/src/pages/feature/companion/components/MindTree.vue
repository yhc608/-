<template>
  <div class="tree" ref="el"></div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';
const props = defineProps<{ data:any; highlight?: boolean }>();
const el = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
function render(){
  if(!el.value) return;
  if(!chart) chart = echarts.init(el.value);
  chart.setOption({
    tooltip: { trigger:'item', triggerOn:'mousemove' },
    series: [{
      type: 'tree',
      data: [props.data || { name:'空' }],
      top: '5%', left:'8%', bottom:'5%', right:'20%',
      symbolSize: 10,
      label: { position: 'left', verticalAlign:'middle', align:'right' },
      leaves: { label: { position: 'right', align: 'left' } },
      emphasis: props.highlight ? { focus: 'ancestor' } : {}
    }]
  });
}
onMounted(()=>{ render(); window.addEventListener('resize', resize); });
onBeforeUnmount(()=>{ window.removeEventListener('resize', resize); chart?.dispose(); });
watch(()=>props.data, render, { deep:true });
function resize(){ chart?.resize(); }
</script>

<style scoped>
.tree { width: 100%; height: 360px; border: 1px solid #eee; border-radius: 8px; }
</style>


