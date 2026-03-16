<template>
  <nav class="tab-bar">
    <router-link 
      v-for="tab in tabs" 
      :key="tab.path"
      :to="tab.path"
      class="tab-item"
      :class="{ active: isActive(tab.path) }"
    >
      <div class="tab-icon-wrapper">
        <span class="material-icons tab-icon">{{ tab.icon }}</span>
        <Transition name="scale">
          <span v-if="tab.badge" class="tab-badge">{{ tab.badge }}</span>
        </Transition>
      </div>
      <span class="tab-label">{{ tab.label }}</span>
      <div class="tab-indicator"></div>
    </router-link>
  </nav>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const currentPath = computed(() => '/' + route.path.split('/')[1])

interface Tab {
  path: string
  label: string
  icon: string
  badge?: number
}

const tabs = ref<Tab[]>([
  { path: '/', label: '首页', icon: 'home' },
  { path: '/prep', label: '预习', icon: 'menu_book', badge: 2 },
  { path: '/classroom', label: '课堂', icon: 'groups' },
  { path: '/review', label: '复习', icon: 'psychology', badge: 5 },
  { path: '/mine', label: '我的', icon: 'person' }
])

const isActive = (path: string) => {
  if (path === '/') {
    return currentPath.value === '/'
  }
  return currentPath.value === path
}
</script>

<style scoped lang="scss">
.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60px;
  background: white;
  display: flex;
  justify-content: space-around;
  align-items: stretch;
  box-shadow: 0 -2px 16px rgba(0, 0, 0, 0.08);
  z-index: 1000;
  padding-bottom: env(safe-area-inset-bottom);

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 1px;
    background: linear-gradient(90deg, transparent, var(--color-border), transparent);
  }
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  padding: 8px 0;
  min-width: 64px;
  cursor: pointer;
  user-select: none;

  &:active {
    transform: scale(0.95);
  }

  &.active {
    color: var(--color-primary);

    .tab-icon-wrapper {
      .tab-icon {
        transform: scale(1.1);
        color: var(--color-primary);
      }
    }

    .tab-label {
      font-weight: 600;
    }

    .tab-indicator {
      transform: scaleX(1);
      opacity: 1;
    }
  }

  &:hover:not(.active) {
    color: var(--color-primary-light);

    .tab-icon-wrapper .tab-icon {
      transform: translateY(-2px);
    }
  }
}

.tab-icon-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 4px;
}

.tab-icon {
  font-size: 24px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.tab-badge {
  position: absolute;
  top: -4px;
  right: -8px;
  min-width: 18px;
  height: 18px;
  padding: 0 4px;
  background: linear-gradient(135deg, var(--color-error) 0%, #d93232 100%);
  color: white;
  border-radius: 9px;
  font-size: 11px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 4px rgba(255, 77, 79, 0.3);
  border: 2px solid white;
}

.tab-label {
  font-size: 12px;
  line-height: 1;
  transition: all 0.3s ease;
}

.tab-indicator {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%) scaleX(0);
  width: 32px;
  height: 3px;
  background: linear-gradient(90deg, var(--color-primary) 0%, var(--color-primary-light) 100%);
  border-radius: 0 0 3px 3px;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

// 动画
.scale-enter-active,
.scale-leave-active {
  transition: all 0.2s ease;
}

.scale-enter-from,
.scale-leave-to {
  transform: scale(0);
  opacity: 0;
}

// 大字体模式适配
:global(.large-text) {
  .tab-label {
    font-size: 14px;
  }
  
  .tab-icon {
    font-size: 26px;
  }
}

:global(.xlarge-text) {
  .tab-label {
    font-size: 16px;
  }
  
  .tab-icon {
    font-size: 28px;
  }
}

// 响应式适配
@media (max-width: 375px) {
  .tab-label {
    font-size: 11px;
  }
  
  .tab-icon {
    font-size: 22px;
  }
}
</style>
