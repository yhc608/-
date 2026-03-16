<template>
  <div class="experiment-scene">
    <div class="scene-container" ref="container"></div>
    <div class="scene-controls">
      <button
        :class="['control-btn', { active: isRunning }]"
        @click="toggleExperiment"
      >
        {{ isRunning ? '⏸ 暂停' : '▶️ 开始' }}
      </button>
      <button class="control-btn" @click="resetExperiment">🔁 重置</button>
      <button class="control-btn" @click="$emit('showPrinciple')">📘 实验原理</button>
    </div>
    <div v-if="showData" class="scene-data">
      <div v-for="(value, key) in displayData" :key="key" class="data-item">
        <span class="data-label">{{ key }}：</span>
        <span class="data-value">{{ value }}</span>
      </div>
    </div>
    <div v-if="resultsVisible" class="result-bar">
      <div class="result-item" v-for="(r, i) in resultTriples" :key="i">
        <span class="result-label">{{ r.label }}</span>
        <span class="result-value" :class="{ emphasis: r.emphasis }">{{ r.value }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import * as THREE from 'three'

const props = defineProps<{
  id: string
  values: Record<string, string | number>
}>()

const emit = defineEmits<{
  (e: 'showPrinciple'): void
}>()

const container = ref<HTMLDivElement | null>(null)
const isRunning = ref(false)
const showData = ref(false)
const displayData = ref<Record<string, string>>({})
const resultsVisible = ref(false)
const controlSpeed = ref(0.6)
const experimentSpeed = ref(0.6)
const radiusDiffPercent = ref(0)
const resultTriples = ref<Array<{ label: string; value: string; emphasis?: boolean }>>([])
// 模拟计时（加速倍数）
const simRate = 60 // 1秒现实时间=60秒实验时间
const simElapsed = ref(0) // 已经过的实验秒数
const simTotal = ref(0) // 实验总时长（秒）
let lastTs: number | null = null

let scene: any
let camera: any
let renderer: any
let animationId: number | null = null
let experimentObjects: any[] = []
let sunLight: any = null
let sunBulb: any = null
let controlTempDisplay: any = null
let experimentTempDisplay: any = null

// 初始化 Three.js 场景
function initScene() {
  if (!container.value) return

  const width = container.value.clientWidth
  const height = container.value.clientHeight

  // 创建场景
  scene = new THREE.Scene()
  // 深色背景以提升模型对比度
  scene.background = new THREE.Color(0x1e293b)

  // 创建相机
  camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000)
  camera.position.set(0, 5, 10)
  camera.lookAt(0, 0, 0)

  // 创建渲染器
  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(width, height)
  renderer.shadowMap.enabled = true
  container.value.appendChild(renderer.domElement)

  // 添加光源
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6)
  scene.add(ambientLight)

  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8)
  directionalLight.position.set(5, 10, 5)
  directionalLight.castShadow = true
  scene.add(directionalLight)

  // 创建实验场景
  createExperimentScene()

  // 开始渲染循环
  animate()
}

// 根据实验 ID 创建不同的实验场景
function createExperimentScene() {
  // 清除之前的对象
  experimentObjects.forEach((obj) => scene.remove(obj))
  experimentObjects = []

  if (props.id === 'heat_circulation') {
    createHeatCirculationScene()
  } else if (props.id === 'atmospheric_insulation') {
    createAtmosphericInsulationScene()
  } else if (props.id === 'soil_erosion') {
    createSoilErosionScene()
  }
}

