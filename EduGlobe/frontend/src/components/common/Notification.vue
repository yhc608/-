<template>
  <Teleport to="body">
    <TransitionGroup name="notification" tag="div" class="notification-container">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        class="notification-item"
        :class="`notification-${notification.type}`"
      >
        <div class="notification-icon">
          <span class="material-icons">{{ notification.icon }}</span>
        </div>
        <div class="notification-content">
          <div class="notification-title">{{ notification.title }}</div>
          <div v-if="notification.message" class="notification-message">
            {{ notification.message }}
          </div>
        </div>
        <button class="notification-close" @click="remove(notification.id)">
          <span class="material-icons">close</span>
        </button>
      </div>
    </TransitionGroup>
  </Teleport>
</template>

<script setup lang="ts">
import { useNotification } from '@/composables/useNotification'

const { notifications, remove } = useNotification()
</script>

<style scoped lang="scss">
.notification-container {
  position: fixed;
  top: 24px;
  right: 24px;
  z-index: 3000;
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 400px;
  pointer-events: none;

  @media (max-width: 768px) {
    left: 16px;
    right: 16px;
    max-width: none;
  }
}

.notification-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  background: white;
  border-radius: var(--radius-base);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  pointer-events: auto;
  min-width: 300px;

  &.notification-success {
    border-left: 4px solid var(--color-success);

    .notification-icon {
      color: var(--color-success);
    }
  }

  &.notification-warning {
    border-left: 4px solid var(--color-warning);

    .notification-icon {
      color: var(--color-warning);
    }
  }

  &.notification-error {
    border-left: 4px solid var(--color-error);

    .notification-icon {
      color: var(--color-error);
    }
  }

  &.notification-info {
    border-left: 4px solid var(--color-info);

    .notification-icon {
      color: var(--color-info);
    }
  }
}

.notification-icon {
  flex-shrink: 0;

  .material-icons {
    font-size: 24px;
  }
}

.notification-content {
  flex: 1;
}

.notification-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.notification-message {
  font-size: 14px;
  color: var(--color-text-secondary);
  line-height: 1.5;
}

.notification-close {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  border: none;
  background: transparent;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-small);
  transition: var(--transition-base);

  .material-icons {
    font-size: 18px;
    color: var(--color-text-secondary);
  }

  &:hover {
    background: var(--color-bg-tertiary);
  }
}

// 动画
.notification-enter-active {
  animation: slideInRight 0.3s ease-out;
}

.notification-leave-active {
  animation: slideOutRight 0.3s ease-in;
}

@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOutRight {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(100%);
    opacity: 0;
  }
}
</style>
