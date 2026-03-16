<template>
  <div class="explore-page" :style="{ backgroundImage: pageBg }" @click="maybeExitFocus">
    <!-- 左侧虚拟摇杆 -->
    <div class="joystick" ref="joystick" @touchstart.prevent @touchmove.prevent="onMove" @touchend="onEnd">
      <div class="stick" :style="stickStyle"></div>
    </div>

    <!-- 右侧功能按键 -->
    <div class="actions">
      <button class="btn action" @mousedown="explorePressStart" @mouseup="explorePressEnd" @touchstart.passive="explorePressStart" @touchend.passive="explorePressEnd" @click.prevent="onExplore">探索</button>
      <button class="btn action" @click="onTools">工具</button>
      <button class="btn action" @click="onRecord">记录</button>
      <button class="btn action" @click="onTask">任务</button>
    </div>

    <!-- 提示/状态 -->
    <div class="hud">
      <div>速度：{{ (speed).toFixed(2) }}</div>
      <div>方向：{{ direction.toFixed(0) }}°</div>
      <div>地形：{{ terrainLabel }}</div>
      <div>动作：{{ movementMode }}</div>
    </div>

    <!-- 聚焦观测模式：中心准星 + 放大镜 + 知识点弹窗 -->
    <div v-if="focusMode" class="reticle" />
    <div v-if="focusMode" class="magnifier">
      <div class="mag-bg" :style="{ backgroundImage: pageBg }"></div>
    </div>
    <div v-if="focusMode && showKnowledge" class="knowledge">
      <div class="k-title">知识点</div>
      <div class="k-body">{{ knowledgeText }}</div>
      <div class="k-hint">长按“探索”开始录音提问，再次松开结束</div>
      <button class="k-close" @click.stop="closeKnowledge">知道了</button>
    </div>

  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// 摇杆状态
const joystick = ref<HTMLDivElement | null>(null)
const center = ref({ x: 0, y: 0 })
const drag = ref({ x: 0, y: 0 })
const active = ref(false)
const maxRadius = 60

// 速度与方向
const speed = ref(0)
const direction = ref(0)
const movementMode = ref('静止')

// 场景参数（影响移动阻力/坡度/背景）
const scene = computed(() => String(route.query.scene || 'scene1'))

// 背景：根据 scene1/2/3 选择对应图片（多命名回退）；兼容旧 scene 名称
const candidates: Record<string, string[]> = {
  scene1: ['/场景1.jpg','/场景1.png','/场景一.jpg','/scene1.jpg','/scene1.png'],
  scene2: ['/场景2.jpg','/场景2.png','/场景二.jpg','/scene2.jpg','/scene2.png'],
  scene3: ['/场景3.jpg','/场景3.png','/场景三.jpg','/scene3.jpg','/场景3.png'],
  // 兼容旧：home/glacier/rainforest - 统一使用情景互动4.jpg
  home: ['/情景互动4.jpg'],
  glacier: ['/情景互动4.jpg'],
  rainforest: ['/情景互动4.jpg']
}
const bgUrl = ref<string>('')
const pageBg = computed(() => (bgUrl.value ? `url(${bgUrl.value})` : 'none'))

const terrainLabel = computed(() => {
  if (scene.value === 'scene1') return '火山地形/高温'
  if (scene.value === 'scene2') return '季风环流/降雨'
  if (scene.value === 'scene3') return '喀斯特溶洞/地下河'
  return scene.value === 'glacier' ? '冰川/涉水' : scene.value === 'rainforest' ? '雨林/涉水' : '平地/山地'
})