// 热力环流场景
function createHeatCirculationScene() {
  // 创建透明容器
  const containerGeometry = new THREE.BoxGeometry(8, 6, 4)
  const containerMaterial = new THREE.MeshBasicMaterial({
    color: 0xffffff,
    transparent: true,
    opacity: 0.1,
    side: THREE.DoubleSide,
  })
  const container = new THREE.Mesh(containerGeometry, containerMaterial)
  scene.add(container)
  experimentObjects.push(container)

  // 热源（左侧红色区域）
  const heatSourceGeometry = new THREE.BoxGeometry(2, 2, 4)
  const heatSourceMaterial = new THREE.MeshStandardMaterial({
    color: 0xff4444,
    emissive: 0xff0000,
    emissiveIntensity: 0.5,
  })
  const heatSource = new THREE.Mesh(heatSourceGeometry, heatSourceMaterial)
  heatSource.position.set(-3, 0, 0)
  scene.add(heatSource)
  experimentObjects.push(heatSource)

  // 冷源（右侧蓝色区域）
  const coldSourceGeometry = new THREE.BoxGeometry(2, 2, 4)
  const coldSourceMaterial = new THREE.MeshStandardMaterial({
    color: 0x4444ff,
    emissive: 0x0000ff,
    emissiveIntensity: 0.3,
  })
  const coldSource = new THREE.Mesh(coldSourceGeometry, coldSourceMaterial)
  coldSource.position.set(3, 0, 0)
  scene.add(coldSource)
  experimentObjects.push(coldSource)

  // 创建流线粒子系统
  createFlowLines()
}

// 创建流线
function createFlowLines() {
  const lineCount = 20
  for (let i = 0; i < lineCount; i++) {
    const points: any[] = []
    const y = (Math.random() - 0.5) * 4
    const z = (Math.random() - 0.5) * 3

    // 创建循环路径
    points.push(new THREE.Vector3(-3, y, z))
    points.push(new THREE.Vector3(-3, y + 2, z))
    points.push(new THREE.Vector3(0, y + 3, z))
    points.push(new THREE.Vector3(3, y + 2, z))
    points.push(new THREE.Vector3(3, y, z))
    points.push(new THREE.Vector3(0, y - 1, z))
    points.push(new THREE.Vector3(-3, y, z))

    const geometry = new THREE.BufferGeometry().setFromPoints(points)
    const material = new THREE.LineBasicMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.6,
    })
    const line = new THREE.Line(geometry, material)
    scene.add(line)
    experimentObjects.push(line)
  }
}

