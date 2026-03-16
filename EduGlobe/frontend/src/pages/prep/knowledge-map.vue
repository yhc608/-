<template>
  <div class="knowledge-map">
    <!-- 顶部工具栏 -->
    <div class="toolbar">
      <div class="mode-switch">
        <button 
          v-for="mode in modes" 
          :key="mode.value"
          class="btn-text"
          :class="{ active: currentMode === mode.value }"
          @click="currentMode = mode.value"
        >
          <span class="material-icons">{{ mode.icon }}</span>
          {{ mode.label }}
        </button>
      </div>

      <div class="difficulty-switch">
        <button 
          v-for="level in difficultyLevels" 
          :key="level.value"
          class="btn-text"
          :class="{ active: currentDifficulty === level.value }"
          @click="currentDifficulty = level.value"
        >
          {{ level.label }}
        </button>
      </div>
    </div>

    <!-- 知识图谱容器 -->
    <div class="map-container" ref="mapContainer">
      <!-- 加载提示 -->
      <div v-if="loading" class="loading">
        <span class="material-icons spinning">refresh</span>
        正在加载知识图谱...
      </div>

      <!-- 2.5D知识网络 -->
      <div v-show="!loading" class="network" ref="networkContainer"></div>
    </div>

    <!-- 知识卡片弹窗 -->
    <div v-if="showCard" class="card-modal" @click.self="showCard = false">
      <div class="knowledge-card">
        <div class="card-header">
          <h3>{{ currentCard.title }}</h3>
          <button class="btn-icon" @click="showCard = false">
            <span class="material-icons">close</span>
          </button>
        </div>

        <div class="card-content">
          <div class="definition">
            <h4>概念定义</h4>
            <p>{{ currentCard.definition }}</p>
          </div>

          <div class="textbook-ref">
            <h4>教材对应</h4>
            <div class="tag">人教版必修一 P{{ currentCard.page }}</div>
          </div>

          <div class="quick-test">
            <h4>速查检测</h4>
            <div class="question">{{ currentCard.question }}</div>
            <div class="options">
              <button 
                v-for="option in currentCard.options" 
                :key="option.value"
                class="option-btn"
                :class="{ 
                  correct: showAnswer && option.value === currentCard.answer,
                  wrong: showAnswer && selectedOption === option.value && option.value !== currentCard.answer
                }"
                @click="checkAnswer(option.value)"
              >
                {{ option.label }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'

// 状态定义
const currentMode = ref('basic')
const currentDifficulty = ref('basic')
const loading = ref(true)
const showCard = ref(false)
const selectedOption = ref('')
const showAnswer = ref(false)

// 配置项
const modes = [
  { value: 'basic', label: '基础模式', icon: 'view_module' },
  { value: 'animation', label: '动画模式', icon: 'play_circle' },
  { value: 'mindmap', label: '思维导图', icon: 'account_tree' }
]

const difficultyLevels = [
  { value: 'basic', label: '基础' },
  { value: 'advanced', label: '进阶' }
]

// 模拟数据
const currentCard = ref({
  title: '季风成因',
  definition: '季风是由于海陆温差形成的周期性风向交替变化现象。夏季，陆地增温快，形成低压，海洋增温慢，形成高压，风从海洋吹向陆地；冬季相反。',
  page: 42,
  question: '下列哪项不是影响季风形成的主要因素？',
  options: [
    { value: 'A', label: '海陆温差' },
    { value: 'B', label: '地转偏向力' },
    { value: 'C', label: '地形地势' },
    { value: 'D', label: '洋流方向' }
  ],
  answer: 'D'
})

// Three.js 相关
const mapContainer = ref<HTMLElement>()
const networkContainer = ref<HTMLElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls

// 初始化3D场景
function initScene() {
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xf5f5f5)

  camera = new THREE.PerspectiveCamera(
    75,
    networkContainer.value!.clientWidth / networkContainer.value!.clientHeight,
    0.1,
    1000
  )
  camera.position.z = 5

  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(networkContainer.value!.clientWidth, networkContainer.value!.clientHeight)
  networkContainer.value!.appendChild(renderer.domElement)

  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  controls.dampingFactor = 0.05

  // 添加环境光
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6)
  scene.add(ambientLight)

  // 添加平行光
  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.4)
  directionalLight.position.set(10, 10, 10)
  scene.add(directionalLight)

  // 创建知识节点
  createKnowledgeNodes()

  animate()
  loading.value = false
}

