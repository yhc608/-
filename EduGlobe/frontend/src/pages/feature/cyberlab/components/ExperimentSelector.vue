<template>
  <div class="experiment-selector">
    <!-- 搜索和筛选栏 -->
    <div class="filter-bar">
      <div class="search-box">
        <input
          v-model="searchKeyword"
          type="text"
          placeholder="搜索实验名称或关键词..."
          class="search-input"
        />
      </div>
      <div class="filter-group">
        <label>知识模块：</label>
        <select v-model="selectedModule" class="filter-select">
          <option value="">全部</option>
          <option v-for="module in knowledgeModules" :key="module" :value="module">
            {{ module }}
          </option>
        </select>
      </div>
    </div>

    <!-- 实验卡片列表 -->
    <div class="experiment-grid">
      <div
        v-for="exp in filteredExperiments"
        :key="exp.id"
        class="experiment-card"
        @click="$emit('start', exp.id)"
      >
        <div class="card-header">
          <h3 class="card-title">{{ exp.name }}</h3>
          <span class="card-module">{{ exp.knowledgeModule }}</span>
        </div>
        <p class="card-description">{{ exp.description }}</p>
        <div class="card-meta">
          <span class="card-chapter">{{ exp.textbookChapter }}</span>
          <div class="card-tags">
            <span v-for="tag in exp.tags" :key="tag" class="tag">{{ tag }}</span>
          </div>
        </div>
        <div class="card-variables">
          <span class="variables-label">变量：</span>
          <span class="variables-list">
            {{ exp.variables.map((v: any) => v.key).join('、') }}
          </span>
        </div>
        <button class="start-btn">开始实验</button>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-if="filteredExperiments.length === 0" class="empty-state">
      <p>暂无匹配的实验</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

interface Experiment {
  id: string
  name: string
  knowledgeModule: string
  textbookChapter: string
  tags: string[]
  description: string
  variables: Array<{ key: string }>
}

const props = defineProps<{ items: Experiment[] }>()
const emit = defineEmits<{ (e: 'start', id: string): void }>()

const searchKeyword = ref('')
const selectedModule = ref('')

// 提取所有知识模块
const knowledgeModules = computed(() => {
  const modules = new Set<string>()
  props.items.forEach((exp) => {
    if (exp.knowledgeModule) {
      modules.add(exp.knowledgeModule)
    }
  })
  return Array.from(modules)
})

// 筛选实验
const filteredExperiments = computed(() => {
  let result = props.items

  // 关键词搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(
      (exp) =>
        exp.name.toLowerCase().includes(keyword) ||
        exp.description.toLowerCase().includes(keyword) ||
        exp.tags.some((tag) => tag.toLowerCase().includes(keyword))
    )
  }

  // 知识模块筛选
  if (selectedModule.value) {
    result = result.filter((exp) => exp.knowledgeModule === selectedModule.value)
  }

  return result
})
</script>

<style scoped>
.experiment-selector {
  padding: var(--spacing-base);
}

.filter-bar {
  display: flex;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
  flex-wrap: wrap;
}

.search-box {
  flex: 1;
  min-width: 200px;
}

.search-input {
  width: 100%;
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: var(--color-bg-secondary);
  font-size: 14px;
  transition: var(--transition-base);
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(123, 107, 82, 0.1);
}

.filter-group {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
}

.filter-select {
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: var(--color-bg-secondary);
  font-size: 14px;
  cursor: pointer;
  transition: var(--transition-base);
}

.filter-select:focus {
  outline: none;
  border-color: var(--color-primary);
}

.experiment-grid {
  display: grid;
  /* 固定三列等宽布局 */
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
}

.experiment-card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  cursor: pointer;
  transition: var(--transition-base);
  box-shadow: var(--shadow-base);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.experiment-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-large);
  border-color: var(--color-primary);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--spacing-small);
}

.card-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
  flex: 1;
}

.card-module {
  background: var(--color-primary);
  color: white;
  padding: 4px var(--spacing-small);
  border-radius: var(--radius-small);
  font-size: 12px;
  white-space: nowrap;
}

.card-description {
  margin: 0;
  font-size: 14px;
  color: var(--color-text-secondary);
  line-height: 1.5;
  flex: 1;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.card-chapter {
  font-size: 12px;
  color: var(--color-text-secondary);
  background: var(--color-bg-tertiary);
  padding: 2px var(--spacing-small);
  border-radius: var(--radius-small);
}

.card-tags {
  display: flex;
  gap: var(--spacing-small);
  flex-wrap: wrap;
}

.tag {
  background: rgba(123, 107, 82, 0.1);
  color: var(--color-primary);
  padding: 2px var(--spacing-small);
  border-radius: var(--radius-small);
  font-size: 12px;
  border: 1px solid rgba(123, 107, 82, 0.2);
}

.card-variables {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  font-size: 13px;
  color: var(--color-text-secondary);
  padding-top: var(--spacing-small);
  border-top: 1px solid var(--color-border-light);
}

.variables-label {
  font-weight: 500;
}

.variables-list {
  flex: 1;
}

.start-btn {
  margin-top: var(--spacing-small);
  padding: var(--spacing-small) var(--spacing-base);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: white;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: var(--transition-base);
  box-shadow: 0 2px 8px rgba(123, 107, 82, 0.3);
}

.start-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(123, 107, 82, 0.4);
}

.empty-state {
  text-align: center;
  padding: var(--spacing-xlarge);
  color: var(--color-text-secondary);
}

@media (max-width: 768px) {
  .experiment-grid {
    grid-template-columns: 1fr;
  }

  .filter-bar {
    flex-direction: column;
  }

  .search-box {
    min-width: 100%;
  }
}
</style>
