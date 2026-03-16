<template>
  <div class="ai-overview" @mousemove="onParallax">
    <div class="page-title">
      <div class="chip">AI地理伴学</div>
      <h1>课堂进度 · 学情双维锚定</h1>
      <div class="subtitle">知识元 · 知识链 · 知识面 · 知识空间</div>
      <div class="cta-row">
        <button class="btn primary" @click="openDesk">伴学任务台</button>
        <button class="btn ghost" @click="openConfig">资源校准设置</button>
      </div>
    </div>
    <!-- 立体知识网络（四阶递进） -->
    <section class="hero">
      <div class="hero-bg"></div>

      <!-- 中心知识立方体与旋转环 -->
      <div class="cube-wrap" :style="{ transform: parallax }">
        <div class="cube">
          <div class="face f1">知识元</div>
          <div class="face f2"></div>
          <div class="face f3"></div>
        </div>
        <div class="orbit o1"></div>
        <div class="orbit o2"></div>
      </div>

      <!-- 四阶节点卡片 -->
      <div class="tier t1">
        <div class="tier-title">知识面</div>
        <div class="chips">
          <div class="chiplet">教育应用</div>
          <div class="chiplet">科研探索</div>
          <div class="chiplet">产业实践</div>
        </div>
      </div>
      <div class="tier t2">
        <div class="tier-title">知识空间</div>
        <div class="chips">
          <div class="chiplet">学科交叉</div>
          <div class="chiplet">体系建设</div>
          <div class="chiplet">知识迁移</div>
        </div>
      </div>
      <div class="tier t3">
        <div class="tier-title">方法延伸</div>
        <div class="chips">
          <div class="chiplet">概念关联</div>
          <div class="chiplet">因果建模</div>
          <div class="chiplet">路径迁移</div>
          <div class="chiplet">策略拓展</div>
        </div>
      </div>
      <div class="tier t4">
        <div class="tier-title">原理推导</div>
        <div class="chips">
          <div class="chiplet">因果建模</div>
          <div class="chiplet">规律解析</div>
          <div class="chiplet">产业延伸</div>
          <div class="chiplet">逻辑建模</div>
        </div>
      </div>

      <!-- 连接线（SVG 动画） -->
      <svg class="links" viewBox="0 0 100 100" preserveAspectRatio="none">
        <defs>
          <linearGradient id="g1" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="#22d3ee"/>
            <stop offset="100%" stop-color="#60a5fa"/>
          </linearGradient>
        </defs>
        <path class="link" d="M50,50 C35,40 28,32 20,28"/>
        <path class="link" d="M50,50 C65,40 78,32 85,25"/>
        <path class="link" d="M50,50 C38,65 30,72 18,80"/>
        <path class="link" d="M50,50 C64,65 75,75 88,82"/>
      </svg>
    </section>

    <!-- 自然过渡分隔：波形衔接 -->
    <svg class="separator" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true">
      <path d="M0,80 C240,20 480,140 720,80 C960,20 1200,140 1440,80 L1440,120 L0,120 Z" fill="url(#sep)"/>
      <defs>
        <linearGradient id="sep" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#071427"/>
          <stop offset="100%" stop-color="#0b0720"/>
        </linearGradient>
      </defs>
    </svg>

    <!-- 班级-个人学情图谱与三阶资源重组 -->
    <section class="graph">
      <div class="graph-bg"></div>
      <div class="legend">
        <div class="step"><span class="dot"></span>认知理解</div>
        <div class="step"><span class="dot"></span>实践应用</div>
        <div class="step"><span class="dot"></span>迁移创新</div>
      </div>

      <!-- 数据采集源（左）-->
      <div class="sources">
        <div class="src"><span class="ico bars"></span><span class="txt">答题数据</span></div>
        <div class="src"><span class="ico wave"></span><span class="txt">答题次数</span></div>
        <div class="src"><span class="ico pulse"></span><span class="txt">互动分次</span></div>
        <div class="src"><span class="ico face"></span><span class="txt">专注度</span></div>
        <div class="src"><span class="ico bubble"></span><span class="txt">课堂提问语义</span></div>
        <div class="src"><span class="ico sensor"></span><span class="txt">模态学情采集</span></div>
      </div>

      <!-- 流动曲线（SVG）-->
      <svg class="flow" viewBox="0 0 100 44" preserveAspectRatio="none">
        <defs>
          <linearGradient id="f" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stop-color="#22d3ee"/>
            <stop offset="100%" stop-color="#a78bfa"/>
          </linearGradient>
        </defs>
        <path class="stream s1" d="M2,10 C25,10 40,18 60,18 C78,18 92,12 98,12"/>
        <path class="stream s2" d="M2,22 C25,22 40,26 60,26 C78,26 92,20 98,20"/>
        <path class="stream s3" d="M2,34 C25,34 40,34 60,34 C78,34 92,28 98,28"/>
      </svg>

      <!-- 三阶段目标卡片（右）-->
      <div class="stage-cards">
        <div class="st-card">
          <div class="st-title">认知理解</div>
          <div class="mini">知识点浓缩微课</div>
        </div>
        <div class="st-card">
          <div class="st-title">实践应用</div>
          <div class="mini">对比式解析资源</div>
        </div>
        <div class="st-card">
          <div class="st-title">迁移创新</div>
          <div class="mini">跨科迁移任务</div>
        </div>
      </div>

      <!-- 指标卡与干预 -->
      <div class="metrics">
        <div class="m-card" @click="traceBack">
          <div class="num">92%</div>
          <div class="label">进度匹配度</div>
        </div>
        <div class="m-card">
          <div class="num">掌握率 76%</div>
          <div class="label">认知盲区分布</div>
        </div>
        <div class="m-card">
          <div class="num tag">大气环流·应用迁移弱</div>
          <div class="label">能力短板标签</div>
        </div>
        <button class="btn intervene" @click="intervene">一键智能干预</button>
      </div>

      <!-- 班级/个人维度图形集群 -->
      <div class="clusters">
        <div class="cluster class">
          <svg viewBox="0 0 120 80">
            <g fill="#22d3ee" opacity="0.85">
              <circle cx="20" cy="40" r="4"/>
              <circle cx="50" cy="20" r="4"/>
              <circle cx="50" cy="60" r="4"/>
              <circle cx="85" cy="35" r="4"/>
            </g>
            <g stroke="#22d3ee" stroke-width="1.5" opacity="0.6">
              <line x1="20" y1="40" x2="50" y2="20"/>
              <line x1="20" y1="40" x2="50" y2="60"/>
              <line x1="50" y1="60" x2="85" y2="35"/>
              <line x1="50" y1="20" x2="85" y2="35"/>
            </g>
          </svg>
          <div class="c-label">班级维段</div>
        </div>
        <div class="cluster personal">
          <svg viewBox="0 0 120 80">
            <g fill="#a78bfa" opacity="0.9">
              <circle cx="24" cy="52" r="5"/>
              <circle cx="44" cy="30" r="5"/>
              <circle cx="72" cy="46" r="5"/>
              <circle cx="96" cy="28" r="5"/>
            </g>
            <g stroke="#a78bfa" stroke-width="1.5" opacity="0.7">
              <polyline points="24,52 44,30 72,46 96,28" fill="none"/>
            </g>
          </svg>
          <div class="c-label">个人维段</div>
        </div>
      </div>
    </section>

    <!-- 波形过渡到“数据整合引擎” -->
    <svg class="separator" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true">
      <path d="M0,80 C240,20 480,140 720,80 C960,20 1200,140 1440,80 L1440,120 L0,120 Z" fill="url(#sep2)"/>
      <defs>
        <linearGradient id="sep2" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#0b0720"/>
          <stop offset="100%" stop-color="#06121f"/>
        </linearGradient>
      </defs>
    </svg>

    <section class="engine">
      <div class="engine-bg"></div>
      <div class="engine-head">
        <div class="title">本地化数据深度融合</div>
        <div class="badge">区域地理数据月报</div>
      </div>

      <!-- 三维数据整合引擎：官方直连 / 跨区联动 / 师生共创 -->
      <svg class="engine-links" viewBox="0 0 800 260" preserveAspectRatio="none">
        <defs>
          <linearGradient id="el" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stop-color="#22d3ee"/>
            <stop offset="100%" stop-color="#34d399"/>
          </linearGradient>
        </defs>
        <path d="M150,200 C300,120 500,120 650,200" stroke="url(#el)" stroke-width="3" fill="none" opacity="0.6"/>
        <path d="M150,60 C300,140 500,140 650,60" stroke="url(#el)" stroke-width="3" fill="none" opacity="0.4"/>
      </svg>

      <div class="engine-cards">
        <div class="e-card">
          <div class="e-icon govern"></div>
          <div class="e-title">官方直连</div>
          <div class="e-tags">
            <span>国家气象局</span>
            <span>地方自然资源局</span>
          </div>
        </div>
        <div class="e-card">
          <div class="e-icon link"></div>
          <div class="e-title">跨区联动</div>
          <div class="e-tags">
            <span>区域教研案例</span>
            <span>线上教材素材</span>
          </div>
        </div>
        <div class="e-card">
          <div class="e-icon cocreate"></div>
          <div class="e-title">师生共创</div>
          <div class="e-tags">
            <span>学生上传素材</span>
            <span>教师审核 · AI标注</span>
          </div>
        </div>
      </div>

      <div class="engine-footer">
        <div class="tip">同主题异区域 · 语义绑定对比库</div>
      </div>
    </section>

    <!-- 分隔至“地理思维拆解工具” -->
    <svg class="separator" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true">
      <path d="M0,80 C240,20 480,140 720,80 C960,20 1200,140 1440,80 L1440,120 L0,120 Z" fill="url(#sep3)"/>
      <defs>
        <linearGradient id="sep3" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#06121f"/>
          <stop offset="100%" stop-color="#eef1f5"/>
        </linearGradient>
      </defs>
    </svg>

    <!-- 地理思维拆解工具 -->
    <section class="thinking">
      <div class="thinking-bg"></div>

      <!-- 顶部：痛点与核心创新（图形徽章） -->
      <div class="pill-row">
        <div class="pill"><span class="dot"></span>隐性思维 → 可视步骤</div>
        <div class="pill"><span class="dot"></span>引导式拆解 + 路径对比</div>
        <div class="pill"><span class="dot"></span>从会做题 → 会思考</div>
      </div>

      <!-- 分层引导式答疑：维度拆解 + 阶梯引导 -->
      <div class="decomp">
        <div class="dim-card">
          <div class="dim-title">维度拆解</div>
          <div class="dim-tags">
            <span>自然条件</span>
            <span>经济条件</span>
            <span>社会条件</span>
          </div>
        </div>
        <div class="ladder">
          <div class="step">基础特征</div>
          <div class="step">因素关联</div>
          <div class="step">内在机理</div>
          <div class="step">综合结论</div>
        </div>
        <div class="dim-card">
          <div class="dim-title">逻辑补全</div>
          <div class="dim-tags">
            <span>缺失维度提示</span>
            <span>断点定位</span>
            <span>反馈纠偏</span>
          </div>
        </div>
      </div>

      <!-- 思维路径对比：个人 vs 名师 -->
      <div class="trees">
        <div class="tree-col">
          <div class="tree-title">个人思维树</div>
          <svg class="tree" viewBox="0 0 220 220" preserveAspectRatio="xMidYMid meet">
            <g stroke="#22d3ee" stroke-width="1.5" fill="none" opacity="0.7">
              <line x1="110" y1="40" x2="70" y2="90"/>
              <line x1="110" y1="40" x2="150" y2="90"/>
              <line x1="70" y1="90" x2="50" y2="140"/>
              <line x1="70" y1="90" x2="90" y2="140"/>
              <line x1="150" y1="90" x2="130" y2="140"/>
            </g>
            <g class="node" transform="translate(100,28)"><circle r="12" class="n core"/><text y="4">问题</text></g>
            <g class="node" transform="translate(60,90)"><circle r="10"/><text y="4">自然</text></g>
            <g class="node" transform="translate(160,90)"><circle r="10"/><text y="4">人为</text></g>
            <g class="node miss" transform="translate(40,140)"><circle r="8"/><text y="4">绿地</text></g>
            <g class="node" transform="translate(90,140)"><circle r="8"/><text y="4">地形</text></g>
            <g class="node" transform="translate(130,140)"><circle r="8"/><text y="4">辐射</text></g>
          </svg>
          <div class="hint">遗漏项以虚线/空心显示</div>
        </div>
        <div class="tree-col">
          <div class="tree-title">名师思维树</div>
          <svg class="tree" viewBox="0 0 220 220" preserveAspectRatio="xMidYMid meet">
            <g stroke="#a78bfa" stroke-width="1.5" fill="none" opacity="0.85">
              <line x1="110" y1="40" x2="70" y2="90"/>
              <line x1="110" y1="40" x2="150" y2="90"/>
              <line x1="70" y1="90" x2="50" y2="140"/>
              <line x1="70" y1="90" x2="90" y2="140"/>
              <line x1="150" y1="90" x2="130" y2="140"/>
              <line x1="150" y1="90" x2="170" y2="140"/>
            </g>
            <g class="node" transform="translate(100,28)"><circle r="12" class="n core master"/><text y="4">问题</text></g>
            <g class="node" transform="translate(60,90)"><circle r="10" class="master"/><text y="4">自然</text></g>
            <g class="node" transform="translate(160,90)"><circle r="10" class="master"/><text y="4">人为</text></g>
            <g class="node" transform="translate(40,140)"><circle r="8" class="good"/><text y="4">绿地</text></g>
            <g class="node" transform="translate(90,140)"><circle r="8" class="good"/><text y="4">地形</text></g>
            <g class="node" transform="translate(130,140)"><circle r="8" class="good"/><text y="4">辐射</text></g>
            <g class="node" transform="translate(170,140)"><circle r="8" class="good"/><text y="4">通风</text></g>
          </svg>
          <div class="hint ok">名师树为完整路径</div>
        </div>
      </div>
    </section>
  </div>
  
