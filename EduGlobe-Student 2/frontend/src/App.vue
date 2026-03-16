<template>
  <div class="app-container">
    <!-- 用户选择页面 -->
    <UserSelection 
      v-if="!hasSelectedEducationLevel" 
      @selection-confirmed="handleSelectionConfirmed"
    />

    <!-- 主应用内容 -->
    <div v-else class="main-app">
      <!-- 离线状态提示 -->
      <Transition name="slide-down">
        <div v-if="isOffline" class="offline-tip">
          <span class="material-icons">wifi_off</span>
          <span>当前处于离线模式，部分功能可能受限</span>
          <button class="btn-icon-small" @click="checkOnline">
            <span class="material-icons">refresh</span>
          </button>
        </div>
      </Transition>

      <!-- 主内容区 -->
      <div class="main-content">
        <router-view v-slot="{ Component }">
          <Transition name="fade" mode="out-in">
            <component :is="Component" />
          </Transition>
        </router-view>
      </div>

      <!-- 底部导航 -->
      <Transition name="slide-up">
        <TabBar v-if="showTabBar" />
      </Transition>
    </div>

    <!-- 通知组件 -->
    <Notification />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import TabBar from './components/TabBar.vue'
import UserSelection from './components/UserSelection.vue'
import Notification from './components/common/Notification.vue'
import './styles/global.scss'
import { useNotification } from './composables/useNotification'

const route = useRoute()
const showTabBar = computed(() => route.meta.tab)
const isOffline = ref(false)
const { info } = useNotification()

// 用户教育阶段选择状态
const hasSelectedEducationLevel = ref(false)
const userEducationLevel = ref<string>('')

// 检查是否已选择教育阶段
function checkEducationLevelSelection() {
  const savedLevel = localStorage.getItem('userEducationLevel')
  if (savedLevel) {
    hasSelectedEducationLevel.value = true
    userEducationLevel.value = savedLevel
  }
}

// 处理选择确认
function handleSelectionConfirmed(level: string) {
  userEducationLevel.value = level
  hasSelectedEducationLevel.value = true
  info('欢迎', `已设置为${getLevelName(level)}阶段`)
}

// 获取教育阶段名称
function getLevelName(level: string) {
  const map: Record<string, string> = {
    'middle-school': '初中',
    'high-school': '高中',
    'undergraduate': '本科'
  }
  return map[level] || level
}

// 检查在线状态
function checkOnlineStatus() {
  isOffline.value = !navigator.onLine
}

function checkOnline() {
  checkOnlineStatus()
  if (!isOffline.value) {
    info('已恢复连接', '网络连接已恢复')
  }
}

// 生命周期
onMounted(() => {
  checkEducationLevelSelection()
  checkOnlineStatus()
  
  window.addEventListener('online', checkOnlineStatus)
  window.addEventListener('offline', checkOnlineStatus)
})

onUnmounted(() => {
  window.removeEventListener('online', checkOnlineStatus)
  window.removeEventListener('offline', checkOnlineStatus)
})
</script>

<style scoped lang="scss">
.app-container {
  min-height: 100vh;
  background: var(--color-bg-primary);
}

.main-app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.offline-tip {
  position: fixed;
  top: var(--spacing-base);
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(135deg, rgba(255, 77, 79, 0.95) 0%, rgba(217, 50, 50, 0.95) 100%);
  color: white;
  padding: 12px 20px;
  border-radius: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  z-index: 2999;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 16px rgba(255, 77, 79, 0.3);
  animation: slideDown 0.3s ease-out;

  .material-icons {
    font-size: 20px;
  }

  span:not(.material-icons) {
    font-size: 14px;
    font-weight: 500;
  }

  .btn-icon-small {
    width: 28px;
    height: 28px;
    border: none;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: var(--transition-base);

    &:hover {
      background: rgba(255, 255, 255, 0.3);
    }

    .material-icons {
      font-size: 18px;
    }
  }
}

.main-content {
  flex: 1;
  padding-bottom: 60px;
}

// 动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
}

.slide-down-enter-from,
.slide-down-leave-to {
  transform: translate(-50%, -100%);
  opacity: 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.3s ease;
}

.slide-up-enter-from {
  transform: translateY(100%);
  opacity: 0;
}

.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}

@keyframes slideDown {
  from {
    transform: translate(-50%, -100%);
    opacity: 0;
  }
  to {
    transform: translate(-50%, 0);
    opacity: 1;
  }
}
</style>