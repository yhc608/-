<template>
  <div class="variable-panel">
    <div class="panel-header">
      <h3>变量控制</h3>
      <p class="panel-tip">调整变量观察实验变化</p>
    </div>
    <div class="variables-list">
      <div v-for="variable in variables" :key="variable.key" class="variable-item">
        <div class="variable-label">
          <span class="label-text">
            <span class="icon" v-if="variable.key.includes('热源')">🔥</span>
            <span class="icon" v-else-if="variable.key.includes('冷源')">❄️</span>
            <span class="icon" v-else-if="variable.key.includes('空间')">🧊</span>
            {{ variable.key }}
          </span>
          <span class="label-desc">{{ variable.description }}</span>
        </div>
        <div class="variable-control">
          <!-- 特判：热源强度 滑块 0-100℃ -->
          <div v-if="variable.key === '热源强度'" class="slider-group">
            <input
              type="range"
              :min="0"
              :max="100"
              :step="1"
              :value="getNumericValue(variable.key)"
              @input="updateValue(variable.key, ($event.target as HTMLInputElement).value)"
              class="slider"
            />
            <span class="slider-value">{{ getNumericValue(variable.key) }}℃</span>
          </div>
          <!-- 特判：冷源强度 滑块 -20~20℃ -->
          <div v-else-if="variable.key === '冷源强度'" class="slider-group">
            <input
              type="range"
              :min="-20"
              :max="20"
              :step="1"
              :value="getNumericValue(variable.key)"
              @input="updateValue(variable.key, ($event.target as HTMLInputElement).value)"
              class="slider"
            />
            <span class="slider-value">{{ getNumericValue(variable.key) }}℃</span>
          </div>
          <!-- 按钮组类型（其他变量） -->
          <div v-else-if="variable.type === 'button'" class="button-group">
            <button
              v-for="option in variable.options"
              :key="option"
              :class="['control-btn', { active: localValues[variable.key] === option }]"
              @click="updateValue(variable.key, option)"
            >
              {{ option }}
            </button>
          </div>
          <!-- 滑块类型 -->
          <div v-else-if="variable.type === 'slider'" class="slider-group">
            <input
              type="range"
              :min="variable.min || 0"
              :max="variable.max || 100"
              :step="variable.step || 1"
              :value="getNumericValue(variable.key)"
              @input="updateValue(variable.key, ($event.target as HTMLInputElement).value)"
              class="slider"
            />
            <span class="slider-value">{{ getNumericValue(variable.key) }}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="panel-actions">
      <button class="start-btn" @click="$emit('start')">开始实验</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, watch } from 'vue'

interface Variable {
  key: string
  type: 'button' | 'slider'
  options?: string[]
  default?: string | number
  min?: number
  max?: number
  step?: number
  description: string
}

const props = defineProps<{
  variables: Variable[]
  modelValue: Record<string, string | number>
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: Record<string, string | number>): void
  (e: 'start'): void
}>()

// 初始化本地值
const localValues = reactive<Record<string, string | number>>({})

// 初始化默认值
function initValues() {
  props.variables.forEach((variable) => {
    if (props.modelValue && props.modelValue[variable.key] !== undefined) {
      localValues[variable.key] = props.modelValue[variable.key]
    } else if (variable.default !== undefined) {
      localValues[variable.key] = variable.default
    } else if (variable.type === 'button' && variable.options && variable.options.length > 0) {
      localValues[variable.key] = variable.options[0]
    } else {
      localValues[variable.key] = 0
    }
  })
  emit('update:modelValue', { ...localValues })
}

// 更新值
function updateValue(key: string, value: string | number) {
  localValues[key] = value
  emit('update:modelValue', { ...localValues })
}

// 获取数值（用于滑块）
function getNumericValue(key: string): number {
  const value = localValues[key]
  if (typeof value === 'number') {
    return value
  }
  if (typeof value === 'string') {
    const num = parseFloat(value)
    return isNaN(num) ? 0 : num
  }
  return 0
}

// 监听外部值变化
watch(
  () => props.modelValue,
  (newValue) => {
    if (newValue) {
      Object.assign(localValues, newValue)
    }
  },
  { deep: true, immediate: true }
)

// 初始化
initValues()
</script>

<style scoped>
.variable-panel {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
  height: fit-content;
  position: sticky;
  top: var(--spacing-base);
}

.panel-header {
  margin-bottom: var(--spacing-base);
  padding-bottom: var(--spacing-base);
  border-bottom: 1px solid var(--color-border-light);
}

.panel-header h3 {
  margin: 0 0 var(--spacing-small) 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.panel-tip {
  margin: 0;
  font-size: 12px;
  color: var(--color-text-secondary);
}

.variables-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-large);
}

.variable-item {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.variable-label {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.label-text {
  font-size: 15px;
  font-weight: 500;
  color: var(--color-text-primary);
}

.label-text .icon {
  margin-right: 6px;
}

.label-desc {
  font-size: 12px;
  color: var(--color-text-secondary);
  line-height: 1.4;
}

.variable-control {
  margin-top: var(--spacing-small);
}

.button-group {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.control-btn {
  flex: 1;
  min-width: 80px;
  padding: var(--spacing-small) var(--spacing-base);
  background: var(--color-bg-tertiary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  color: var(--color-text-primary);
  font-size: 14px;
  cursor: pointer;
  transition: var(--transition-base);
  white-space: nowrap;
}

.control-btn:hover {
  background: var(--color-primary-light);
  color: white;
  border-color: var(--color-primary);
}

.control-btn.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: white;
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px rgba(123, 107, 82, 0.3);
}

.slider-group {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
}

.slider {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: var(--color-border-light);
  outline: none;
  -webkit-appearance: none;
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--color-primary);
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  transition: var(--transition-base);
}

.slider::-webkit-slider-thumb:hover {
  background: var(--color-primary-dark);
  transform: scale(1.1);
}

.slider::-moz-range-thumb {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--color-primary);
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.slider-value {
  min-width: 50px;
  text-align: right;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-primary);
}

.panel-actions {
  margin-top: var(--spacing-large);
}

.start-btn {
  width: 100%;
  padding: 12px 16px;
  background: linear-gradient(135deg, #10b981 0%, #22c55e 100%);
  border: none;
  border-radius: var(--radius-base);
  color: white;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.35);
}

.start-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.45);
}

@media (max-width: 768px) {
  .variable-panel {
    position: static;
  }

  .button-group {
    flex-direction: column;
  }

  .control-btn {
    width: 100%;
  }
}
</style>
