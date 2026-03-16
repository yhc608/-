<template>
  <div class="settings-page">
    <div class="page-header">
      <h1>设置</h1>
      <p>个性化您的学习体验</p>
    </div>

    <div class="settings-content">
      <!-- 教育阶段设置 -->
      <div class="setting-section">
        <div class="section-header">
          <h2>学习阶段</h2>
          <span class="current-level">{{ getCurrentLevelName() }}</span>
        </div>
        <div class="section-content">
          <p class="section-description">选择您的学习阶段，系统将为您提供相应的学习内容</p>
          <button class="btn-primary" @click="showLevelSelector = true">
            <span class="material-icons">edit</span>
            更改学习阶段
          </button>
        </div>
      </div>

      <!-- 其他设置选项 -->
      <div class="setting-section">
        <div class="section-header">
          <h2>学习偏好</h2>
        </div>
        <div class="section-content">
          <div class="setting-item">
            <div class="setting-info">
              <h3>字体大小</h3>
              <p>调整界面文字大小</p>
            </div>
            <div class="setting-control">
              <select v-model="fontSize" @change="updateFontSize">
                <option value="normal">标准</option>
                <option value="large">大字体</option>
                <option value="xlarge">超大字体</option>
              </select>
            </div>
          </div>

          <div class="setting-item">
            <div class="setting-info">
              <h3>主题模式</h3>
              <p>选择您喜欢的界面主题</p>
            </div>
            <div class="setting-control">
              <select v-model="theme" @change="updateTheme">
                <option value="light">浅色模式</option>
                <option value="dark">深色模式</option>
                <option value="auto">跟随系统</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- 数据管理 -->
      <div class="setting-section">
        <div class="section-header">
          <h2>数据管理</h2>
        </div>
        <div class="section-content">
          <div class="setting-item">
            <div class="setting-info">
              <h3>清除学习记录</h3>
              <p>清除所有学习进度和记录</p>
            </div>
            <div class="setting-control">
              <button class="btn-text danger" @click="clearLearningData">
                <span class="material-icons">delete</span>
                清除数据
              </button>
            </div>
          </div>

          <div class="setting-item">
            <div class="setting-info">
              <h3>重置应用</h3>
              <p>重置所有设置到初始状态</p>
            </div>
            <div class="setting-control">
              <button class="btn-text danger" @click="resetApp">
                <span class="material-icons">refresh</span>
                重置应用
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 教育阶段选择模态框 -->
    <div v-if="showLevelSelector" class="level-selector-modal" @click.self="showLevelSelector = false">
      <div class="modal-content">
        <div class="modal-header">
          <h3>选择学习阶段</h3>
          <button class="btn-icon" @click="showLevelSelector = false">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="level-options">
            <div 
              v-for="option in educationOptions" 
              :key="option.id"
              class="level-option"
              :class="{ selected: selectedLevel === option.id }"
              @click="selectedLevel = option.id"
            >
              <div class="option-icon">
                <span class="material-icons">{{ option.icon }}</span>
              </div>
              <div class="option-content">
                <h4>{{ option.title }}</h4>
                <p>{{ option.description }}</p>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-text" @click="showLevelSelector = false">取消</button>
          <button class="btn-primary" @click="confirmLevelChange" :disabled="!selectedLevel">
            确认更改
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

// 教育阶段选项
const educationOptions = [
  {
    id: 'middle-school',
    title: '初中',
    description: '适合初中生的地理学习内容',
    icon: 'child_care'
  },
  {
    id: 'high-school',
    title: '高中',
    description: '适合高中生的地理学习内容',
    icon: 'school'
  },
  {
    id: 'undergraduate',
    title: '本科生',
    description: '适合本科生的地理学习内容',
    icon: 'account_balance'
  }
]

// 状态管理
const showLevelSelector = ref(false)
const selectedLevel = ref<string>('')
const fontSize = ref('normal')
const theme = ref('light')

// 获取当前教育阶段名称
function getCurrentLevelName() {
  const currentLevel = localStorage.getItem('userEducationLevel')
  const option = educationOptions.find(opt => opt.id === currentLevel)
  return option ? option.title : '未选择'
}

// 确认更改教育阶段
function confirmLevelChange() {
  if (selectedLevel.value) {
    localStorage.setItem('userEducationLevel', selectedLevel.value)
    
    // 触发全局事件
    window.dispatchEvent(new CustomEvent('educationLevelChanged', { 
      detail: { level: selectedLevel.value } 
    }))
    
    showLevelSelector.value = false
    selectedLevel.value = ''
    
    // 显示成功提示
    alert('学习阶段已更新！')
  }
}

// 更新字体大小
function updateFontSize() {
  document.body.className = document.body.className.replace(/large-text|xlarge-text/g, '')
  if (fontSize.value !== 'normal') {
    document.body.classList.add(fontSize.value + '-text')
  }
  localStorage.setItem('fontSize', fontSize.value)
}