// 大气保温场景
function createAtmosphericInsulationScene() {
  // 对照组（无大气）
  const controlGroup = new THREE.Group()
  const controlContainer = createContainer(0x88ccff, 0.3)
  controlContainer.position.set(-3, 0, 0)
  controlGroup.add(controlContainer)

  // 底部黑色砂石层（5cm模拟）
  const controlBase = new THREE.Mesh(
    new THREE.CylinderGeometry(1.45, 1.45, 0.2, 32),
    new THREE.MeshStandardMaterial({ color: 0x111111 })
  )
  controlBase.position.set(-3, -2, 0)
  controlGroup.add(controlBase)

  const controlThermometer = createThermometer()
  controlThermometer.position.set(-3, -2, 0)
  controlGroup.add(controlThermometer)
  scene.add(controlGroup)
  experimentObjects.push(controlGroup)

  // 实验组（有大气）
  const experimentGroup = new THREE.Group()
  const experimentContainer = createContainer(0x4488ff, 0.6)
  experimentContainer.position.set(3, 0, 0)
  experimentGroup.add(experimentContainer)

  // 底部黑色砂石层
  const experimentBase = new THREE.Mesh(
    new THREE.CylinderGeometry(1.45, 1.45, 0.2, 32),
    new THREE.MeshStandardMaterial({ color: 0x111111 })
  )
  experimentBase.position.set(3, -2, 0)
  experimentGroup.add(experimentBase)

  const experimentThermometer = createThermometer()
  experimentThermometer.position.set(3, -2, 0)
  experimentGroup.add(experimentThermometer)

  // 在两组容器内壁中部添加电子温度计显示（数字显示）
  // 内壁半径略小于容器半径，居中放置并面向相机
  controlTempDisplay = createDigitalDisplay()
  controlTempDisplay.position.set(-3 + 0, 0.2, 1.3)
  controlTempDisplay.rotation.y = -Math.PI / 2
  controlGroup.add(controlTempDisplay)

  experimentTempDisplay = createDigitalDisplay()
  experimentTempDisplay.position.set(3 + 0, 0.2, 1.3)
  experimentTempDisplay.rotation.y = -Math.PI / 2
  experimentGroup.add(experimentTempDisplay)

  experimentObjects.push(controlTempDisplay, experimentTempDisplay)

  // 有大气组：灰色微米级粒子，密度随大气浓度变化
  const concentration = String(props.values['大气浓度'] || '中')
  const particleCount = concentration === '高' ? 800 : concentration === '中' ? 400 : 200
  const gasGeometry = new THREE.BufferGeometry()
  const positions = new Float32Array(particleCount * 3)
  for (let i = 0; i < particleCount; i++) {
    // 限定在容器体积内
    positions[i * 3 + 0] = 3 + (Math.random() - 0.5) * 2.5
    positions[i * 3 + 1] = (Math.random() - 0.5) * 3.5
    positions[i * 3 + 2] = (Math.random() - 0.5) * 2.0
  }
  gasGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  const gasMaterial = new THREE.PointsMaterial({ color: 0x888888, size: 0.03, transparent: true, opacity: 0.6 })
  const gasParticles = new THREE.Points(gasGeometry, gasMaterial)
  experimentGroup.add(gasParticles)

  scene.add(experimentGroup)
  experimentObjects.push(experimentGroup)

  // 顶部中央黄色LED光源（模拟太阳）+ 可见灯泡
  sunLight = new THREE.SpotLight(0xffdd55, 1.2)
  sunLight.position.set(0, 8, 0)
  sunLight.angle = Math.PI / 4
  sunLight.penumbra = 0.5
  sunLight.decay = 1
  sunLight.distance = 30
  scene.add(sunLight)
  experimentObjects.push(sunLight)

  const bulbGeom = new THREE.SphereGeometry(0.25, 20, 20)
  const bulbMat = new THREE.MeshStandardMaterial({ color: 0xffdd55, emissive: 0xffcc33, emissiveIntensity: 0.8 })
  sunBulb = new THREE.Mesh(bulbGeom, bulbMat)
  sunBulb.position.set(0, 8, 0)
  scene.add(sunBulb)
  experimentObjects.push(sunBulb)
}

function createContainer(color: number, opacity: number): any {
  const geometry = new THREE.CylinderGeometry(1.5, 1.5, 4, 32)
  const material = new THREE.MeshStandardMaterial({
    color,
    transparent: true,
    opacity,
  })
  return new THREE.Mesh(geometry, material)
}

function createThermometer(): any {
  const group = new THREE.Group()
  const tubeGeometry = new THREE.CylinderGeometry(0.1, 0.1, 2, 16)
  const tubeMaterial = new THREE.MeshStandardMaterial({ color: 0x333333 })
  const tube = new THREE.Mesh(tubeGeometry, tubeMaterial)
  group.add(tube)

  const bulbGeometry = new THREE.SphereGeometry(0.2, 16, 16)
  const bulbMaterial = new THREE.MeshStandardMaterial({ color: 0xff0000 })
  const bulb = new THREE.Mesh(bulbGeometry, bulbMaterial)
  bulb.position.y = -1
  group.add(bulb)

  return group
}

// 创建数字显示屏（电子温度计显示）
function createDigitalDisplay(): any {
  const width = 256
  const height = 128
  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  const ctx = canvas.getContext('2d') as CanvasRenderingContext2D

  function draw(text: string) {
    // 背景
    ctx.fillStyle = '#0b1b14'
    ctx.fillRect(0, 0, width, height)
    // 边框
    ctx.strokeStyle = '#3aa675'
    ctx.lineWidth = 4
    ctx.strokeRect(4, 4, width - 8, height - 8)
    // 文本
    ctx.fillStyle = '#7CFC00'
    ctx.font = 'bold 56px Segoe UI, Arial'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(text, width / 2, height / 2)
  }

  draw('--.-℃')
  const texture = new THREE.CanvasTexture(canvas)
  texture.minFilter = THREE.LinearFilter
  texture.magFilter = THREE.LinearFilter
  const mat = new THREE.MeshBasicMaterial({ map: texture })
  const aspect = width / height
  const displayHeight = 0.5
  const displayWidth = displayHeight * aspect
  const geo = new THREE.PlaneGeometry(displayWidth, displayHeight)
  const mesh = new THREE.Mesh(geo, mat)
  mesh.userData.update = (text: string) => {
    draw(text)
    texture.needsUpdate = true
  }
  return mesh
}

