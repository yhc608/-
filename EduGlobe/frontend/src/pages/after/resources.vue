<script setup lang="ts">
const videos = [ { id:'v1', title:'季风与降水（4:50）' } ]
const articles = [ { id:'a1', title:'等高线判读入门' } ]
const tasks = [ { id:'p1', title:'用橡皮泥做等高线模型' } ]
</script>

<template>
  <view style="padding:12px">
    <view class="card" style="margin-bottom:12px">
      <text class="h1">视频（≤5分钟）</text>
      <view v-for="v in videos" :key="v.id" style="margin-top:8px">{{ v.title }}</view>
    </view>
    <view class="card" style="margin-bottom:12px">
      <text class="h1">文章</text>
      <view v-for="a in articles" :key="a.id" style="margin-top:8px">{{ a.title }}</view>
    </view>
    <view class="card">
      <text class="h1">实践任务</text>
      <view v-for="t in tasks" :key="t.id" style="margin-top:8px">{{ t.title }}</view>
    </view>
  </view>
</template>

