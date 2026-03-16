<template>
  <div class="case-card">
    <div class="case-header">
      <span class="case-icon">📋</span>
      <h4>{{ item.title }}</h4>
    </div>
    <p class="case-summary">{{ item.summary }}</p>
  </div>
</template>

<script setup lang="ts">
defineProps<{ item: { id: string; title: string; summary: string } }>();
</script>

<style scoped lang="scss">
.case-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  transition: var(--transition-base);
  border-left: 3px solid var(--color-primary);
  
  &:hover {
    background: var(--color-bg-secondary);
    border-color: var(--color-primary);
    transform: translateY(-2px);
    box-shadow: var(--shadow-base);
  }
}

.case-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-small);
  
  .case-icon {
    font-size: 18px;
  }
  
  h4 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
    flex: 1;
  }
}

.case-summary {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}
</style>