</template>

<script setup lang="ts">
import { ref } from 'vue'

const parallax = ref('translate3d(0,0,0)')

function onParallax(e: MouseEvent) {
  const x = (e.clientX / window.innerWidth - 0.5) * 12
  const y = (e.clientY / window.innerHeight - 0.5) * 8
  parallax.value = `translate3d(${x}px, ${y}px, 0)`
}

function openDesk() { alert('伴学任务台（占位）') }
function openConfig() { alert('资源校准设置（占位）') }
function intervene() { alert('已根据图谱触发：微课/对比资源/迁移任务（占位）') }
function traceBack() { alert('点击溯源：展示知识点的班级-个人学情明细（占位）') }
</script>

<style scoped>
.ai-overview { background: #05070e; color: #e8f1ff; min-height: 100vh; overflow-x: hidden; }

/* 顶部：立体知识网络 */
.page-title { text-align: center; padding: 18px 12px 8px; }
.page-title .chip { display: inline-block; padding: 6px 10px; border-radius: 999px; background: rgba(255,255,255,.9); color: #0b1220; font-weight: 800; margin-bottom: 8px; }
.page-title h1 { margin: 0 0 6px; font-size: clamp(22px, 3.2vw, 38px); font-weight: 900; }
.page-title .subtitle { opacity: .92; margin-bottom: 10px; font-weight: 700; }
.page-title .cta-row { justify-content: center; }

.hero { position: relative; min-height: 60vh; overflow: hidden; display: grid; place-items: center; padding-top: 12px; padding-bottom: 36px; }
.hero-bg { position: absolute; inset: 0; background: radial-gradient(80% 60% at 50% 0%, #0b2d3b 0%, #071427 60%, #05070e 100%); }
.cube-wrap { position: relative; width: clamp(180px, 20vw, 280px); height: clamp(180px, 20vw, 280px); filter: drop-shadow(0 24px 60px rgba(34,211,238,.18)); }
.cube { position: absolute; inset: 0; transform-style: preserve-3d; animation: spin 14s linear infinite; }
.face { position: absolute; inset: 0; display: grid; place-items: center; border-radius: 18px; background: linear-gradient(180deg, rgba(255,255,255,.15), rgba(255,255,255,.06)); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,.2); font-weight: 900; font-size: 28px; letter-spacing: 2px; color: #eafcff; text-shadow: 0 2px 8px rgba(0,0,0,.4); }
.f1 { transform: translateZ(40px); }
.f2 { transform: rotateY(90deg) translateZ(40px); }
.f3 { transform: rotateX(90deg) translateZ(40px); }
.orbit { position: absolute; inset: -12%; border-radius: 50%; border: 2px dashed rgba(34,211,238,.4); animation: orbit 10s linear infinite; }
.o2 { inset: -20%; animation-duration: 16s; border-color: rgba(96,165,250,.35); }

.tier { position: absolute; width: 160px; height: 90px; border-radius: 14px; text-align: center; display: grid; place-items: center; background: linear-gradient(180deg, rgba(255,255,255,.12), rgba(255,255,255,.06)); border: 1px solid rgba(255,255,255,.18); backdrop-filter: blur(6px); box-shadow: 0 8px 24px rgba(0,0,0,.25); font-weight: 700; }
.tier span { opacity: .9; font-size: 12px; }
.t1 { left: 6vw; top: 8vh; }
.t2 { right: 6vw; top: 10vh; }
.t3 { left: 8vw; bottom: 8vh; }
.t4 { right: 6vw; bottom: 10vh; }

.tier-title { font-weight: 900; margin-bottom: 6px; }
.chips { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; padding: 0 6px; }
.chiplet { position: relative; padding: 6px 10px 6px 24px; border-radius: 999px; background: linear-gradient(135deg, rgba(255,255,255,.22), rgba(255,255,255,.08)); border: 1px solid rgba(255,255,255,.22); font-weight: 800; font-size: 12px; }
.chiplet::before { content: ''; position: absolute; left: 8px; top: 50%; transform: translateY(-50%); width: 10px; height: 10px; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #22d3ee, #60a5fa); box-shadow: 0 0 10px rgba(34,211,238,.6); }

.links { position: absolute; inset: 0; z-index: 0; }
.link { fill: none; stroke: url(#g1); stroke-width: 1.8; stroke-dasharray: 6 8; animation: dash 2.4s linear infinite; opacity: .8; }

/* 下部：学情图谱与三阶重组 */
.graph { position: relative; padding: 22px; }
.legend { position: absolute; top: 18px; left: 22px; display: flex; gap: 12px; backdrop-filter: blur(6px); background: rgba(0,0,0,.25); padding: 8px 10px; border-radius: 12px; border: 1px solid rgba(255,255,255,.16); z-index: 2; }
.step { display: flex; align-items: center; gap: 6px; font-weight: 800; }
.step .dot { width: 8px; height: 8px; border-radius: 50%; background: #22d3ee; box-shadow: 0 0 10px #22d3ee; }

.sources { position: relative; z-index: 1; display: grid; gap: 8px; width: 160px; }
.src { background: rgba(255,255,255,.08); border: 1px solid rgba(255,255,255,.18); border-radius: 10px; padding: 8px 10px; display: flex; align-items: center; gap: 8px; font-weight: 700; }
.ico { width: 16px; height: 16px; display: inline-block; filter: drop-shadow(0 0 6px rgba(255,255,255,.25)); }
.ico.bars { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23ffffff"><rect x="3" y="14" width="4" height="7"/><rect x="10" y="9" width="4" height="12"/><rect x="17" y="5" width="4" height="16"/></svg>'); background-size: contain; background-repeat: no-repeat; }
.ico.wave { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%23ffffff" stroke-width="2"><path d="M2 12c4-4 6 4 10 0s6 4 10 0"/></svg>'); background-size: contain; background-repeat: no-repeat; }
.ico.pulse { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%23ffffff" stroke-width="2"><path d="M2 12h4l2-6 4 12 2-6h6"/></svg>'); background-size: contain; background-repeat: no-repeat; }
.ico.face { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23ffffff"><circle cx="8" cy="10" r="1.5"/><circle cx="16" cy="10" r="1.5"/><path d="M7 15c2 2 8 2 10 0"/></svg>'); background-size: contain; background-repeat: no-repeat; }
.ico.bubble { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23ffffff"><path d="M4 4h16v12H7l-3 3V4z"/></svg>'); background-size: contain; background-repeat: no-repeat; }
.ico.sensor { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%23ffffff" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 2v4M12 18v4M2 12h4M18 12h4M4.9 4.9l2.8 2.8M16.3 16.3l2.8 2.8M19.1 4.9l-2.8 2.8M7.7 16.3l-2.8 2.8"/></svg>'); background-size: contain; background-repeat: no-repeat; }

.flow { position: absolute; left: 160px; right: 260px; height: 180px; top: 40px; }
.stream { fill: none; stroke: url(#f); stroke-width: 2.2; stroke-linecap: round; stroke-dasharray: 8 200; animation: flow 3.2s ease-in-out infinite; opacity: .9; }
.s2 { animation-delay: .4s; opacity: .8 }
.s3 { animation-delay: .8s; opacity: .7 }

.stage-cards { position: absolute; right: 22px; top: 34px; display: grid; gap: 10px; width: 240px; }
.st-card { height: 86px; border-radius: 12px; background: linear-gradient(180deg, rgba(255,255,255,.12), rgba(255,255,255,.06)); border: 1px solid rgba(255,255,255,.18); backdrop-filter: blur(6px); box-shadow: 0 8px 24px rgba(0,0,0,.25); padding: 10px 12px; }
.st-title { font-weight: 900; margin-bottom: 6px; }
.mini { font-size: 12px; opacity: .9 }

.metrics { margin-top: 200px; display: grid; grid-template-columns: repeat(3, 1fr) auto; gap: 12px; align-items: center; }
.m-card { background: linear-gradient(180deg, rgba(255,255,255,.12), rgba(255,255,255,.06)); border: 1px solid rgba(255,255,255,.18); border-radius: 12px; padding: 12px; text-align: center; backdrop-filter: blur(6px); box-shadow: 0 8px 24px rgba(0,0,0,.25); }
.m-card .num { font-size: 22px; font-weight: 900; margin-bottom: 4px; }
.m-card .tag { font-weight: 800; font-size: 14px; }
.m-card .label { opacity: .9; font-weight: 700; }
.btn.intervene { height: 44px; padding: 0 16px; background: #22d3ee; color: #0b1220; box-shadow: 0 10px 20px rgba(34,211,238,.25); border: none; border-radius: 10px; font-weight: 800; }

/* 班级 / 个人维段：同一水平线并缩小图形 */
.clusters { margin-top: 12px; display: flex; justify-content: center; align-items: center; gap: 18px; }
.cluster { display: flex; flex-direction: column; align-items: center; gap: 6px; }
.cluster svg { width: 140px; height: 90px; }
.c-label { font-size: 12px; opacity: .9; }

/* 思维拆解工具样式（浅灰背景 + 树同排 + 缩小） */
.thinking { position: relative; padding: 22px 18px 28px; background: #eef1f5; }
.thinking-bg { position: absolute; inset: 0; background: radial-gradient(120% 100% at 50% -10%, rgba(255,255,255,0.9) 0%, rgba(238,241,245,1) 60%, rgba(230,234,240,1) 100%); z-index: 0; }
.pill-row { position: relative; z-index: 1; display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; margin-bottom: 12px; }
.pill { background: #fff; color: #0b1220; border: 1px solid rgba(0,0,0,0.06); border-radius: 999px; padding: 8px 12px; font-weight: 800; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 6px 16px rgba(0,0,0,0.06); }
.pill .dot { width: 8px; height: 8px; border-radius: 50%; background: linear-gradient(135deg, #22d3ee, #60a5fa); box-shadow: 0 0 8px rgba(34,211,238,0.6); }
.decomp { position: relative; z-index: 1; display: grid; grid-template-columns: 1fr auto 1fr; gap: 12px; align-items: center; margin-bottom: 10px; }
.dim-card { background: #fff; border: 1px solid rgba(0,0,0,0.06); border-radius: 12px; padding: 12px; box-shadow: 0 6px 16px rgba(0,0,0,0.06); }
.dim-title { font-weight: 900; margin-bottom: 6px; color: #0b1220; }
.dim-tags { display: flex; flex-wrap: wrap; gap: 6px; }
.dim-tags span { position: relative; padding: 6px 10px 6px 22px; background: linear-gradient(180deg, #ffffff, #f6f7fb); border: 1px solid rgba(0,0,0,0.06); border-radius: 999px; font-weight: 800; }
.dim-tags span::before { content: ''; position: absolute; left: 8px; top: 50%; transform: translateY(-50%); width: 10px; height: 10px; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #34d399, #22d3ee); box-shadow: 0 0 8px rgba(34,211,238,0.5); }
.ladder { display: grid; gap: 8px; }
.ladder .step { background: #fff; border: 1px dashed rgba(0,0,0,0.12); border-radius: 999px; padding: 6px 12px; font-weight: 800; color: #0b1220; box-shadow: 0 6px 12px rgba(0,0,0,0.04); }
.trees { position: relative; z-index: 1; display: flex; justify-content: center; align-items: flex-start; gap: 16px; flex-wrap: nowrap; }
.tree-col { background: #f3f4f6; border: 1px solid rgba(0,0,0,0.06); border-radius: 14px; padding: 10px 12px; box-shadow: 0 8px 18px rgba(0,0,0,0.06); }
.tree-title { font-weight: 900; color: #0b1220; margin-bottom: 6px; text-align: center; }
.tree { width: 160px; height: 160px; background: #f3f4f6; border-radius: 10px; }
.node circle { fill: #ffffff; stroke: rgba(0,0,0,0.12); }
.node.miss circle { fill: none; stroke: #94a3b8; stroke-dasharray: 4 3; }
.node text { font-size: 10px; text-anchor: middle; fill: #0b1220; }
.node .master { fill: #f8f7ff; stroke: rgba(124,58,237,0.35); }
.node .good { fill: #f0fdf4; stroke: rgba(34,197,94,0.4); }
.n.core { fill: #ecfeff; stroke: rgba(34,211,238,0.4); }
.n.core.master { fill: #f5f3ff; stroke: rgba(124,58,237,0.4); }
.hint { text-align: center; font-size: 12px; color: #334155; opacity: .9; }
.hint.ok { color: #1f2937; }

@keyframes spin { from { transform: rotateX(0) rotateY(0); } to { transform: rotateX(360deg) rotateY(360deg); } }
@keyframes orbit { to { transform: rotate(360deg); } }
@keyframes dash { to { stroke-dashoffset: -200; } }
@keyframes flow { 0% { stroke-dashoffset: 0; } 100% { stroke-dashoffset: -208; } }

@media (max-width: 900px) {
  .tier { width: 40vw; max-width: 200px; }
  .t1 { left: 4vw; top: 6vh; }
  .t2 { right: 4vw; top: 8vh; }
  .t3 { left: 6vw; bottom: 6vh; }
  .t4 { right: 4vw; bottom: 8vh; }
  .stage-cards { width: 40vw; right: 16px; }
  .flow { left: 140px; right: 200px; }
}

@media (max-width: 768px) {
  .hero { min-height: 52vh; }
  .cube-wrap { width: 48vw; height: 48vw; }
  .stage-cards { position: static; width: 100%; grid-template-columns: repeat(3,1fr); margin-top: 12px; }
  .sources { grid-template-columns: 1fr 1fr; width: 100%; margin-bottom: 10px; }
  .flow { position: static; width: 100%; height: 120px; }
  .metrics { margin-top: 16px; grid-template-columns: 1fr; }
  .clusters { flex-direction: row; gap: 12px; }
  .cluster svg { width: 120px; height: 76px; }
}

/* ================= 第二核心功能：本地化数据深度融合 ================= */
</style>

<!-- removed duplicate template block: engine moved into primary template -->

<style scoped>
.engine { position: relative; padding: 26px 18px 36px; min-height: 42vh; }
.engine-bg { position: absolute; inset: 0; background: radial-gradient(70% 60% at 50% 0%, #06121f 0%, #071426 55%, #05070e 100%); z-index: 0; }
.engine-head { position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.engine-head .title { font-weight: 900; letter-spacing: .5px; }
.engine-head .badge { background: #22d3ee; color: #0b1220; border-radius: 999px; padding: 6px 10px; font-weight: 800; box-shadow: 0 8px 18px rgba(34,211,238,.25); border: none; }

.engine-links { position: absolute; inset: 0 0 auto 0; height: 260px; z-index: 0; pointer-events: none; }

.engine-cards { position: relative; z-index: 1; display: grid; grid-template-columns: repeat(3, minmax(220px, 1fr)); gap: 14px; align-items: start; }
.e-card { height: 160px; border-radius: 14px; background: linear-gradient(180deg, rgba(255,255,255,.12), rgba(255,255,255,.06)); border: 1px solid rgba(255,255,255,.18); backdrop-filter: blur(8px); box-shadow: 0 8px 24px rgba(0,0,0,.25); padding: 12px; display: grid; grid-template-columns: 64px 1fr; grid-template-areas: 'icon title' 'icon tags'; column-gap: 10px; align-items: center; }
.e-icon { grid-area: icon; width: 56px; height: 56px; border-radius: 14px; background: rgba(255,255,255,.18); border: 1px solid rgba(255,255,255,.25); box-shadow: inset 0 0 12px rgba(0,0,0,.25); position: relative; }
.e-icon::after { content: ''; position: absolute; inset: 0; background-position: center; background-repeat: no-repeat; background-size: 70%; filter: drop-shadow(0 2px 2px rgba(0,0,0,.35)); }
.e-icon.govern::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23a7f3d0"><path d="M12 2l9 5v2H3V7l9-5zm-9 9h18v2H3v-2zm2 4h14v5H5v-5z"/></svg>'); }
.e-icon.link::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23bfdbfe"><path d="M10 13a5 5 0 007.07 0l2.83-2.83a5 5 0 10-7.07-7.07L11 5"/><path d="M14 11a5 5 0 01-7.07 0L4.1 8.17a5 5 0 017.07-7.07L13 3" stroke="%23bfdbfe" stroke-width="2" fill="none"/></svg>'); }
.e-icon.cocreate::after { background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23fde68a"><path d="M12 2a5 5 0 015 5v1h1a4 4 0 014 4v8H2v-8a4 4 0 014-4h1V7a5 5 0 015-5z"/></svg>'); }
.e-title { grid-area: title; font-weight: 900; margin-bottom: 6px; }
.e-tags { grid-area: tags; display: flex; flex-wrap: wrap; gap: 6px; }
.e-tags span { padding: 6px 10px; border-radius: 999px; border: 1px solid rgba(255,255,255,.22); background: linear-gradient(135deg, rgba(255,255,255,.22), rgba(255,255,255,.08)); font-weight: 800; font-size: 12px; }

.engine-footer { margin-top: 12px; text-align: center; opacity: .9; font-weight: 700; }

@media (max-width: 900px) {
  .engine-cards { grid-template-columns: 1fr; }
  .e-card { height: auto; grid-template-columns: 56px 1fr; }
}
</style>