// 水土流失场景
function createSoilErosionScene() {
  // 从变量读取实验组可视坡度（默认30°），对照组固定30°
  const slopeVar = String(props.values['地面坡度'] || '30°')
  const expAngle = parseFloat(slopeVar.replace('°', '')) || 30

  // 对照组
  const controlSlope = createSlope(0xcc4f2f, -5, 'control', 30)
  scene.add(controlSlope)
  experimentObjects.push(controlSlope)

  // 实验组
  const experimentSlope = createSlope(0xcc4f2f, 5, 'experiment', expAngle)
  scene.add(experimentSlope)
  experimentObjects.push(experimentSlope)

  // 创建雨滴粒子系统
  createRainParticles()
}

function createSlope(color: number, x: number, type: string, angleDeg: number): any {
  const group = new THREE.Group()

  // 土壤层
  const slopeGeometry = new THREE.BoxGeometry(3.5, 0.7, 6)
  const slopeMaterial = new THREE.MeshStandardMaterial({ color })
  const slope = new THREE.Mesh(slopeGeometry, slopeMaterial)
  // 设置与水平夹角为传入角度（度），使坡面朝向相机
  slope.rotation.x = THREE.MathUtils.degToRad(angleDeg)
  slope.position.set(x, -0.8, 0)
  group.add(slope)

  // 植被：对照组无草，实验组覆盖草地
  if (type === 'experiment') {
    const grassGeometry = new THREE.ConeGeometry(0.06, 0.28, 8)
    const grassMaterial = new THREE.MeshStandardMaterial({ color: 0x228b22 })
    const countX = 14
    const countZ = 18
    for (let ix = 0; ix < countX; ix++) {
      for (let iz = 0; iz < countZ; iz++) {
        const grass = new THREE.Mesh(grassGeometry, grassMaterial)
        const jitterX = (Math.random() - 0.5) * 0.1
        const jitterZ = (Math.random() - 0.5) * 0.1
        const localX = ((ix / (countX - 1)) - 0.5) * 3.0 + jitterX
        const localZ = ((iz / (countZ - 1)) - 0.5) * 5.0 + jitterZ
        // 放置在坡面局部坐标的顶面附近，让草跟随坡面旋转
        grass.position.set(localX, (0.7 / 2) + 0.02 + Math.random() * 0.02, localZ)
        slope.add(grass)
      }
    }
  }

  // 收集槽
  const collectorGeometry = new THREE.BoxGeometry(3.6, 0.2, 0.6)
  const collectorMaterial = new THREE.MeshStandardMaterial({ color: 0xcccccc })
  const collector = new THREE.Mesh(collectorGeometry, collectorMaterial)
  collector.position.set(x, -2, 0)
  group.add(collector)

  return group
}

function createRainParticles() {
  const particleCount = 100
  const geometry = new THREE.BufferGeometry()
  const positions = new Float32Array(particleCount * 3)

  for (let i = 0; i < particleCount * 3; i++) {
    positions[i] = (Math.random() - 0.5) * 20
  }

  geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  const material = new THREE.PointsMaterial({
    color: 0x4488ff,
    size: 0.1,
    transparent: true,
    opacity: 0.6,
  })
  const particles = new THREE.Points(geometry, material)
  scene.add(particles)
  experimentObjects.push(particles)
}

// 动画循环
function animate() {
  animationId = requestAnimationFrame(animate)

  if (isRunning.value) {
    // 根据变量值更新场景
    updateScene()
    // 更新计时
    const now = performance.now()
    if (lastTs == null) lastTs = now
    const dt = (now - lastTs) / 1000
    lastTs = now
    simElapsed.value = Math.min(simElapsed.value + dt * simRate, simTotal.value || simElapsed.value + dt * simRate)
  }

  renderer.render(scene, camera)
}