function onMove(e: TouchEvent) {
  if (!joystick.value) return
  const rect = joystick.value.getBoundingClientRect()
  const t = e.touches[0]
  const x = t.clientX - rect.left
  const y = t.clientY - rect.top
  if (!active.value) {
    active.value = true
    center.value = { x, y }
  }
  const dx = x - center.value.x
  const dy = y - center.value.y
  const r = Math.hypot(dx, dy)
  const ang = Math.atan2(dy, dx)
  const clamped = Math.min(r, maxRadius)
  drag.value = { x: Math.cos(ang) * clamped, y: Math.sin(ang) * clamped }

  // 基础速度（0~1）
  let base = clamped / maxRadius

  // 地形阻力与坡度减速：涉水阻力更大
  let resistance = 1
  if (scene.value === 'glacier') resistance = 0.6
  else if (scene.value === 'rainforest') resistance = 0.75

  // 简化坡度影响：向上（90°）速度更慢
  const deg = (ang * 180) / Math.PI
  const uphillFactor = deg > 45 && deg < 135 ? 0.7 : 1.0

  // 涉水需要更大力度：对输入做非线性压缩，提升“阻力感”
  const isWading = scene.value === 'glacier' || scene.value === 'rainforest' || scene.value === 'scene2' || scene.value === 'scene3'
  const inputAdjusted = isWading ? Math.pow(base, 1.25) : base

  speed.value = inputAdjusted * resistance * uphillFactor
  direction.value = (deg + 360) % 360

  // 动作模式判定
  if (speed.value < 0.05) {
    movementMode.value = '静止'
  } else if (uphillFactor < 1 && inputAdjusted > 0.2) {
    movementMode.value = '攀爬'
  } else if (isWading && inputAdjusted > 0.2) {
    movementMode.value = '涉水'
  } else if (inputAdjusted > 0.7) {
    movementMode.value = '奔跑'
  } else {
    movementMode.value = '行走'
  }
}

function onEnd() {
  active.value = false
  drag.value = { x: 0, y: 0 }
  speed.value = 0
  movementMode.value = '静止'
}

const stickStyle = computed(() => ({ transform: `translate(${drag.value.x}px, ${drag.value.y}px)` }))

// 聚焦观测模式
const focusMode = ref(false)
const showKnowledge = ref(false)
const knowledgeText = computed(() => {
  if (scene.value === 'scene1') return '火山喷发：靠近岩浆流区域温度可达800℃；岩浆冷却后可能形成玄武岩（细晶结构）'
  if (scene.value === 'scene2') return '季风环流：冬季西北风偏冷干、夏季海洋暖湿气流带来锋面雨，受地转偏向力影响'
  if (scene.value === 'scene3') return '喀斯特地貌：钟乳石自上而下、石笋自下而上生长；溶蚀作用形成溶洞与地下暗河'
  if (scene.value === 'glacier') return '冰川侵蚀地貌：角峰、刃脊、U形谷形成于冰川刨蚀与搬运作用'
  if (scene.value === 'rainforest') return '热带雨林植物叶片具滴水尖，有利于迅速甩落水分；土壤腐殖质丰富'
  return '花岗岩球状风化：昼夜温差导致岩体表层膨胀收缩，促成外层剥落'
})

function onExplore() {
  focusMode.value = !focusMode.value
  showKnowledge.value = false
  if (focusMode.value) {
    // 进入后延时展示知识点
    setTimeout(() => { if (focusMode.value) showKnowledge.value = true }, 600)
  }
}

function closeKnowledge() { showKnowledge.value = false }
function maybeExitFocus() { if (focusMode.value && !showKnowledge.value) focusMode.value = false }

// 长按录音（占位）
let pressTimer: any = null
function explorePressStart() {
  clearTimeout(pressTimer)
  pressTimer = setTimeout(() => {
    alert('录音中…（占位）释放停止并保存到个人日志')
  }, 600)
}
function explorePressEnd() { clearTimeout(pressTimer) }
function onTools() {
  alert('工具库：海拔仪/土壤采样器/遥感扫描仪（占位）')
}
function onRecord() {
  alert('记录：拍照/绘图/标注并同步教师端（占位）')
}
function onTask() {
  alert('任务清单：完成目标解锁徽章与工具（占位）')
}