// 更新主题
function updateTheme() {
  document.body.className = document.body.className.replace(/theme-light|theme-dark|theme-auto/g, '')
  document.body.classList.add('theme-' + theme.value)
  localStorage.setItem('theme', theme.value)
}

// 清除学习数据
function clearLearningData() {
  if (confirm('确定要清除所有学习记录吗？此操作不可恢复。')) {
    // 清除学习相关的本地存储数据
    const keysToRemove = []
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key && (key.includes('learning') || key.includes('progress') || key.includes('history'))) {
        keysToRemove.push(key)
      }
    }
    keysToRemove.forEach(key => localStorage.removeItem(key))
    alert('学习记录已清除！')
  }
}

// 重置应用
function resetApp() {
  if (confirm('确定要重置所有设置吗？这将清除所有数据并重新开始。')) {
    localStorage.clear()
    alert('应用已重置！页面将刷新。')
    window.location.reload()
  }
}

onMounted(() => {
  // 加载保存的设置
  const savedFontSize = localStorage.getItem('fontSize')
  if (savedFontSize) {
    fontSize.value = savedFontSize
    updateFontSize()
  }

  const savedTheme = localStorage.getItem('theme')
  if (savedTheme) {
    theme.value = savedTheme
    updateTheme()
  }
})
</script>

<style scoped lang="scss">
.settings-page {
  padding: var(--spacing-base);
  padding-bottom: 60px;
  min-height: 100vh;
  background: #f8f9fa;
}

.page-header {
  text-align: center;
  margin-bottom: var(--spacing-large);
  padding: var(--spacing-large) 0;

  h1 {
    font-size: 2rem;
    font-weight: 700;
    color: var(--color-text-primary);
    margin: 0 0 var(--spacing-small);
  }

  p {
    color: var(--color-text-secondary);
    margin: 0;
  }
}

.settings-content {
  max-width: 800px;
  margin: 0 auto;
}

.setting-section {
  background: white;
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);
  background: #f8f9fa;

  h2 {
    margin: 0;
    font-size: 1.2em;
    color: var(--color-text-primary);
  }

  .current-level {
    background: var(--color-primary);
    color: white;
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 0.9em;
    font-weight: 500;
  }
}

.section-content {
  padding: var(--spacing-base);
}

.section-description {
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-base);
  line-height: 1.5;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base) 0;
  border-bottom: 1px solid var(--color-border);

  &:last-child {
    border-bottom: none;
  }
}

.setting-info {
  flex: 1;

  h3 {
    margin: 0 0 var(--spacing-small);
    font-size: 1.1em;
    color: var(--color-text-primary);
  }

  p {
    margin: 0;
    color: var(--color-text-secondary);
    font-size: 0.9em;
  }
}

.setting-control {
  select {
    padding: var(--spacing-small) var(--spacing-base);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    background: white;
    font-size: inherit;
    min-width: 120px;

    &:focus {
      outline: none;
      border-color: var(--color-primary);
    }
  }

  .btn-text {
    &.danger {
      color: var(--color-error);

      &:hover {
        background: rgba(255, 77, 79, 0.1);
      }
    }
  }
}

// 教育阶段选择模态框
.level-selector-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: var(--radius-base);
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);

  h3 {
    margin: 0;
  }
}

.modal-body {
  padding: var(--spacing-base);
}

.level-options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.level-option {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    border-color: var(--color-primary);
    background: #f8f9ff;
  }

  &.selected {
    border-color: var(--color-primary);
    background: linear-gradient(135deg, #f8f9ff 0%, #e8f2ff 100%);
  }

  .option-icon {
    .material-icons {
      font-size: 2rem;
      color: var(--color-primary);
    }
  }

  .option-content {
    flex: 1;

    h4 {
      margin: 0 0 var(--spacing-small);
      color: var(--color-text-primary);
    }

    p {
      margin: 0;
      color: var(--color-text-secondary);
      font-size: 0.9em;
    }
  }
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  border-top: 1px solid var(--color-border);
}

// 响应式设计
@media (max-width: 768px) {
  .settings-page {
    padding: var(--spacing-small);
  }

  .page-header {
    padding: var(--spacing-base) 0;

    h1 {
      font-size: 1.5rem;
    }
  }

  .setting-item {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--spacing-small);

    .setting-control {
      width: 100%;
    }
  }
}

// 适配大字体模式
:global(.large-text) {
  .page-header h1 {
    font-size: 2.2rem;
  }

  .section-header h2 {
    font-size: 1.3em;
  }

  .setting-info h3 {
    font-size: 1.2em;
  }
}

:global(.xlarge-text) {
  .page-header h1 {
    font-size: 2.4rem;
  }

  .section-header h2 {
    font-size: 1.4em;
  }

  .setting-info h3 {
    font-size: 1.3em;
  }
}
</style>
