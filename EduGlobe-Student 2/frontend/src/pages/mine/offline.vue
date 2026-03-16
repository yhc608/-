<script setup lang="ts">
import { setCache } from '../../utils/offline'
function downloadBasic(){
  setCache('core.knowledge', { version:'v1', items:[] })
  uni.showToast({ title:'已下载', icon:'success' })
}
function clearAll(){ uni.clearStorage(); uni.showToast({ title:'已清空', icon:'none' }) }
</script>

<template>
  <view style="padding:16px">
    <button @click="downloadBasic">下载基础资源</button>
    <button type="warn" style="margin-top:12px" @click="clearAll">清空离线资源</button>
  </view>
</template>

