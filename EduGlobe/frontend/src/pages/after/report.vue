<script setup lang="ts">
import { onMounted } from 'vue'
let chart: any
onMounted(async ()=>{
  // #ifdef H5
  if (typeof document === 'undefined') return
  const echarts = await import('echarts/core')
  const { RadarChart } = await import('echarts/charts')
  const { TitleComponent, TooltipComponent, LegendComponent } = await import('echarts/components')
  const { CanvasRenderer } = await import('echarts/renderers')
  echarts.use([RadarChart, TitleComponent, TooltipComponent, LegendComponent, CanvasRenderer])
  const el = document.getElementById('radar') as any
  if (!el) return
  const inst = echarts.init(el)
  inst.setOption({
    title:{ text:'每日学习报告' },
    radar:{ indicator:[{name:'自然'},{name:'人文'},{name:'区域'}] },
    series:[{ type:'radar', data:[{ value:[78, 64, 55], name:'得分' }] }]
  })
  chart = inst
  // #endif
})
</script>

<template>
  <view style="padding:12px">
    <!-- #ifdef H5 -->
    <view id="radar" style="width:100%;height:260px;background:#fff;border-radius:12px"></view>
    <!-- #endif -->
    <view style="margin-top:12px">
      <text>薄弱点：</text>
      <view>- 洋流分布规律错误率 35%</view>
    </view>
  </view>
</template>

