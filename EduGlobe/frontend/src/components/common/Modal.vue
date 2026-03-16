<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="modelValue"
        class="modal-overlay"
        :class="{ 'modal-blur': blur }"
        @click="handleOverlayClick"
      >
        <Transition name="modal-scale">
          <div
            v-if="modelValue"
            class="modal-container"
            :class="[`modal-${size}`, { 'modal-fullscreen': fullscreen }]"
            @click.stop
          >
            <!-- 关闭按钮 -->
            <button
              v-if="showClose"
              class="modal-close"
              @click="handleClose"
            >
              <span class="material-icons">close</span>
            </button>

            <!-- 头部 -->
            <div v-if="$slots.header || title" class="modal-header">
              <slot name="header">
                <div class="modal-title-wrapper">
                  <span v-if="icon" class="material-icons modal-icon">{{ icon }}</span>
                  <h3 class="modal-title">{{ title }}</h3>
                </div>
              </slot>
            </div>

            <!-- 内容 -->
            <div class="modal-body" :class="{ 'modal-body-scrollable': scrollable }">
              <slot></slot>
            </div>

            <!-- 底部 -->
            <div v-if="$slots.footer" class="modal-footer">
              <slot name="footer"></slot>
            </div>
          </div>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
interface Props {
  modelValue: boolean
  title?: string
  icon?: string
  size?: 'small' | 'medium' | 'large'
  fullscreen?: boolean
  showClose?: boolean
  closeOnClickOutside?: boolean
  scrollable?: boolean
  blur?: boolean
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'close'): void
}

const props = withDefaults(defineProps<Props>(), {
  size: 'medium',
  fullscreen: false,
  showClose: true,
  closeOnClickOutside: true,
  scrollable: true,
  blur: true
})

const emit = defineEmits<Emits>()

const handleClose = () => {
  emit('update:modelValue', false)
  emit('close')
}

const handleOverlayClick = () => {
  if (props.closeOnClickOutside) {
    handleClose()
  }
}
</script>

<style scoped lang="scss">
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--color-bg-mask);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: var(--spacing-base);

  &.modal-blur {
    backdrop-filter: blur(4px);
  }
}

.modal-container {
  background: white;
  border-radius: var(--radius-large);
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.2);
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  position: relative;

  &.modal-small {
    width: 400px;
  }

  &.modal-medium {
    width: 600px;
  }

  &.modal-large {
    width: 900px;
  }

  &.modal-fullscreen {
    width: 100vw;
    height: 100vh;
    max-height: 100vh;
    border-radius: 0;
  }

  @media (max-width: 768px) {
    width: 100% !important;
    max-height: 80vh;
  }
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border: none;
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-circle);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-base);
  z-index: 1;

  .material-icons {
    font-size: 20px;
    color: var(--color-text-secondary);
  }

  &:hover {
    background: var(--color-error);

    .material-icons {
      color: white;
    }
  }
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid var(--color-border-light);
}

.modal-title-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-icon {
  font-size: 28px;
  color: var(--color-primary);
}

.modal-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.modal-body {
  padding: 24px;
  flex: 1;
  overflow: hidden;

  &.modal-body-scrollable {
    overflow-y: auto;
  }
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--color-border-light);
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
}

// 动画
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-scale-enter-active,
.modal-scale-leave-active {
  transition: all 0.3s ease;
}

.modal-scale-enter-from {
  opacity: 0;
  transform: scale(0.9) translateY(-20px);
}

.modal-scale-leave-to {
  opacity: 0;
  transform: scale(0.9) translateY(20px);
}
</style>
