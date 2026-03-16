<script setup lang="ts">
import { ref } from 'vue'
const question = ref('')
const answer = ref('')
async function ask(){
  // 模拟 300ms 内结构化回答
  answer.value = ''
  setTimeout(()=>{ answer.value = '结论：夏季风主因海陆热力差异；依据：必修一P40。' }, 300)
}
</script>

<template>
  <view style="padding:16px">
    <textarea v-model="question" placeholder="语音/文字提问" style="height:120px;background:#fff;border-radius:12px;padding:8px" />
    <button class="btn-big" style="margin-top:12px" @click="ask">速问</button>
    <view v-if="answer" class="card" style="margin-top:12px">{{ answer }}</view>
  </view>
</template>

