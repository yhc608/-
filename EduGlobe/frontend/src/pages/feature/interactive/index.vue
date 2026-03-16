<template>
  <div class="interactive-page" :style="{ backgroundImage: bgStyle }">
    <div class="overlay-panel">
      <div class="panel-title">探索者定制</div>
      <div class="form-row">
        <label>性别</label>
        <div class="options">
          <label class="opt"><input type="radio" value="男" v-model="gender"> 男</label>
          <label class="opt"><input type="radio" value="女" v-model="gender"> 女</label>
        </div>
      </div>
      <div class="form-row">
        <label>学科职业套装</label>
        <select v-model="profession" class="select">
          <option value="地质学家">地质学家</option>
          <option value="气象观测员">气象观测员</option>
          <option value="热带雨林探索家">热带雨林探索家</option>
          <option value="冰川探索家">冰川探索家</option>
        </select>
      </div>
      <div class="form-row">
        <label>职业发型</label>
        <select v-model="hairstyle" class="select">
          <option value="平头">平头</option>
          <option value="短发">短发</option>
          <option value="长发">长发</option>
          <option value="光头">光头</option>
        </select>
      </div>
      <div class="form-row">
        <label>面部特征</label>
        <select v-model="face" class="select">
          <option value="方形脸">方形脸</option>
          <option value="圆形脸">圆形脸</option>
          <option value="椭圆形脸">椭圆形脸</option>
        </select>
      </div>
      <div class="panel-actions">
        <button class="btn-primary" @click="confirmExplorer">确定</button>
      </div>
    </div>

    <div class="overlay-controls">
      <button class="btn-text" @click="switchScene('home')">首页</button>
      <button class="btn-text" @click="switchScene('glacier')">冰川</button>
      <button class="btn-text" @click="switchScene('rainforest')">热带雨林</button>
    </div>

    <button class="btn-explore" @click="startExplore">探索</button>
    <button class="btn-deep" @click="openDeep">深度探索</button>
    <button class="btn-highlight" @click="openHighlights">核心特色</button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'

// 当前场景与背景地址
const current = ref<'home' | 'glacier' | 'rainforest'>('home')
const backgroundUrl = ref<string>('')
const router = useRouter()

// 定制面板数据
const gender = ref<'男'|'女'>('男')
const profession = ref<'地质学家'|'气象观测员'>('地质学家')
const hairstyle = ref<'短发'|'中发'|'长发'>('短发')
const face = ref<'清秀'|'坚毅'|'亲和'>('清秀')

// 各场景候选文件（按优先级从前到后探测）
const candidates: Record<'home'|'glacier'|'rainforest', string[]> = {
  home: ['/背景1.jpg', '/背景一.jpg', '/背景1.png'],
  glacier: ['/背景2.jpg', '/背景2png.png', '/背景2jpg.jpg'],
  rainforest: ['/背景3.jpg', '/背景三.jpg', '/背景3.png']
}

async function switchScene(scene: 'home' | 'glacier' | 'rainforest') {
  current.value = scene
  // 默认先用第一个候选，避免空白
  backgroundUrl.value = candidates[scene][0]
  // 逐个探测，找到第一个可用的文件
  for (const url of candidates[scene]) {
    const ok = await pingImage(url)
    if (ok) { backgroundUrl.value = url; break }
  }
}

function pingImage(url: string): Promise<boolean> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => resolve(true)
    img.onerror = () => resolve(false)
    img.src = url
  })
}

onMounted(() => {
  switchScene('home')
})

const bgStyle = computed(() => (backgroundUrl.value ? `url(${backgroundUrl.value})` : 'none'))

function confirmExplorer() {
  const payload = {
    gender: gender.value,
    profession: profession.value,
    hairstyle: hairstyle.value,
    face: face.value,
  }
  try { localStorage.setItem('interactive_explorer', JSON.stringify(payload)) } catch {}
}

function startExplore() {
  router.push({ path: '/feature/interactive/explore', query: { scene: current.value } })
}

function openDeep() {
  router.push({ path: '/feature/interactive/deep' })
}

function openHighlights() {
  router.push({ path: '/feature/interactive/highlights' })
}
</script>

<style scoped>
.interactive-page {
  position: relative;
  width: 100%;
  min-height: 100vh;
  height: 100vh;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.overlay-panel {
  position: absolute;
  top: 120px;
  left: var(--spacing-base);
  width: 340px;
  background: rgba(0,0,0,0.5);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: var(--radius-base);
  backdrop-filter: blur(8px);
  padding: 16px 18px;
  color: #fff;
  z-index: 6;
}

.panel-title {
  font-weight: 600;
  margin-bottom: 12px;
  font-size: 16px;
}

.form-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.options { display: flex; gap: 14px; }
.opt { display: flex; align-items: center; gap: 6px; }
.select {
  flex: 1;
  padding: 8px 10px;
  background: #ffffff;
  color: #000000;
  border: 1px solid transparent;
  border-radius: 8px;
  font-size: 14px;
}

.panel-actions {
  display: flex;
  justify-content: flex-end;
}

.btn-primary {
  padding: 8px 14px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: #fff;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
}

.btn-explore {
  position: absolute;
  right: var(--spacing-base);
  bottom: var(--spacing-base);
  background: #fbbf24; /* amber-400 */
  color: #000;
  border: none;
  border-radius: 9999px;
  padding: 16px 28px;
  font-weight: 700;
  font-size: 16px;
  box-shadow: 0 10px 24px rgba(251, 191, 36, 0.5);
  cursor: pointer;
}

.btn-explore:hover {
  filter: brightness(1.05);
}

.btn-deep {
  position: absolute;
  left: var(--spacing-base);
  bottom: var(--spacing-base);
  background: rgba(255,255,255,0.9);
  color: #111;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 9999px;
  padding: 12px 20px;
  font-weight: 700;
  box-shadow: 0 6px 16px rgba(0,0,0,0.12);
  cursor: pointer;
}

.btn-highlight {
  position: absolute;
  left: var(--spacing-base);
  bottom: calc(var(--spacing-base) + 56px);
  background: rgba(255,255,255,0.9);
  color: #111;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 9999px;
  padding: 12px 20px;
  font-weight: 700;
  box-shadow: 0 6px 16px rgba(0,0,0,0.12);
  cursor: pointer;
}

.overlay-controls {
  position: absolute;
  top: var(--spacing-base);
  right: var(--spacing-base);
  display: flex;
  gap: var(--spacing-small);
  z-index: 5;
}

.btn-text {
  padding: 8px 14px;
  background: rgba(0,0,0,0.35);
  color: #fff;
  border: 1px solid rgba(255,255,255,0.35);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: var(--transition-base);
  backdrop-filter: blur(6px);
}

.btn-text:hover {
  background: rgba(255,255,255,0.15);
}
</style>
