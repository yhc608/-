<template>
  <div v-if="visible" class="popup-overlay" @click.self="close">
    <div class="popup-content">
      <div class="popup-header">
        <h3>实验原理</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="popup-body">
        <div class="principle-text">
          <p>{{ principle }}</p>
        </div>
        <div class="principle-tips">
          <h4>关键要点：</h4>
          <ul>
            <li v-for="(tip, index) in tips" :key="index">{{ tip }}</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  visible: boolean
  principle: string
}>()

const emit = defineEmits<{
  (e: 'close'): void
}>()

function close() {
  emit('close')
}

// 根据原理文本提取关键要点（简化版，实际可以从数据中获取）
const tips = computed(() => {
  const text = props.principle
  const tipsList: string[] = []
  
  if (text.includes('热力环流')) {
    tipsList.push('热源处空气受热膨胀上升')
    tipsList.push('冷源处空气冷却收缩下沉')
    tipsList.push('形成闭合的环流系统')
  } else if (text.includes('大气保温')) {
    tipsList.push('大气对地面长波辐射有较强的吸收能力')
    tipsList.push('夜间大气向地面释放热量')
    tipsList.push('大气浓度越高，保温效果越明显')
  } else if (text.includes('水土流失')) {
    tipsList.push('植被通过根系固定土壤')
    tipsList.push('坡度越大、降水越强，侵蚀越严重')
    tipsList.push('黏质土壤抗侵蚀能力最强')
  }
  
  return tipsList.length > 0 ? tipsList : ['请仔细观察实验现象', '注意变量变化对结果的影响']
})
</script>

<style scoped>
.popup-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--color-bg-mask);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.popup-content {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-large);
  box-shadow: var(--shadow-large);
  max-width: 600px;
  width: 90%;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base) var(--spacing-large);
  border-bottom: 1px solid var(--color-border-light);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: white;
}

.popup-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 32px;
  height: 32px;
  border-radius: var(--radius-circle);
  cursor: pointer;
  font-size: 24px;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition-base);
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.popup-body {
  padding: var(--spacing-large);
  overflow-y: auto;
  flex: 1;
}

.principle-text {
  margin-bottom: var(--spacing-large);
}

.principle-text p {
  margin: 0;
  font-size: 15px;
  line-height: 1.8;
  color: var(--color-text-primary);
  text-align: justify;
}

.principle-tips {
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  border-left: 4px solid var(--color-primary);
}

.principle-tips h4 {
  margin: 0 0 var(--spacing-small) 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.principle-tips ul {
  margin: 0;
  padding-left: var(--spacing-large);
  list-style-type: disc;
}

.principle-tips li {
  margin-bottom: var(--spacing-small);
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.principle-tips li:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .popup-content {
    width: 95%;
    max-height: 85vh;
  }

  .popup-header {
    padding: var(--spacing-base);
  }

  .popup-body {
    padding: var(--spacing-base);
  }
}
</style>