// 创建知识节点
function createKnowledgeNodes() {
  // 创建节点几何体
  const geometry = new THREE.SphereGeometry(0.2, 32, 32)
  const material = new THREE.MeshPhongMaterial({ color: 0x4A90E2 })
  
  // 添加多个节点
  for (let i = 0; i < 10; i++) {
    const node = new THREE.Mesh(geometry, material)
    node.position.x = (Math.random() - 0.5) * 5
    node.position.y = (Math.random() - 0.5) * 5
    node.position.z = (Math.random() - 0.5) * 2
    scene.add(node)
  }

  // 添加连线
  const lineMaterial = new THREE.LineBasicMaterial({ color: 0xcccccc })
  for (let i = 0; i < 15; i++) {
    const points = []
    points.push(
      new THREE.Vector3((Math.random() - 0.5) * 5, (Math.random() - 0.5) * 5, (Math.random() - 0.5) * 2),
      new THREE.Vector3((Math.random() - 0.5) * 5, (Math.random() - 0.5) * 5, (Math.random() - 0.5) * 2)
    )
    const geometry = new THREE.BufferGeometry().setFromPoints(points)
    const line = new THREE.Line(geometry, lineMaterial)
    scene.add(line)
  }
}

// 动画循环
function animate() {
  requestAnimationFrame(animate)
  controls.update()
  renderer.render(scene, camera)
}

// 检查答案
function checkAnswer(value: string) {
  selectedOption.value = value
  showAnswer.value = true
}

// 生命周期钩子
onMounted(() => {
  initScene()

  // 监听窗口大小变化
  window.addEventListener('resize', onWindowResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', onWindowResize)
  
  // 清理Three.js资源
  scene.clear()
  renderer.dispose()
})

// 窗口大小变化处理
function onWindowResize() {
  if (networkContainer.value) {
    camera.aspect = networkContainer.value.clientWidth / networkContainer.value.clientHeight
    camera.updateProjectionMatrix()
    renderer.setSize(networkContainer.value.clientWidth, networkContainer.value.clientHeight)
  }
}
</script>

<style scoped lang="scss">
.knowledge-map {
  height: calc(100vh - 180px);
  display: flex;
  flex-direction: column;
}

.toolbar {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-base);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.mode-switch,
.difficulty-switch {
  display: flex;
  gap: var(--spacing-small);
}

.map-container {
  flex: 1;
  background: white;
  border-radius: var(--radius-base);
  overflow: hidden;
  position: relative;
}

.network {
  width: 100%;
  height: 100%;
}

.loading {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  color: var(--color-text-secondary);

  .spinning {
    animation: spin 1s linear infinite;
  }
}

.card-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.knowledge-card {
  background: white;
  border-radius: var(--radius-large);
  width: 90%;
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
}

.card-header {
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;

  h3 {
    margin: 0;
    font-size: 1.2em;
  }
}

.card-content {
  padding: var(--spacing-base);

  h4 {
    margin: var(--spacing-base) 0 var(--spacing-small);
    color: var(--color-text-secondary);
    font-size: 1em;
  }
}

.options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-small);
  margin-top: var(--spacing-small);
}

.option-btn {
  padding: var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;
  }

  &.correct {
    background: #f6ffed;
    border-color: #b7eb8f;
    color: #52c41a;
  }

  &.wrong {
    background: #fff2f0;
    border-color: #ffccc7;
    color: #ff4d4f;
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
