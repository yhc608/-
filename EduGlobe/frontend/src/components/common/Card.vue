<template>
  <div 
    class="edu-card" 
    :class="[
      `card-${variant}`,
      `card-${size}`,
      { 
        'card-hoverable': hoverable,
        'card-shadow': shadow,
        'card-bordered': bordered,
        'card-loading': loading
      }
    ]"
  >
    <!-- 加载状态 -->
    <div v-if="loading" class="card-loading-overlay">
      <div class="loading-spinner"></div>
    </div>

    <!-- 卡片头部 -->
    <div v-if="$slots.header || title" class="card-header">
      <slot name="header">
        <div class="card-title-wrapper">
          <span v-if="icon" class="material-icons card-icon">{{ icon }}</span>
          <h3 class="card-title">{{ title }}</h3>
          <span v-if="badge" class="card-badge">{{ badge }}</span>
        </div>
        <div v-if="$slots.extra" class="card-extra">
          <slot name="extra"></slot>
        </div>
      </slot>
    </div>

    <!-- 卡片内容 -->
    <div class="card-body" :class="{ 'card-body-padded': padding }">
      <slot></slot>
    </div>

    <!-- 卡片底部 -->
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  title?: string
  icon?: string
  badge?: string | number
  variant?: 'default' | 'primary' | 'forest' | 'ocean' | 'mountain' | 'gradient'
  size?: 'small' | 'medium' | 'large'
  hoverable?: boolean
  shadow?: boolean
  bordered?: boolean
  loading?: boolean
  padding?: boolean
}

withDefaults(defineProps<Props>(), {
  variant: 'default',
  size: 'medium',
  hoverable: false,
  shadow: true,
  bordered: false,
  loading: false,
  padding: true
})
</script>

<style scoped lang="scss">
.edu-card {
  background: white;
  border-radius: var(--radius-large);
  overflow: hidden;
  transition: var(--transition-base);
  position: relative;

  &.card-shadow {
    box-shadow: var(--shadow-card);
  }

  &.card-bordered {
    border: 1px solid var(--color-border);
  }

  &.card-hoverable {
    cursor: pointer;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    }

    &:active {
      transform: translateY(-2px);
    }
  }

  // 尺寸变体
  &.card-small {
    .card-header {
      padding: 12px 16px;
    }
    .card-body {
      padding: 12px 16px;
    }
    .card-footer {
      padding: 12px 16px;
    }
  }

  &.card-medium {
    .card-header {
      padding: 16px 20px;
    }
    .card-body {
      padding: 16px 20px;
    }
    .card-footer {
      padding: 16px 20px;
    }
  }

  &.card-large {
    .card-header {
      padding: 20px 24px;
    }
    .card-body {
      padding: 20px 24px;
    }
    .card-footer {
      padding: 20px 24px;
    }
  }

  // 主题变体
  &.card-primary {
    background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
    color: white;

    .card-title {
      color: white;
    }
  }

  &.card-forest {
    background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%);
    border-left: 4px solid var(--color-forest);
  }

  &.card-ocean {
    background: linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 100%);
    border-left: 4px solid var(--color-ocean);
  }

  &.card-mountain {
    background: linear-gradient(135deg, #EFEBE9 0%, #D7CCC8 100%);
    border-left: 4px solid var(--color-mountain);
  }

  &.card-gradient {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;

    .card-title {
      color: white;
    }
  }
}

.card-loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--color-border-light);
}

.card-title-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
}

.card-icon {
  font-size: 24px;
  color: var(--color-primary);
}

.card-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.card-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 2px 8px;
  background: var(--color-primary);
  color: white;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.card-extra {
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-body {
  &:not(.card-body-padded) {
    padding: 0;
  }
}

.card-footer {
  border-top: 1px solid var(--color-border-light);
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
