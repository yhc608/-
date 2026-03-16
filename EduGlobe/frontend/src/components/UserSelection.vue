<template>
  <div class="user-selection">
    <div class="selection-container">
      <!-- 标题区域 -->
      <div class="header-section">
        <div class="logo">
          <span class="material-icons">school</span>
          <h1>EduGlobe</h1>
        </div>
        <p class="subtitle">选择您的学习阶段，开启地理学习之旅</p>
      </div>

      <!-- 选择卡片区域 -->
      <div class="selection-cards">
        <div 
          v-for="option in educationOptions" 
          :key="option.id"
          class="education-card"
          :class="{ selected: selectedOption === option.id }"
          @click="selectOption(option.id)"
        >
          <div class="card-icon">
            <span class="material-icons">{{ option.icon }}</span>
          </div>
          <div class="card-content">
            <h3>{{ option.title }}</h3>
            <p class="description">{{ option.description }}</p>
            <div class="features">
              <div 
                v-for="feature in option.features" 
                :key="feature"
                class="feature-item"
              >
                <span class="material-icons">check</span>
                <span>{{ feature }}</span>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <span class="duration">{{ option.duration }}</span>
          </div>
        </div>
      </div>

      <!-- 确认按钮 -->
      <div class="action-section">
        <button 
          class="btn-primary confirm-btn"
          :disabled="!selectedOption"
          @click="confirmSelection"
        >
          <span class="material-icons">arrow_forward</span>
          开始学习
        </button>
        <p class="tip">选择后可在设置中随时更改</p>
      </div>
    </div>

    <!-- 背景装饰 -->
    <div class="background-decoration">
      <div class="decoration-circle circle-1"></div>
      <div class="decoration-circle circle-2"></div>
      <div class="decoration-circle circle-3"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// 定义教育阶段选项
const educationOptions = [
  {
    id: 'middle-school',
    title: '初中',
    description: '适合初中生的地理学习内容',
    icon: 'child_care',
    duration: '3年制',
    features: [
      '基础地理概念',
      '中国地理概况',
      '世界地理入门',
      '简单地图识读'
    ]
  },
  {
    id: 'high-school',
    title: '高中',
    description: '适合高中生的地理学习内容',
    icon: 'school',
    duration: '3年制',
    features: [
      '系统地理知识',
      '区域地理分析',
      '地理技能训练',
      '高考考点覆盖'
    ]
  },
  {
    id: 'undergraduate',
    title: '本科生',
    description: '适合本科生的地理学习内容',
    icon: 'account_balance',
    duration: '4年制',
    features: [
      '专业地理理论',
      '地理信息系统',
      '研究方法训练',
      '学术论文写作'
    ]
  }
]

// 状态管理
const selectedOption = ref<string | null>(null)

// 方法
function selectOption(optionId: string) {
  selectedOption.value = optionId
}

function confirmSelection() {
  if (selectedOption.value) {
    // 保存选择到本地存储
    localStorage.setItem('userEducationLevel', selectedOption.value)
    
    // 触发父组件事件
    emit('selectionConfirmed', selectedOption.value)
  }
}

// 定义事件
const emit = defineEmits<{
  selectionConfirmed: [level: string]
}>()
</script>

<style scoped lang="scss">
.user-selection {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-base);
  position: relative;
  overflow: hidden;
}

.selection-container {
  background: white;
  border-radius: 20px;
  padding: var(--spacing-large);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  max-width: 1000px;
  width: 100%;
  position: relative;
  z-index: 2;
}

// 标题区域
.header-section {
  text-align: center;
  margin-bottom: var(--spacing-large);

  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--spacing-base);
    margin-bottom: var(--spacing-base);

    .material-icons {
      font-size: 3rem;
      color: var(--color-primary);
    }

    h1 {
      font-size: 2.5rem;
      font-weight: 700;
      color: var(--color-primary);
      margin: 0;
    }
  }

  .subtitle {
    font-size: 1.2em;
    color: var(--color-text-secondary);
    margin: 0;
  }
}

