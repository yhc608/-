<template>
  <div class="fpv">
    <canvas ref="canvas" class="fpv-canvas"></canvas>
    <div class="hud">
      <div class="hint">WASD/拖动控制视角，点击高亮点可触发知识弹窗</div>
      <div class="mobile-joystick" @touchstart.prevent @touchmove.prevent="onTouch" @touchend="resetTouch">
        <div class="stick" :style="{ transform: `translate(${stick.x}px, ${stick.y}px)` }"></div>
      </div>
      <button class="hud-btn" @click="emit('interact', 'record')">记录位置</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, reactive } from 'vue';
import * as THREE from 'three';

const emit = defineEmits<{ (e: 'interact', type: string): void }>();

const canvas = ref<HTMLCanvasElement | null>(null);
let renderer: THREE.WebGLRenderer | null = null;
let scene: THREE.Scene | null = null;
let camera: THREE.PerspectiveCamera | null = null;
let clock: THREE.Clock | null = null;
let raf = 0;
const pointer = new THREE.Vector2();
const raycaster = new THREE.Raycaster();
const hotspots: THREE.Mesh[] = [];
const velocity = reactive({ forward: 0, strafe: 0 });
const stick = reactive({ x: 0, y: 0 });

const keyState: Record<string, boolean> = {};

function initScene() {
  if (!canvas.value) return;
  const width = canvas.value.clientWidth || canvas.value.parentElement?.clientWidth || 800;
  const height = canvas.value.clientHeight || canvas.value.parentElement?.clientHeight || 450;

  renderer = new THREE.WebGLRenderer({ canvas: canvas.value, antialias: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(width, height);

  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0f172a);

  camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 100);
  camera.position.set(0, 1.6, 4);

  clock = new THREE.Clock();

  const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 1);
  hemi.position.set(0, 20, 0);
  scene.add(hemi);

  const dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
  dirLight.position.set(5, 10, 7.5);
  scene.add(dirLight);

  const floorGeo = new THREE.PlaneGeometry(40, 40, 20, 20);
  const floorMat = new THREE.MeshStandardMaterial({ color: 0x1d4ed8, wireframe: true, transparent: true, opacity: 0.18 });
  const floor = new THREE.Mesh(floorGeo, floorMat);
  floor.rotation.x = -Math.PI / 2;
  scene.add(floor);

  createHotspot(new THREE.Vector3(2, 1, -2), 'observe');
  createHotspot(new THREE.Vector3(-3, 1.2, -5), 'measure');
  createHotspot(new THREE.Vector3(1, 0.8, -8), 'explain');

  animate();
}

function createHotspot(position: THREE.Vector3, type: string) {
  if (!scene) return;
  const geo = new THREE.SphereGeometry(0.25, 32, 32);
  const mat = new THREE.MeshStandardMaterial({ color: 0xfacc15, emissive: 0xf59e0b, emissiveIntensity: 0.6 });
  const mesh = new THREE.Mesh(geo, mat) as THREE.Mesh & { hotspotType?: string };
  mesh.position.copy(position);
  mesh.hotspotType = type;
  scene.add(mesh);
  hotspots.push(mesh);
}

function animate() {
  if (!renderer || !scene || !camera || !clock) return;
  raf = requestAnimationFrame(animate);
  const delta = clock.getDelta();
  updateVelocity(delta);
  renderer.render(scene, camera);
}

function updateVelocity(delta: number) {
  if (!camera) return;
  const speed = 4;
  const moveForward = keyState['KeyW'] || keyState['ArrowUp'] || velocity.forward > 0;
  const moveBackward = keyState['KeyS'] || keyState['ArrowDown'] || velocity.forward < 0;
  const moveLeft = keyState['KeyA'] || keyState['ArrowLeft'] || velocity.strafe < 0;
  const moveRight = keyState['KeyD'] || keyState['ArrowRight'] || velocity.strafe > 0;

  const direction = new THREE.Vector3();
  if (moveForward) direction.z -= 1;
  if (moveBackward) direction.z += 1;
  if (moveLeft) direction.x -= 1;
  if (moveRight) direction.x += 1;

  direction.normalize().applyAxisAngle(new THREE.Vector3(0, 1, 0), camera.rotation.y);
  camera.position.addScaledVector(direction, speed * delta);
}

