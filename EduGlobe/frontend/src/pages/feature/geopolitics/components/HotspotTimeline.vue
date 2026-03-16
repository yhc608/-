<template>
  <div class="timeline-container">
    <h3>事件时间轴</h3>
    <div class="timeline">
      <div
        v-for="(event, index) in events"
        :key="index"
        class="timeline-item"
        :class="{ active: selectedIndex === index }"
        @click="selectEvent(index)"
      >
        <div class="timeline-dot"></div>
        <div class="timeline-content">
          <div class="timeline-date">{{ event.date }}</div>
          <div class="timeline-event">{{ event.event }}</div>
          <div class="timeline-description">{{ event.description }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface TimelineEvent {
  date: string
  event: string
  description: string
}

const props = defineProps<{
  events: TimelineEvent[]
}>()

const emit = defineEmits<{
  (e: 'select', event: TimelineEvent): void
}>()

const selectedIndex = ref<number | null>(null)

function selectEvent(index: number) {
  selectedIndex.value = index
  const event = props.events[index]
  emit('select', event)
  
  // 可以在这里加载对应时间点的地图状态或相关数据
  console.log('选择时间轴事件:', event)
  console.log('事件日期:', event.date)
  console.log('可以加载该时间点的地理要素变化数据')
}

watch(
  () => props.events,
  () => {
    selectedIndex.value = null
  }
)
</script>

<style scoped>
.timeline-container {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
}

.timeline-container h3 {
  margin: 0 0 var(--spacing-base) 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.timeline {
  position: relative;
  padding-left: var(--spacing-large);
}

.timeline::before {
  content: '';
  position: absolute;
  left: 8px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: var(--color-border);
}

.timeline-item {
  position: relative;
  margin-bottom: var(--spacing-large);
  cursor: pointer;
  transition: var(--transition-base);
}

.timeline-item:hover {
  transform: translateX(4px);
}

.timeline-item.active .timeline-dot {
  background: var(--color-primary);
  border-color: var(--color-primary);
  transform: scale(1.2);
}

.timeline-dot {
  position: absolute;
  left: -20px;
  top: 4px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--color-bg-secondary);
  border: 2px solid var(--color-border);
  transition: var(--transition-base);
}

.timeline-content {
  background: var(--color-bg-tertiary);
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-border);
  transition: var(--transition-base);
}

.timeline-item.active .timeline-content {
  border-left-color: var(--color-primary);
  background: var(--color-bg-secondary);
  box-shadow: var(--shadow-base);
}

.timeline-date {
  font-size: 12px;
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-small);
}

.timeline-event {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: var(--spacing-small);
}

.timeline-description {
  font-size: 13px;
  color: var(--color-text-secondary);
  line-height: 1.5;
}
</style>


