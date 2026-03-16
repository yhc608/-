<script setup lang="ts">
const games = [
  { id:'g1', title:'气候拼图', tag:'必修一 P42' },
  { id:'g2', title:'地理灯谜', tag:'综合' }
]
</script>

<template>
  <view style="padding:12px">
    <view class="card" v-for="g in games" :key="g.id" style="margin-bottom:12px">
      <text class="h1">{{ g.title }}</text>
      <text style="display:block;color:#666;margin-top:6px">对应：{{ g.tag }}</text>
      <button size="mini" style="margin-top:8px">开始</button>
    </view>
  </view>
</template>