function onKeyDown(e: KeyboardEvent) {
  keyState[e.code] = true;
}

function onKeyUp(e: KeyboardEvent) {
  keyState[e.code] = false;
}

function onMouseMove(e: MouseEvent) {
  if (!camera) return;
  if (document.pointerLockElement === canvas.value) {
    const movementX = e.movementX || 0;
    const movementY = e.movementY || 0;
    camera.rotation.y -= movementX * 0.002;
    camera.rotation.x -= movementY * 0.002;
    camera.rotation.x = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, camera.rotation.x));
  }
}

function onClick(event: MouseEvent) {
  if (!camera || !renderer || !scene) return;
  if (document.pointerLockElement !== canvas.value) {
    canvas.value?.requestPointerLock();
  }

  const rect = renderer.domElement.getBoundingClientRect();
  pointer.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
  pointer.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(hotspots, false);
  if (intersects.length > 0) {
    const hs = intersects[0].object as THREE.Mesh & { hotspotType?: string };
    emit('interact', hs.hotspotType || 'observe');
  } else {
    emit('interact', 'observe');
  }
}

function onResize() {
  if (!renderer || !camera || !canvas.value) return;
  const width = canvas.value.parentElement?.clientWidth || window.innerWidth;
  const height = 480;
  renderer.setSize(width, height);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
}

function onTouch(event: TouchEvent) {
  const touch = event.touches[0];
  const bounds = (event.currentTarget as HTMLElement).getBoundingClientRect();
  const x = touch.clientX - bounds.left - bounds.width / 2;
  const y = touch.clientY - bounds.top - bounds.height / 2;
  stick.x = Math.max(-40, Math.min(40, x));
  stick.y = Math.max(-40, Math.min(40, y));
  velocity.forward = stick.y < -10 ? 1 : stick.y > 10 ? -1 : 0;
  velocity.strafe = stick.x > 10 ? 1 : stick.x < -10 ? -1 : 0;
}

function resetTouch() {
  stick.x = 0;
  stick.y = 0;
  velocity.forward = 0;
  velocity.strafe = 0;
}

onMounted(() => {
  initScene();
  window.addEventListener('resize', onResize);
  window.addEventListener('keydown', onKeyDown);
  window.addEventListener('keyup', onKeyUp);
  window.addEventListener('mousemove', onMouseMove);
  canvas.value?.addEventListener('click', onClick);
});

onBeforeUnmount(() => {
  cancelAnimationFrame(raf);
  window.removeEventListener('resize', onResize);
  window.removeEventListener('keydown', onKeyDown);
  window.removeEventListener('keyup', onKeyUp);
  window.removeEventListener('mousemove', onMouseMove);
  canvas.value?.removeEventListener('click', onClick);
  if (renderer) {
    renderer.dispose();
    renderer.forceContextLoss();
  }
  hotspots.splice(0, hotspots.length);
});
</script>

<style scoped>
.fpv {
  position: relative;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  overflow: hidden;
}
.fpv-canvas {
  width: 100%;
  height: 480px;
  display: block;
}
.hud {
  position: absolute;
  left: 16px;
  right: 16px;
  bottom: 16px;
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  pointer-events: none;
}
.hint {
  color: rgba(255, 255, 255, 0.85);
  background: rgba(15, 23, 42, 0.6);
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  pointer-events: auto;
}
.hud-btn {
  pointer-events: auto;
  border: none;
  background: rgba(125, 211, 252, 0.75);
  color: #0f172a;
  padding: 6px 18px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 600;
}
.mobile-joystick {
  pointer-events: auto;
  width: 86px;
  height: 86px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.3);
  position: relative;
  display: none;
}
.mobile-joystick .stick {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.6);
  transform: translate(-50%, -50%);
}
@media (max-width: 768px) {
  .mobile-joystick {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .fpv-canvas {
    height: 360px;
  }
}
</style>


