<template>
  <div class="deep-page">
    <div class="header">场景化地理知识深度探索</div>
    <div class="grid">
      <div class="card" @click="enter('scene1')">
        <div class="thumb" :style="{ backgroundImage: thumbs.scene1 }"></div>
        <div class="title">场景1 · 火山喷发</div>
      </div>
      <div class="card" @click="enter('scene2')">
        <div class="thumb" :style="{ backgroundImage: thumbs.scene2 }"></div>
        <div class="title">场景2 · 季风环流</div>
      </div>
      <div class="card" @click="enter('scene3')">
        <div class="thumb" :style="{ backgroundImage: thumbs.scene3 }"></div>
        <div class="title">场景3 · 喀斯特溶洞</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const thumbs = ref<{[k:string]: string}>({ scene1: 'none', scene2: 'none', scene3: 'none' })

const candidates: Record<string, string[]> = {
  scene1: ['/场景1.jpg','/场景1.png','/场景一.jpg','/场景1.jpeg'],
  scene2: ['/场景2.jpg','/场景2.png','/场景二.jpg','/场景2.jpeg'],
  scene3: ['/场景3.jpg','/场景3.png','/场景三.jpg','/场景3.jpeg']
}

function enter(scene: 'scene1'|'scene2'|'scene3') {
  router.push({ path: '/feature/interactive/explore', query: { scene } })
}

onMounted(async () => {
  for (const key of Object.keys(candidates)) {
    const list = candidates[key]
    for (const u of list) {
      const ok = await pingImage(u)
      if (ok) { thumbs.value[key] = `url(${u})`; break }
    }
  }
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
.deep-page {
  min-height: 100vh;
  padding: 24px;
  background: #0b1220;
  color: #fff;
}
.header { font-size: 18px; font-weight: 700; margin-bottom: 16px; }
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
}
.card {
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: transform .12s ease;
}
.card:hover { transform: translateY(-2px); }
.thumb {
  height: 160px;
  background-size: cover; background-position: center;
}
.title { padding: 12px; font-weight: 600; }
</style>
