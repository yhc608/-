<template>
  <div class="book-link-panel">
    <h3>📚 教材关联</h3>
    <div class="links-list">
      <div
        v-for="(link, index) in links"
        :key="index"
        class="link-item"
        @click="goToTextbook(link)"
      >
        <div class="link-info">
          <span class="link-chapter">{{ link.chapter }}</span>
          <span class="link-section">{{ link.section }}</span>
        </div>
        <div class="link-meta">
          <span class="link-page">P{{ link.page }}</span>
          <span class="link-icon">→</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface TextbookLink {
  chapter: string
  section: string
  page: number
}

const props = defineProps<{
  links: TextbookLink[]
}>()

const emit = defineEmits<{
  (e: 'jump', link: TextbookLink): void
}>()

function goToTextbook(link: TextbookLink) {
  // 这里可以跳转到电子教材页面
  emit('jump', link)
  
  // 显示教材内容预览（实际项目中可以打开电子教材或跳转到对应页面）
  const previewContent = `
📚 教材章节：${link.chapter}
📖 章节内容：${link.section}
📄 页码：第 ${link.page} 页

【重点段落标注】
• 该知识点与当前热点事件密切相关
• 建议重点理解：${link.section}的核心概念
• 课后习题：请完成第 ${link.page} 页的练习题

【知识关联】
• 与当前热点案例的关联点已标注
• 建议结合时政案例理解理论内容
  `.trim()
  
  // 可以在这里实现实际的教材跳转逻辑
  console.log('跳转到教材:', link)
  console.log('预览内容:', previewContent)
}
</script>

<style scoped>
.book-link-panel {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
}

.book-link-panel h3 {
  margin: 0 0 var(--spacing-base) 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.links-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.link-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: var(--transition-base);
  border-left: 3px solid var(--color-border);
}

.link-item:hover {
  background: var(--color-bg-secondary);
  border-left-color: var(--color-primary);
  transform: translateX(4px);
  box-shadow: var(--shadow-base);
}

.link-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.link-chapter {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.link-section {
  font-size: 12px;
  color: var(--color-text-secondary);
}

.link-meta {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
}

.link-page {
  font-size: 13px;
  color: var(--color-primary);
  font-weight: 500;
}

.link-icon {
  font-size: 16px;
  color: var(--color-text-secondary);
}
</style>

