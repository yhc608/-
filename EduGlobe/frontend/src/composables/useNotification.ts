// src/composables/useNotification.ts
import { ref } from 'vue'

export type NotificationType = 'success' | 'warning' | 'error' | 'info'

export interface Notification {
  id: number
  type: NotificationType
  title: string
  message?: string
  duration?: number
  icon?: string
}

const notifications = ref<Notification[]>([])
let notificationId = 0

export function useNotification() {
  const notify = (options: Omit<Notification, 'id'>) => {
    const id = notificationId++
    const notification: Notification = {
      id,
      duration: 3000,
      ...options
    }

    notifications.value.push(notification)

    if (notification.duration && notification.duration > 0) {
      setTimeout(() => {
        remove(id)
      }, notification.duration)
    }

    return id
  }

  const success = (title: string, message?: string, duration?: number) => {
    return notify({
      type: 'success',
      title,
      message,
      duration,
      icon: 'check_circle'
    })
  }

  const warning = (title: string, message?: string, duration?: number) => {
    return notify({
      type: 'warning',
      title,
      message,
      duration,
      icon: 'warning'
    })
  }

  const error = (title: string, message?: string, duration?: number) => {
    return notify({
      type: 'error',
      title,
      message,
      duration: duration || 5000,
      icon: 'error'
    })
  }

  const info = (title: string, message?: string, duration?: number) => {
    return notify({
      type: 'info',
      title,
      message,
      duration,
      icon: 'info'
    })
  }

  const remove = (id: number) => {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index !== -1) {
      notifications.value.splice(index, 1)
    }
  }

  const clear = () => {
    notifications.value = []
  }

  return {
    notifications,
    notify,
    success,
    warning,
    error,
    info,
    remove,
    clear
  }
}