// 更新场景（根据变量值）
function updateScene() {
  if (props.id === 'heat_circulation') {
    updateHeatCirculation()
  } else if (props.id === 'atmospheric_insulation') {
    updateAtmosphericInsulation()
  } else if (props.id === 'soil_erosion') {
    updateSoilErosion()
  }
}

function updateHeatCirculation() {
  // 根据热源和冷源强度调整颜色和强度
  const heatTemp = parseFloat(String(props.values['热源强度'] || '60').replace('℃', ''))
  const coldTemp = parseFloat(String(props.values['冷源强度'] || '0').replace('℃', ''))
  const closed = String(props.values['空间密闭性'] || '密闭') === '密闭'

  experimentObjects.forEach((obj) => {
    if (obj instanceof THREE.Mesh && obj.material instanceof THREE.MeshStandardMaterial) {
      if (obj.material.emissive?.r > 0) {
        // 热源
        const intensity = (heatTemp - 30) / 70
        obj.material.emissiveIntensity = 0.3 + intensity * 0.5
      } else if (obj.material.emissive?.b > 0) {
        // 冷源
        const intensity = Math.abs(coldTemp + 20) / 40
        obj.material.emissiveIntensity = 0.1 + intensity * 0.3
      }
    }
  })

  // 更新显示数据
  displayData.value = {
    热源温度: `${heatTemp}℃`,
    冷源温度: `${coldTemp}℃`,
    环流状态: '运行中',
  }
  showData.value = true

  const baseDelta = 60 - 0
  const delta = Math.max(10, heatTemp - coldTemp)
  const closedFactor = closed ? 1.1 : 0.8
  experimentSpeed.value = controlSpeed.value * (delta / baseDelta) * closedFactor
  radiusDiffPercent.value = (experimentSpeed.value / controlSpeed.value - 1) * 100
  resultsVisible.value = true
  resultTriples.value = [
    { label: '对照环流速度', value: `${controlSpeed.value.toFixed(1)} m/s` },
    { label: '实验组', value: `${experimentSpeed.value.toFixed(1)} m/s`, emphasis: true },
    { label: '环流范围差异', value: `${radiusDiffPercent.value.toFixed(0)}%`, emphasis: true },
  ]
}

function updateAtmosphericInsulation() {
  const concentration = String(props.values['大气浓度'] || '中')
  const light = String(props.values['光照强度'] || '中')
  const isDay = String(props.values['昼夜状态'] || '白天') === '白天'

  // 计算温度（模拟）
  const baseTemp = isDay ? 25 : 15
  const concentrationFactor = concentration === '高' ? 1.2 : concentration === '中' ? 1.0 : 0.8
  const lightFactor = light === '强' ? 1.3 : light === '中' ? 1.0 : 0.7

  const controlTemp = baseTemp * lightFactor
  const experimentTemp = baseTemp * lightFactor * concentrationFactor

  displayData.value = {
    对照组温度: `${controlTemp.toFixed(1)}℃`,
    实验组温度: `${experimentTemp.toFixed(1)}℃`,
    温差: `${(experimentTemp - controlTemp).toFixed(1)}℃`,
  }
  showData.value = true

  // 更新电子温度计数字显示
  if (controlTempDisplay?.userData?.update) controlTempDisplay.userData.update(`${controlTemp.toFixed(1)}℃`)
  if (experimentTempDisplay?.userData?.update) experimentTempDisplay.userData.update(`${experimentTemp.toFixed(1)}℃`)

  // 更新光照强度：白天亮度与光照强度关联，夜间关闭；同步更新可见灯泡的发光强度
  const intensity = isDay ? (light === '强' ? 2.0 : light === '中' ? 1.2 : 0.6) : 0.0
  if (sunLight) {
    sunLight.intensity = intensity
  }
  if (sunBulb && sunBulb.material) {
    sunBulb.material.emissiveIntensity = Math.max(0.0, intensity * 0.6)
    sunBulb.visible = intensity > 0
  }

  // 底部结果区（夜间显著）：显示1小时降温幅度与提升率
  if (!isDay) {
    const controlDrop = Math.max(5, 12 * lightFactor) // 无大气降温更快
    const experimentDrop = controlDrop / concentrationFactor // 浓度越高，降温幅度越小
    const improve = ((controlDrop - experimentDrop) / controlDrop) * 100
    resultsVisible.value = true
    resultTriples.value = [
      { label: '对照组1小时降温幅度', value: `${controlDrop.toFixed(1)}℃` },
      { label: '实验组1小时降温幅度', value: `${experimentDrop.toFixed(1)}℃`, emphasis: true },
      { label: '保温效果提升率', value: `${improve.toFixed(1)}%`, emphasis: true },
    ]
  } else {
    // 白天不突出降温幅度
    resultsVisible.value = false
  }
}

