<template>
  <div class="geopolitics-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>🌍 经纬瞰政 · 热点总览</h2>
      <div class="header-actions">
        <button class="link" @click="$router.push('/feature/geopolitics/quiz')">闯关模式</button>
        <button class="link" @click="$router.push('/feature/geopolitics/report')">查看报告</button>
      </div>
    </header>
    
    <section class="main-content">
      <div class="map-section">
        <div class="section-title">
          <h3>热点地图</h3>
          <p class="section-desc">点击地图上的热点标记查看详情</p>
        </div>
        <HotspotMap :items="hotspots" @select="goDetail" />
      </div>
      
      <div class="list-section">
        <div class="section-title">
          <h3>热点列表</h3>
          <p class="section-desc">按热度排序</p>
        </div>
        <div class="hotspot-list">
          <div 
            v-for="h in sortedHotspots" 
            :key="h.id" 
            class="hotspot-item"
            @click="goDetail(h.id)"
          >
            <div class="hotspot-header">
              <strong class="hotspot-title">{{ h.title || h.name }}</strong>
              <span class="heat-badge" :class="getHeatClass(h.heat)">热度 {{ h.heat }}</span>
            </div>
            <div class="hotspot-meta">
              <span class="category">{{ h.category || '时政热点' }}</span>
              <span class="related-count">{{ (h.relatedKnowledge || []).length }} 个知识点</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue';
import HotspotMap from './components/HotspotMap.vue';
import { getHotspots } from '../../../services/api';

type Hotspot = {
  id: string; 
  title: string; 
  name?: string;
  lat: number; 
  lng: number; 
  heat: number;
  category?: string;
  relatedKnowledge?: string[];
};

const hotspots = ref<Hotspot[]>([]);

// 按热度排序的热点列表
const sortedHotspots = computed(() => {
  return [...hotspots.value].sort((a, b) => b.heat - a.heat);
});

onMounted(async () => {
  try {
    const data = await getHotspots();
    // 优先使用hotspots数组，如果没有则使用items
    hotspots.value = (data.hotspots || data.items || []).map((item: any) => ({
      id: item.id,
      title: item.title || item.name,
      name: item.name,
      lat: item.lat,
      lng: item.lng,
      heat: item.heat || 0,
      category: item.category,
      relatedKnowledge: item.relatedKnowledge || []
    }));
  } catch (error) {
    console.error('加载热点数据失败:', error);
    hotspots.value = [];
  }
});

function goDetail(id: string) {
  // 携带 id 进入详情
  history.pushState({}, '', `/feature/geopolitics/detail?id=${encodeURIComponent(id)}`);
  window.dispatchEvent(new PopStateEvent('popstate')); // 触发路由
}

function getHeatClass(heat: number): string {
  if (heat >= 90) return 'heat-high';
  if (heat >= 70) return 'heat-medium';
  return 'heat-low';
}
</script>

<style scoped lang="scss">
.geopolitics-page {
  padding: var(--spacing-base);
  min-height: 100vh;
  background: linear-gradient(135deg, var(--color-bg-primary) 0%, #E8F4EA 100%);
}

.feature-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  box-shadow: var(--shadow-base);
  
  h2 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
    color: var(--color-text-primary);
    flex: 1;
    text-align: center;
  }
}

.header-actions {
  display: flex;
  gap: var(--spacing-small);
}

.link {
  padding: var(--spacing-small) var(--spacing-base);
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  font-size: 14px;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-primary-dark);
    transform: translateY(-1px);
  }
}

.main-content {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: var(--spacing-base);
  
  @media (max-width: 1024px) {
    grid-template-columns: 1fr;
  }
}

.map-section,
.list-section {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
}

.section-title {
  margin-bottom: var(--spacing-base);
  
  h3 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 18px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  .section-desc {
    margin: 0;
    font-size: 12px;
    color: var(--color-text-secondary);
  }
}

.hotspot-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.hotspot-item {
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-bg-secondary);
    border-color: var(--color-primary);
    transform: translateY(-2px);
    box-shadow: var(--shadow-base);
  }
}

.hotspot-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-small);
}

.hotspot-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
  flex: 1;
}

.heat-badge {
  padding: 4px var(--spacing-small);
  border-radius: var(--radius-small);
  font-size: 12px;
  font-weight: 600;
  
  &.heat-high {
    background: rgba(245, 108, 108, 0.2);
    color: #f56c6c;
  }
  
  &.heat-medium {
    background: rgba(250, 173, 20, 0.2);
    color: #faad14;
  }
  
  &.heat-low {
    background: rgba(82, 196, 26, 0.2);
    color: #52c41a;
  }
}

.hotspot-meta {
  display: flex;
  gap: var(--spacing-base);
  font-size: 12px;
  color: var(--color-text-secondary);
  
  .category {
    padding: 2px var(--spacing-small);
    background: rgba(64, 158, 255, 0.1);
    color: #409eff;
    border-radius: var(--radius-small);
  }
  
  .related-count {
    color: var(--color-text-secondary);
  }
}

@media (max-width: 768px) {
  .main-content {
    grid-template-columns: 1fr;
  }
  
  .feature-header {
    flex-direction: column;
    gap: var(--spacing-small);
    
    h2 {
      text-align: left;
    }
    
    .header-actions {
      width: 100%;
      justify-content: space-around;
    }
  }
}
</style>