onMounted(() => {
  // 根据 scene 设置背景：逐个尝试
  const list = candidates[scene.value] || candidates.scene1
  ;(async () => {
    for (const u of list) {
      const ok = await pingImage(u)
      if (ok) { bgUrl.value = u; break }
    }
  })()
})

function pingImage(url: string): Promise<boolean> {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => resolve(true)
    img.onerror = () => resolve(false)
    img.src = url
  })
}
</script>

<style scoped>
.explore-page {
  position: relative;
  width: 100%;
  height: 100vh;
  background: #0b1220; /* 兜底颜色 */
  background-size: cover;
  background-position: center;
  overflow: hidden;
}

.joystick {
  position: absolute;
  left: 18px;
  bottom: 18px;
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: rgba(255,255,255,0.08);
  backdrop-filter: blur(6px);
  border: 1px solid rgba(255,255,255,0.15);
}

.stick {
  position: absolute;
  left: calc(50% - 26px);
  top: calc(50% - 26px);
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: rgba(255,255,255,0.25);
  border: 1px solid rgba(255,255,255,0.4);
  transition: transform 40ms linear;
}

.actions {
  position: absolute;
  right: 18px;
  bottom: 18px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  background: rgba(240,240,240,0.9);
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 14px;
  padding: 12px;
  width: 20vw;
  height: 40vh;
  overflow: auto;
}

.btn.action {
  width: 100%;
  height: 64px;
  border-radius: 12px;
  background: linear-gradient(180deg, #ffffff 0%, #f6f7fb 100%);
  border: 1px solid rgba(0,0,0,0.08);
  color: #111;
  font-weight: 700;
  font-size: 16px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.06);
}
.btn.action:hover { filter: brightness(0.98); }

.hud {
  position: absolute;
  top: 12px;
  left: 12px;
  color: #222;
  font-size: 13px;
  background: rgba(240,240,240,0.92);
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,0.08);
}

/* 中心准星 */
.reticle {
  position: absolute;
  left: 50%; top: 50%;
  width: 40px; height: 40px;
  transform: translate(-50%, -50%);
  pointer-events: none;
}
.reticle::before, .reticle::after {
  content: '';
  position: absolute;
  left: 50%; top: 50%;
  transform: translate(-50%, -50%);
  background: rgba(255,255,255,0.9);
}
.reticle::before { width: 36px; height: 2px; }
.reticle::after { width: 2px; height: 36px; }

/* 放大镜（中心圆形） */
.magnifier {
  position: absolute;
  left: 50%; top: 50%;
  width: 180px; height: 180px;
  transform: translate(-50%, -50%);
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 8px 20px rgba(0,0,0,0.45), inset 0 0 0 2px rgba(255,255,255,0.6);
}
.magnifier .mag-bg {
  position: absolute; inset: 0;
  background-size: 140% 140%;
  background-position: center;
  filter: contrast(1.05) saturate(1.05);
  transform: scale(1.02);
}

/* 知识点弹窗 */
.knowledge {
  position: absolute;
  left: 50%; top: calc(50% + 120px);
  transform: translateX(-50%);
  width: min(92vw, 520px);
  background: rgba(0,0,0,0.6);
  color: #fff;
  border: 1px solid rgba(255,255,255,0.25);
  border-radius: 12px;
  padding: 12px 14px;
  backdrop-filter: blur(8px);
}
.k-title { font-weight: 700; margin-bottom: 6px; }
.k-body { line-height: 1.6; margin-bottom: 8px; }
.k-hint { font-size: 12px; opacity: 0.85; margin-bottom: 8px; }
.k-close { background: #fbbf24; color: #000; border: none; border-radius: 8px; padding: 6px 10px; font-weight: 600; }

@media (max-width: 768px) {
  .joystick {
    width: 140px; height: 140px;
  }
  .stick { width: 48px; height: 48px; left: calc(50% - 24px); top: calc(50% - 24px); }
  .btn.action { width: 100%; height: 56px; font-size: 15px; }
}
</style>
