<template>
  <div class="swot-analysis">
    <h4>📋 SWOT分析</h4>
    <div class="swot-grid">
      <div class="swot-item strengths">
        <h5>优势 (Strengths)</h5>
        <ul>
          <li v-for="(item, index) in strengths" :key="index">{{ item }}</li>
        </ul>
      </div>
      
      <div class="swot-item weaknesses">
        <h5>劣势 (Weaknesses)</h5>
        <ul>
          <li v-for="(item, index) in weaknesses" :key="index">{{ item }}</li>
        </ul>
      </div>
      
      <div class="swot-item opportunities">
        <h5>机会 (Opportunities)</h5>
        <ul>
          <li v-for="(item, index) in opportunities" :key="index">{{ item }}</li>
        </ul>
      </div>
      
      <div class="swot-item threats">
        <h5>威胁 (Threats)</h5>
        <ul>
          <li v-for="(item, index) in threats" :key="index">{{ item }}</li>
        </ul>
      </div>
    </div>
    
    <div class="recommendations">
      <h5>💡 政策优化建议</h5>
      <p>{{ recommendations }}</p>
      <p class="reference-note">
        参考《城乡规划》中"公共服务均等化"案例
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  strengths: string[];
  weaknesses: string[];
  opportunities: string[];
  threats: string[];
  recommendations: string;
}>();
</script>

<style scoped lang="scss">
.swot-analysis {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.swot-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.swot-item {
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  border-left: 4px solid;
  
  h5 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  ul {
    margin: 0;
    padding-left: var(--spacing-base);
    list-style: none;
    
    li {
      margin-bottom: var(--spacing-small);
      font-size: 13px;
      line-height: 1.6;
      color: var(--color-text-primary);
      position: relative;
      
      &::before {
        content: '•';
        position: absolute;
        left: -16px;
        color: inherit;
      }
    }
  }
  
  &.strengths {
    background: rgba(82, 196, 26, 0.1);
    border-left-color: #52c41a;
  }
  
  &.weaknesses {
    background: rgba(245, 108, 108, 0.1);
    border-left-color: #f56c6c;
  }
  
  &.opportunities {
    background: rgba(64, 158, 255, 0.1);
    border-left-color: #409eff;
  }
  
  &.threats {
    background: rgba(250, 173, 20, 0.1);
    border-left-color: #faad14;
  }
}

.recommendations {
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-primary);
  
  h5 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  p {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 13px;
    line-height: 1.8;
    color: var(--color-text-primary);
  }
  
  .reference-note {
    margin-top: var(--spacing-base);
    font-size: 12px;
    color: var(--color-text-secondary);
    font-style: italic;
  }
}
</style>