// 选择卡片区域
.selection-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
}

.education-card {
  background: white;
  border: 2px solid var(--color-border);
  border-radius: 16px;
  padding: var(--spacing-base);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
    border-color: var(--color-primary);
  }

  &.selected {
    border-color: var(--color-primary);
    background: linear-gradient(135deg, #f8f9ff 0%, #e8f2ff 100%);
    transform: translateY(-2px);
    box-shadow: 0 8px 16px rgba(102, 126, 234, 0.2);

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
    }
  }

  .card-icon {
    text-align: center;
    margin-bottom: var(--spacing-base);

    .material-icons {
      font-size: 3rem;
      color: var(--color-primary);
    }
  }

  .card-content {
    text-align: center;
    margin-bottom: var(--spacing-base);

    h3 {
      font-size: 1.5rem;
      font-weight: 600;
      color: var(--color-text-primary);
      margin: 0 0 var(--spacing-small);
    }

    .description {
      color: var(--color-text-secondary);
      margin-bottom: var(--spacing-base);
      line-height: 1.5;
    }

    .features {
      text-align: left;

      .feature-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-small);
        margin-bottom: var(--spacing-small);
        font-size: 0.9em;
        color: var(--color-text-secondary);

        .material-icons {
          font-size: 1rem;
          color: var(--color-success);
        }
      }
    }
  }

  .card-footer {
    text-align: center;
    padding-top: var(--spacing-base);
    border-top: 1px solid var(--color-border);

    .duration {
      font-size: 0.9em;
      color: var(--color-text-secondary);
      font-weight: 500;
    }
  }
}

// 操作区域
.action-section {
  text-align: center;

  .confirm-btn {
    display: inline-flex;
    align-items: center;
    gap: var(--spacing-small);
    padding: var(--spacing-base) var(--spacing-large);
    font-size: 1.1em;
    font-weight: 600;
    margin-bottom: var(--spacing-base);

    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  }

  .tip {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    margin: 0;
  }
}

// 背景装饰
.background-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 1;

  .decoration-circle {
    position: absolute;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    animation: float 6s ease-in-out infinite;

    &.circle-1 {
      width: 200px;
      height: 200px;
      top: 10%;
      left: 10%;
      animation-delay: 0s;
    }

    &.circle-2 {
      width: 150px;
      height: 150px;
      top: 60%;
      right: 15%;
      animation-delay: 2s;
    }

    &.circle-3 {
      width: 100px;
      height: 100px;
      bottom: 20%;
      left: 20%;
      animation-delay: 4s;
    }
  }
}

// 动画
@keyframes float {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .selection-container {
    padding: var(--spacing-base);
    margin: var(--spacing-base);
  }

  .header-section {
    .logo {
      .material-icons {
        font-size: 2.5rem;
      }

      h1 {
        font-size: 2rem;
      }
    }

    .subtitle {
      font-size: 1em;
    }
  }

  .selection-cards {
    grid-template-columns: 1fr;
    gap: var(--spacing-base);
  }

  .education-card {
    .card-icon .material-icons {
      font-size: 2.5rem;
    }

    .card-content h3 {
      font-size: 1.3rem;
    }
  }
}

// 适配大字体模式
:global(.large-text) {
  .education-card {
    .card-content {
      h3 {
        font-size: 1.6rem;
      }

      .description {
        font-size: 1.1em;
      }

      .features .feature-item {
        font-size: 1em;
      }
    }
  }

  .confirm-btn {
    font-size: 1.2em;
  }
}

:global(.xlarge-text) {
  .education-card {
    .card-content {
      h3 {
        font-size: 1.7rem;
      }

      .description {
        font-size: 1.2em;
      }

      .features .feature-item {
        font-size: 1.1em;
      }
    }
  }

  .confirm-btn {
    font-size: 1.3em;
  }
}
</style>
