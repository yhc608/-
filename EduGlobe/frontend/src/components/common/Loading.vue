<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="visible" class="edu-loading-overlay" :class="{ 'loading-fullscreen': fullscreen }">
        <div class="loading-content">
          <div class="loading-spinner" :class="`spinner-${size}`">
            <div class="spinner-circle"></div>
            <div class="spinner-circle"></div>
            <div class="spinner-circle"></div>
          </div>
          <p v-if="text" class="loading-text">{{ text }}</p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
interface Props {
  visible?: boolean
  text?: string
  fullscreen?: boolean
  size?: 'small' | 'medium' | 'large'
}

withDefaults(defineProps<Props>(), {
  visible: false,
  fullscreen: true,
  size: 'medium'
})
</script>

<style scoped lang="scss">
.edu-loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 3000;

  &.loading-fullscreen {
    background: var(--color-bg-mask);
    backdrop-filter: blur(4px);
  }
}

.loading-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-base);
}

.loading-spinner {
  display: flex;
  gap: 8px;

  &.spinner-small {
    .spinner-circle {
      width: 8px;
      height: 8px;
    }
  }

  &.spinner-medium {
    .spinner-circle {
      width: 12px;
      height: 12px;
    }
  }

  &.spinner-large {
    .spinner-circle {
      width: 16px;
      height: 16px;
    }
  }
}

.spinner-circle {
  background: var(--color-primary);
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;

  &:nth-child(1) {
    animation-delay: -0.32s;
  }

  &:nth-child(2) {
    animation-delay: -0.16s;
  }
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

.loading-text {
  margin: 0;
  color: var(--color-text-primary);
  font-size: 16px;
  font-weight: 500;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
