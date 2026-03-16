<template>
  <div class="hl-wrap" @mousemove="onParallax">
    <!-- 背景层：游戏1/游戏2 叠加形成动感舞台 -->
    <div class="bg bg1" :style="{ backgroundImage: bg1 }"></div>
    <div class="bg bg2" :style="{ backgroundImage: bg2, transform: parallax }"></div>

    <!-- 霓虹装饰与粒子特效 -->
    <div class="glow glow-tl"></div>
    <div class="glow glow-br"></div>
    <div class="particles"></div>

    <!-- 中央交互主卡：三大特色，用图标+短标题呈现 -->
    <div class="stage">
      <div class="badge-row">
        <div class="badge" title="地理真实感">
          <div class="icon earth"></div>
          <div class="label">地理真实感</div>
        </div>
        <div class="badge" title="游戏趣味性">
          <div class="icon game"></div>
          <div class="label">游戏趣味性</div>
        </div>
        <div class="badge" title="个性化拓展">
          <div class="icon spark"></div>
          <div class="label">个性化拓展</div>
        </div>
      </div>

      <div class="cta-row">
        <button class="cta" @click="goDeep">开始探索</button>
        <button class="cta ghost" @click="back">返回模块</button>
      </div>
    </div>
  </div>
  
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
const router = useRouter()

const bg1 = ref('none') // 游戏1
const bg2 = ref('none') // 游戏2
const parallax = ref('translate3d(0px,0px,0)')

const c1 = ['/游戏1.jpg','/游戏1.png','/游戏一.jpg','/game1.jpg','/game1.png']
const c2 = ['/游戏2.jpg','/游戏2.png','/游戏二.jpg','/game2.jpg','/game2.png']

function onParallax(e: MouseEvent) {
  const x = (e.clientX / window.innerWidth - 0.5) * 10
  const y = (e.clientY / window.innerHeight - 0.5) * 10
  parallax.value = `translate3d(${x}px, ${y}px, 0)`
}

function goDeep() { router.push('/feature/interactive/deep') }
function back() { router.push('/feature/interactive') }

onMounted(async () => {
  for (const u of c1) { if (await ping(u)) { bg1.value = `url(${u})`; break } }
  for (const u of c2) { if (await ping(u)) { bg2.value = `url(${u})`; break } }
})

function ping(url: string): Promise<boolean> {
  return new Promise((resolve) => { const i = new Image(); i.onload=()=>resolve(true); i.onerror=()=>resolve(false); i.src=url })
}
</script>

<style scoped>
.hl-wrap {
  position: relative; min-height: 100vh; overflow: hidden; background: #05070e;
}
.bg { position: absolute; inset: 0; background-size: cover; background-position: center; }
.bg1 { filter: brightness(0.85) contrast(1.05); animation: slow-zoom 18s ease-in-out infinite alternate; }
.bg2 { mix-blend-mode: screen; opacity: 0.55; animation: float 12s ease-in-out infinite; }

.glow { position: absolute; width: 38vw; height: 38vw; border-radius: 50%; filter: blur(80px); opacity: 0.28; pointer-events: none; }
.glow-tl { left: -10vw; top: -10vw; background: radial-gradient(closest-side, #2dd4bf, transparent); }
.glow-br { right: -12vw; bottom: -12vw; background: radial-gradient(closest-side, #60a5fa, transparent); }

.particles { position: absolute; inset: 0; pointer-events: none; background-image: radial-gradient(#ffffff66 1px, transparent 1px); background-size: 3px 3px; opacity: .13; animation: twinkle 4s linear infinite; }

.stage {
  position: relative; z-index: 2; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; gap: 24px;
}

.badge-row { display: grid; grid-template-columns: repeat(auto-fit,minmax(200px,1fr)); gap: 18px; width: min(1000px, 90vw); }
.badge {
  height: 160px; border-radius: 16px; backdrop-filter: blur(8px);
  background: linear-gradient(180deg, rgba(255,255,255,0.14), rgba(255,255,255,0.06));
  border: 1px solid rgba(255,255,255,0.18);
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; color: #e7f3ff;
  box-shadow: 0 8px 24px rgba(0,0,0,0.25); transition: transform .18s ease, filter .18s ease;
}
.badge:hover { transform: translateY(-6px) scale(1.02); filter: brightness(1.03); }

.icon { width: 56px; height: 56px; border-radius: 14px; background: rgba(255,255,255,0.18); border: 1px solid rgba(255,255,255,0.25); box-shadow: inset 0 0 12px rgba(0,0,0,0.25); position: relative; }
.icon::after { content: ''; position: absolute; inset: 0; background-position: center; background-repeat: no-repeat; background-size: 70%; filter: drop-shadow(0 2px 2px rgba(0,0,0,0.35)); }
.icon.earth::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="72" height="72" viewBox="0 0 24 24" fill="%23a7f3d0"><path d="M12 2a10 10 0 100 20 10 10 0 000-20zm-1 3.1A8 8 0 0119 12h-2.5l-1.5 2-2 .5L11 13l-2-1-1 2-2-1 1-3 2-1 2-2zm1 13.8A8 8 0 015 12h2l2 1 1 2 2 .5 1.5-1.5H19a8 8 0 01-6 3.4z"/></svg>'); }
.icon.game::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="72" height="72" viewBox="0 0 24 24" fill="%23bfdbfe"><path d="M6 7h12a4 4 0 014 4v6a2 2 0 01-2 2h-2l-3-3H9l-3 3H4a2 2 0 01-2-2v-6a4 4 0 014-4zm2 4H7v1H6v1h1v1h1v-1h1v-1H8v-1zm8 2a1 1 0 100-2 1 1 0 000 2zm2 1a1 1 0 100-2 1 1 0 000 2z"/></svg>'); }
.icon.spark::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="72" height="72" viewBox="0 0 24 24" fill="%23fde68a"><path d="M11 2l2 6h6l-5 4 2 6-5-4-5 4 2-6-5-4h6z"/></svg>'); }
.label { font-weight: 800; letter-spacing: .5px; }

.cta-row { display: flex; gap: 12px; }
.cta { background: #22d3ee; color: #0b1220; border: none; border-radius: 999px; padding: 12px 22px; font-weight: 800; box-shadow: 0 12px 24px rgba(34,211,238,0.3); }
.cta.ghost { background: rgba(255,255,255,0.85); color: #0b1220; box-shadow: 0 8px 18px rgba(255,255,255,0.2); }
.cta:hover { filter: brightness(1.05); }

@keyframes slow-zoom { from { transform: scale(1); } to { transform: scale(1.08); } }
@keyframes float { 0% { transform: translateY(0); } 50% { transform: translateY(-8px); } 100% { transform: translateY(0); } }
@keyframes twinkle { 0%,100% { opacity: .13 } 50% { opacity: .23 } }

@media (max-width: 768px) {
  .badge { height: 140px; }
  .icon { width: 48px; height: 48px; }
}
</style>
