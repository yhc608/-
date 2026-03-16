<script setup lang="ts">
function takePhoto(){
  uni.chooseImage({ count:1, sourceType:['camera','album'],
    success: async (res)=>{
      const path = res.tempFilePaths[0]
      uni.showToast({ title:'已获取图片，进行识别…', icon:'none' })
    }
  })
}
</script>

<template>
  <view style="padding:16px">
    <button class="btn-big" @click="takePhoto">拍照识别</button>
    <textarea placeholder="语音/文字提问（语音需平台能力）" style="margin-top:12px;height:120px;background:#fff;border-radius:12px;padding:8px" />
  </view>
</template>