function updateSoilErosion() {
  const vegetation = String(props.values['植被覆盖'] || '稀疏')
  const slope = String(props.values['地面坡度'] || '30°')
  const rain = String(props.values['降水强度'] || '中雨')

  // 计算流失量（模拟），以 ml 为单位，基于变量因子与时间推进
  // 对照组固定：30° + 茂密 + 中雨 + 壤质
  const baseRate = 1 // ml/分钟 基准
  const controlFactors = { vegetation: 0.4, slope: 1 + 30 / 60, rain: 1.0, soil: 0.8 }
  const controlPerMin = baseRate * controlFactors.vegetation * controlFactors.slope * controlFactors.rain * controlFactors.soil

  // 实验组因子
  let vegFactor = vegetation === '茂密' ? 0.4 : vegetation === '稀疏' ? 0.7 : 1.0
  const slopeAngle = parseFloat(slope.replace('°', '')) || 0
  let slopeFactor = 1 + slopeAngle / 60
  let rainFactor = rain === '暴雨' ? 2.0 : rain === '大雨' ? 1.5 : rain === '小雨' ? 0.6 : 1.0
  // 土壤性质来自 props.values，若存在
  const soil = String(props.values['土壤性质'] || '壤质')
  let soilFactor = soil === '黏质' ? 0.6 : soil === '壤质' ? 0.8 : 1.1

  const expPerMin = baseRate * vegFactor * slopeFactor * rainFactor * soilFactor

  // 按模拟时间折算累计（限制到总时长5分钟）
  const minutes = Math.min(simTotal.value ? simTotal.value / 60 : 5, (simElapsed.value || 0) / 60)
  const controlMl = controlPerMin * minutes
  const expMl = expPerMin * minutes
  const reducePercent = ((controlMl - expMl) / (controlMl || 1)) * 100

  displayData.value = {
    植被覆盖: vegetation,
    坡度: slope,
    降水强度: rain,
    倒计时: `${Math.max(0, Math.ceil((simTotal.value - simElapsed.value) / 60)).toString().padStart(1, '0')} 分钟`,
  }
  showData.value = true

  resultsVisible.value = true
  resultTriples.value = [
    { label: '对照组水土流失量', value: `${controlMl.toFixed(1)} ml` },
    { label: '实验组水土流失量', value: `${expMl.toFixed(1)} ml`, emphasis: true },
    { label: '减少百分比', value: `${reducePercent.toFixed(1)}%`, emphasis: true },
  ]
}

function toggleExperiment() {
  isRunning.value = !isRunning.value
  if (isRunning.value) {
    resultsVisible.value = true
  }
}

function resetExperiment() {
  isRunning.value = false
  createExperimentScene()
  displayData.value = {}
  showData.value = false
  resultsVisible.value = false
  controlSpeed.value = 0.6
  experimentSpeed.value = 0.6
  radiusDiffPercent.value = 0
  simElapsed.value = 0
  simTotal.value = 0
  lastTs = null
}

