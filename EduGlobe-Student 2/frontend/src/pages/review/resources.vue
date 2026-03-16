<template>
  <div class="resources">
    <!-- 资源分类 -->
    <div class="categories card">
      <div class="section-header">
        <h3>资源分类</h3>
        <div class="view-mode">
          <button 
            v-for="mode in ['grid', 'list']" 
            :key="mode"
            :class="{ active: viewMode === mode }"
            class="btn-icon"
            @click="viewMode = mode"
          >
            <span class="material-icons">
              {{ mode === 'grid' ? 'grid_view' : 'view_list' }}
            </span>
          </button>
        </div>
      </div>

      <div class="category-list" :class="viewMode">
        <div 
          v-for="category in categories" 
          :key="category.id"
          class="category-item"
          @click="selectCategory(category)"
        >
          <div class="category-icon" :style="{ backgroundColor: category.color }">
            <span class="material-icons">{{ category.icon }}</span>
          </div>
          <div class="category-info">
            <div class="category-name">{{ category.name }}</div>
            <div class="category-meta">
              <span class="count">{{ category.count }}个资源</span>
              <span class="update" v-if="category.hasUpdate">有更新</span>
            </div>
          </div>
          <div class="offline-status">
            <span 
              class="material-icons"
              :class="{ downloaded: category.isDownloaded }"
            >
              {{ category.isDownloaded ? 'check_circle' : 'cloud_download' }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- 推荐资源 -->
    <div class="recommended card">
      <div class="section-header">
        <h3>推荐资源</h3>
        <button class="btn-text" @click="refreshRecommended">
          <span class="material-icons">refresh</span>
          换一批
        </button>
      </div>

      <div class="resource-list">
        <div 
          v-for="resource in recommendedResources" 
          :key="resource.id"
          class="resource-item"
          @click="openResource(resource)"
        >
          <div class="resource-preview">
            <img :src="resource.cover" :alt="resource.title">
            <div class="resource-type" :style="{ backgroundColor: resource.typeColor }">
              {{ resource.type }}
            </div>
          </div>
          <div class="resource-info">
            <div class="resource-title">{{ resource.title }}</div>
            <div class="resource-meta">
              <span class="size">{{ resource.size }}</span>
              <span class="downloads">{{ resource.downloads }}次下载</span>
            </div>
          </div>
          <button 
            class="btn-icon download"
            @click.stop="downloadResource(resource)"
            :class="{ downloaded: resource.isDownloaded }"
          >
            <span class="material-icons">
              {{ resource.isDownloaded ? 'check_circle' : 'cloud_download' }}
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- 最近使用 -->
    <div class="recent card">
      <div class="section-header">
        <h3>最近使用</h3>
        <button class="btn-text" @click="clearHistory" v-if="recentResources.length">
          清空记录
        </button>
      </div>

      <div class="resource-list">
        <div 
          v-for="resource in recentResources" 
          :key="resource.id"
          class="resource-item"
          @click="openResource(resource)"
        >
          <div class="resource-preview">
            <img :src="resource.cover" :alt="resource.title">
            <div class="resource-type" :style="{ backgroundColor: resource.typeColor }">
              {{ resource.type }}
            </div>
          </div>
          <div class="resource-info">
            <div class="resource-title">{{ resource.title }}</div>
            <div class="resource-meta">
              <span class="time">{{ formatTime(resource.lastUsed) }}</span>
              <span class="chapter">{{ resource.chapter }}</span>
            </div>
          </div>
          <button 
            class="btn-icon"
            @click.stop="removeFromRecent(resource)"
          >
            <span class="material-icons">close</span>
          </button>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="!recentResources.length" class="empty-state">
        <span class="material-icons">history</span>
        <p>暂无使用记录</p>
      </div>
    </div>

    <!-- 下载管理弹窗 -->
    <div v-if="showDownloadModal" class="modal" @click.self="showDownloadModal = false">
      <div class="modal-content card">
        <div class="modal-header">
          <h3>下载管理</h3>
          <button class="btn-icon" @click="showDownloadModal = false">
            <span class="material-icons">close</span>
          </button>
        </div>

        <div class="download-list">
          <div 
            v-for="task in downloadTasks" 
            :key="task.id"
            class="download-item"
          >
            <div class="task-info">
              <div class="task-name">{{ task.name }}</div>
              <div class="task-progress">
                <div 
                  class="progress-bar"
                  :style="{ width: `${task.progress}%` }"
                ></div>
                <span class="progress-text">{{ task.progress }}%</span>
              </div>
            </div>
            <button 
              class="btn-icon"
              @click="cancelDownload(task)"
              v-if="task.progress < 100"
            >
              <span class="material-icons">cancel</span>
            </button>
            <button 
              class="btn-icon"
              @click="deleteDownload(task)"
              v-else
            >
              <span class="material-icons">delete</span>
            </button>
          </div>
        </div>

        <div class="modal-footer">
          <div class="storage-info">
            <div class="storage-text">
              已用空间: {{ usedStorage }} / {{ totalStorage }}
            </div>
            <div class="storage-bar">
              <div 
                class="storage-used"
                :style="{ width: `${(usedStorage / totalStorage) * 100}%` }"
              ></div>
            </div>
          </div>
          <button 
            class="btn-text danger"
            @click="clearDownloads"
            v-if="downloadTasks.length"
          >
            清空下载
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const viewMode = ref('grid')
const showDownloadModal = ref(false)

// 模拟数据
const categories = ref([
  {
    id: 'c1',
    name: '纪录片资源库',
    icon: 'movie',
    color: '#1890ff',
    count: 24,
    hasUpdate: true,
    isDownloaded: true
  },
  {
    id: 'c2',
    name: '地理公众号精选',
    icon: 'article',
    color: '#52c41a',
    count: 12,
    hasUpdate: false,
    isDownloaded: false
  },
  {
    id: 'c3',
    name: 'gis动态演示示意图',
    icon: 'animation',
    color: '#faad14',
    count: 18,
    hasUpdate: false,
    isDownloaded: true
  },
  {
    id: 'c4',
    name: '家庭实验资源库',
    icon: 'science',
    color: '#722ed1',
    count: 8,
    hasUpdate: true,
    isDownloaded: false
  },
  {
    id: 'c5',
    name: '实践成果展示平台',
    icon: 'show_chart',
    color: '#f5222d',
    count: 15,
    hasUpdate: false,
    isDownloaded: true
  },
  {
    id: 'c6',
    name: '社区互动与竞赛',
    icon: 'groups',
    color: '#13c2c2',
    count: 6,
    hasUpdate: true,
    isDownloaded: false
  }
])

const recommendedResources = ref([
  {
    id: 'r1',
    title: '地球自转与公转动画',
    type: '视频',
    typeColor: '#1890ff',
    cover: '/demo/earth-rotation.jpg',
    size: '45MB',
    downloads: 1280,
    isDownloaded: true
  },
  {
    id: 'r2',
    title: '火山喷发模型',
    type: '3D',
    typeColor: '#52c41a',
    cover: '/demo/volcano.jpg',
    size: '128MB',
    downloads: 856,
    isDownloaded: false
  }
])

const recentResources = ref([
  {
    id: 'h1',
    title: '天气系统形成过程',
    type: '视频',
    typeColor: '#1890ff',
    cover: '/demo/weather.jpg',
    lastUsed: Date.now() - 3600000,
    chapter: '大气环流'
  }
])

const downloadTasks = ref([
  {
    id: 'd1',
    name: '火山喷发模型.glb',
    progress: 45
  },
  {
    id: 'd2',
    name: '地球运动.mp4',
    progress: 100
  }
])

const usedStorage = '1.2GB'
const totalStorage = '5GB'

// 方法
function selectCategory(category: any) {
  router.push(`/review/resources/${category.id}`)
}

function refreshRecommended() {
  // TODO: 刷新推荐资源
}

function openResource(resource: any) {
  // TODO: 打开资源
}

function downloadResource(resource: any) {
  showDownloadModal.value = true
  // TODO: 添加下载任务
}

function removeFromRecent(resource: any) {
  const index = recentResources.value.findIndex(r => r.id === resource.id)
  if (index > -1) {
    recentResources.value.splice(index, 1)
  }
}

function clearHistory() {
  recentResources.value = []
}

function cancelDownload(task: any) {
  // TODO: 取消下载
}

function deleteDownload(task: any) {
  const index = downloadTasks.value.findIndex(t => t.id === task.id)
  if (index > -1) {
    downloadTasks.value.splice(index, 1)
  }
}

function clearDownloads() {
  downloadTasks.value = []
}

function formatTime(timestamp: number) {
  const now = Date.now()
  const diff = now - timestamp
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  
  const date = new Date(timestamp)
  return `${date.getMonth() + 1}月${date.getDate()}日`
}
</script>

<style scoped lang="scss">
.resources {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

.card {
  margin-bottom: var(--spacing-base);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);

  h3 {
    margin: 0;
  }

  .view-mode {
    display: flex;
    gap: var(--spacing-small);
  }
}

// 分类列表
.category-list {
  display: grid;
  gap: var(--spacing-base);

  &.grid {
    grid-template-columns: repeat(2, 1fr);
    
    @media (min-width: 768px) {
      grid-template-columns: repeat(3, 1fr);
    }
  }

  &.list {
    grid-template-columns: 1fr;
  }
}

.category-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;
  }

  .category-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-base);
    display: flex;
    align-items: center;
    justify-content: center;

    .material-icons {
      color: white;
      font-size: 24px;
    }
  }

  .category-info {
    flex: 1;
  }

  .category-name {
    font-weight: 500;
    margin-bottom: 4px;
  }

  .category-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);

    .update {
      color: var(--color-primary);
    }
  }

  .offline-status {
    .material-icons {
      color: var(--color-text-secondary);

      &.downloaded {
        color: var(--color-primary);
      }
    }
  }
}

