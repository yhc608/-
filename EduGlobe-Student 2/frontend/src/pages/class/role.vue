<script setup lang="ts">
import { ref } from 'vue'
const dialogs = [
  '我是徐霞客，行走山川之间，今日同你一起看地貌。',
  '暖场问题："四山环翠"对应哪种地貌？A. 喀斯特 B. 冲积平原'
]
const i = ref(0)
function next(){ if(i.value<dialogs.length-1) i.value++; }
</script>

<template>
  <view style="padding:16px;text-align:center">
    <image src="/static/role/xuxiake.png" style="width:120px;height:120px;border-radius:60px;background:#eee" />
    <view class="card" style="margin-top:12px">
      <text>{{ dialogs[i] }}</text>
    </view>
    <button class="btn-big" style="margin-top:12px" @click="next">下一条</button>
  </view>
</template>

