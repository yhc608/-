<script setup lang="ts">
import { ref } from 'vue'
type Node = { id:string; label:string; refs?:string[]; page?:string }
const mode = ref<'basic'|'advance'>('basic')
const view = ref<'text'|'mindmap'>('text')
const nodes = ref<Node[]>([
  {id:'ch1', label:'大气环流', refs:['c1','c2']},
  {id:'c1', label:'季风成因', page:'必修一 P40'},
  {id:'c2', label:'气压带与风带', page:'必修一 P42'}
])
const selected = ref<Node|null>(null)
function open(node:Node){ selected.value = node }
</script>

<template>
  <view class="toolbar">
    <picker :range="['基础','进阶']" @change="mode = $event.detail.value==0?'basic':'advance'"><view>难度：{{ mode==='basic'?'基础':'进阶' }}</view></picker>
    <picker :range="['文字','思维导图']" @change="view = $event.detail.value==0?'text':'mindmap'"><view>模态：{{ view==='text'?'文字':'导图' }}</view></picker>
  </view>

  <view class="graph">
    <view v-for="n in nodes" :key="n.id" class="node" @click="open(n)">{{ n.label }}</view>
  </view>

  <view v-if="selected" class="sheet">
    <text class="title">{{ selected?.label }}</text>
    <text class="meta" v-if="selected?.page">教材：{{ selected?.page }}</text>
    <view class="qa" v-if="selected?.id==='c1'">
      <text>速测：我国夏季风主导风向？</text>
      <text>答：东南/西南风（区域差异）。</text>
    </view>
  </view>
</template>

<style>
.toolbar{ display:flex; gap:12px; padding:12px; }
.graph{ display:flex; gap:12px; flex-wrap:wrap; padding:12px; }
.node{ padding:12px 16px; background:#eef7ff; border-radius:12px; }
.sheet{ padding:16px; margin:12px; background:#fff; border-radius:12px; }
.title{ font-weight:700; }
.meta{ color:#666; margin-top:6px; display:block; }
</style>