// 暴露给父组件的控制方法
function start() {
  if (!isRunning.value) {
    isRunning.value = true
    resultsVisible.value = true
    // 初始化时长
    if (props.id === 'atmospheric_insulation') simTotal.value = 3600
    else if (props.id === 'soil_erosion') simTotal.value = 300
    else simTotal.value = 0
    simElapsed.value = 0
    lastTs = null
  }
}

function pause() {
  isRunning.value = false
}

function reset() {
  resetExperiment()
}

defineExpose({ start, pause, reset })

function handleResize() {
  if (!container.value || !renderer || !camera) return
  const width = container.value.clientWidth
  const height = container.value.clientHeight
  renderer.setSize(width, height)
  camera.aspect = width / height
  camera.updateProjectionMatrix()
}

// 监听变量变化
watch(
  () => props.values,
  () => {
    if (isRunning.value) {
      createExperimentScene()
    }
  },
  { deep: true }
)

// 监听实验 ID 变化
watch(
  () => props.id,
  () => {
    createExperimentScene()
    resetExperiment()
  }
)

onMounted(() => {
  initScene()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  window.removeEventListener('resize', handleResize)
  if (renderer) {
    renderer.dispose()
  }
  experimentObjects.forEach((obj) => {
    if (obj instanceof THREE.Mesh) {
      obj.geometry.dispose()
      if (Array.isArray(obj.material)) {
        obj.material.forEach((mat: any) => mat.dispose())
      } else {
        obj.material.dispose()
      }
    }
  })
})
</script>

<style scoped>
.experiment-scene {
  position: relative;
  width: 100%;
  height: 600px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  overflow: hidden;
  /* 深色背景 + 轻微晕影，增强对比 */
  background: radial-gradient(ellipse at center, rgba(30,41,59,0.3) 0%, rgba(30,41,59,0.75) 60%, rgba(30,41,59,0.9) 100%);
}

.scene-container {
  width: 100%;
  height: 100%;
}

.scene-controls {
  position: absolute;
  bottom: 72px; /* 留出底部结果条空间 */
  left: var(--spacing-base);
  display: flex;
  gap: var(--spacing-small);
  z-index: 9; /* 低于数据面板，避免遮挡 */
}

.control-btn {
  padding: var(--spacing-small) var(--spacing-base);
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  color: var(--color-text-primary);
  font-size: 14px;
  cursor: pointer;
  transition: var(--transition-base);
  backdrop-filter: blur(10px);
  box-shadow: var(--shadow-base);
}

.control-btn:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
  transform: translateY(-2px);
}

.control-btn.active {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.scene-data {
  position: absolute;
  top: var(--spacing-base);
  right: var(--spacing-base);
  background: rgba(255, 255, 255, 0.95);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  backdrop-filter: blur(10px);
  box-shadow: var(--shadow-base);
  z-index: 10;
  min-width: 180px;
}

.data-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--spacing-small);
  font-size: 13px;
}

.data-item:last-child {
  margin-bottom: 0;
}

.data-label {
  color: var(--color-text-secondary);
}

.data-value {
  color: var(--color-primary);
  font-weight: 600;
}

.result-bar {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
  padding: 10px 16px;
  background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.9) 30%);
  border-top: 1px solid var(--color-border);
  backdrop-filter: blur(8px);
}

.result-item {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  background: rgba(255,255,255,0.8);
  padding: 8px 12px;
  border-radius: var(--radius-small);
  border: 1px solid var(--color-border-light);
}

.result-label {
  color: var(--color-text-secondary);
  font-size: 12px;
}

.result-value {
  color: var(--color-text-primary);
  font-weight: 600;
}

.result-value.emphasis {
  color: var(--color-primary);
}

@media (max-width: 768px) {
  .experiment-scene {
    height: 400px;
  }

  .scene-controls {
    flex-wrap: wrap;
    justify-content: center;
  }

  .control-btn {
    font-size: 12px;
    padding: 6px 12px;
  }

  .scene-data {
    position: static;
    margin: var(--spacing-base);
    width: calc(100% - 32px);
  }
}
</style>
