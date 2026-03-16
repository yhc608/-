<template>
  <button
    class="edu-button"
    :class="[
      `btn-${type}`,
      `btn-${size}`,
      {
        'btn-loading': loading,
        'btn-disabled': disabled || loading,
        'btn-block': block,
        'btn-rounded': rounded,
        'btn-icon-only': iconOnly
      }
    ]"
    :disabled="disabled || loading"
    @click="handleClick"
  >
    <span v-if="loading" class="btn-loading-icon">
      <div class="spinner"></div>
    </span>
    <span v-else-if="icon && !iconOnly" class="material-icons btn-icon">{{ icon }}</span>
    <span v-else-if="icon && iconOnly" class="material-icons">{{ icon }}</span>
    <span v-if="!iconOnly" class="btn-text">
      <slot></slot>
    </span>
    <span v-if="suffixIcon" class="material-icons btn-suffix-icon">{{ suffixIcon }}</span>
  </button>
</template>

<script setup lang="ts">
interface Props {
  type?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'text' | 'ghost'
  size?: 'small' | 'medium' | 'large'
  icon?: string
  suffixIcon?: string
  iconOnly?: boolean
  loading?: boolean
  disabled?: boolean
  block?: boolean
  rounded?: boolean
}

interface Emits {
  (e: 'click', event: MouseEvent): void
}

const props = withDefaults(defineProps<Props>(), {
  type: 'primary',
  size: 'medium',
  loading: false,
  disabled: false,
  block: false,
  rounded: false,
  iconOnly: false
})

const emit = defineEmits<Emits>()

const handleClick = (event: MouseEvent) => {
  if (!props.loading && !props.disabled) {
    emit('click', event)
  }
}
</script>

<style scoped lang="scss">
.edu-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border: none;
  cursor: pointer;
  font-weight: 500;
  border-radius: var(--radius-base);
  transition: var(--transition-base);
  position: relative;
  font-family: inherit;
  white-space: nowrap;
  user-select: none;

  &:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(123, 107, 82, 0.2);
  }

  &:active:not(.btn-disabled) {
    transform: scale(0.98);
  }

  // 尺寸
  &.btn-small {
    padding: 6px 12px;
    font-size: 14px;
    height: 32px;

    .material-icons {
      font-size: 18px;
    }

    &.btn-icon-only {
      width: 32px;
      padding: 6px;
    }
  }

  &.btn-medium {
    padding: 10px 20px;
    font-size: 16px;
    height: 40px;

    .material-icons {
      font-size: 20px;
    }

    &.btn-icon-only {
      width: 40px;
      padding: 10px;
    }
  }

  &.btn-large {
    padding: 14px 28px;
    font-size: 18px;
    height: 48px;

    .material-icons {
      font-size: 24px;
    }

    &.btn-icon-only {
      width: 48px;
      padding: 14px;
    }
  }

  // 类型
  &.btn-primary {
    background: var(--color-primary);
    color: white;

    &:hover:not(.btn-disabled) {
      background: var(--color-primary-dark);
      box-shadow: 0 4px 12px rgba(123, 107, 82, 0.3);
    }
  }

  &.btn-secondary {
    background: var(--color-text-secondary);
    color: white;

    &:hover:not(.btn-disabled) {
      background: var(--color-text-primary);
    }
  }

  &.btn-success {
    background: var(--color-success);
    color: white;

    &:hover:not(.btn-disabled) {
      background: #3ba617;
      box-shadow: 0 4px 12px rgba(82, 196, 26, 0.3);
    }
  }

  &.btn-warning {
    background: var(--color-warning);
    color: white;

    &:hover:not(.btn-disabled) {
      background: #e09200;
    }
  }

  &.btn-danger {
    background: var(--color-error);
    color: white;

    &:hover:not(.btn-disabled) {
      background: #d93232;
      box-shadow: 0 4px 12px rgba(255, 77, 79, 0.3);
    }
  }

  &.btn-text {
    background: transparent;
    color: var(--color-primary);

    &:hover:not(.btn-disabled) {
      background: var(--color-bg-tertiary);
    }
  }

  &.btn-ghost {
    background: transparent;
    border: 1px solid var(--color-primary);
    color: var(--color-primary);

    &:hover:not(.btn-disabled) {
      background: var(--color-primary);
      color: white;
    }
  }

  // 状态
  &.btn-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &.btn-loading {
    cursor: wait;
    pointer-events: none;
  }

  &.btn-block {
    width: 100%;
    display: flex;
  }

  &.btn-rounded {
    border-radius: 24px;
  }
}

.btn-loading-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.btn-icon,
.btn-suffix-icon {
  display: inline-flex;
  align-items: center;
}

.btn-text {
  display: inline-flex;
  align-items: center;
}
</style>