// 资源列表
.resource-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.resource-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;
  }

  .resource-preview {
    width: 80px;
    height: 80px;
    border-radius: var(--radius-small);
    overflow: hidden;
    position: relative;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .resource-type {
      position: absolute;
      top: 4px;
      right: 4px;
      padding: 2px 6px;
      border-radius: 10px;
      color: white;
      font-size: 0.8em;
    }
  }

  .resource-info {
    flex: 1;
  }

  .resource-title {
    margin-bottom: 4px;
  }

  .resource-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);
  }

  .download {
    color: var(--color-text-secondary);

    &.downloaded {
      color: var(--color-primary);
    }
  }
}

// 空状态
.empty-state {
  text-align: center;
  padding: var(--spacing-large) 0;
  color: var(--color-text-secondary);

  .material-icons {
    font-size: 48px;
    margin-bottom: var(--spacing-small);
  }

  p {
    margin: 0;
  }
}

// 模态框
.modal {
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
  width: 90%;
  max-width: 480px;
  margin: 0;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);

  h3 {
    margin: 0;
  }
}

.download-list {
  margin-bottom: var(--spacing-base);
}

.download-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-small);

  .task-info {
    flex: 1;
  }

  .task-name {
    margin-bottom: 4px;
  }

  .task-progress {
    position: relative;
    height: 4px;
    background: #e8e8e8;
    border-radius: 2px;
    overflow: hidden;

    .progress-bar {
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      background: var(--color-primary);
      transition: width 0.3s ease;
    }

    .progress-text {
      position: absolute;
      right: 0;
      top: -18px;
      font-size: 0.9em;
      color: var(--color-text-secondary);
    }
  }
}

.modal-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .storage-info {
    flex: 1;
    margin-right: var(--spacing-base);
  }

  .storage-text {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    margin-bottom: 4px;
  }

  .storage-bar {
    height: 4px;
    background: #e8e8e8;
    border-radius: 2px;
    overflow: hidden;

    .storage-used {
      height: 100%;
      background: var(--color-primary);
      transition: width 0.3s ease;
    }
  }

  .danger {
    color: #ff4d4f;
  }
}

// 适配大字体模式
:global(.large-text) {
  .category-name,
  .resource-title {
    font-size: 1.1em;
  }

  .category-meta,
  .resource-meta,
  .storage-text {
    font-size: 1em;
  }
}

:global(.xlarge-text) {
  .category-name,
  .resource-title {
    font-size: 1.2em;
  }

  .category-meta,
  .resource-meta,
  .storage-text {
    font-size: 1.1em;
  }
}
</style>
