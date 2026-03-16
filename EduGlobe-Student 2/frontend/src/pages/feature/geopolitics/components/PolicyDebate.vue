<template>
  <div class="policy-debate">
    <h4>💬 政策辩论场</h4>
    <p class="description">基于区域协调发展理论，提出折中方案</p>
    
    <div class="debate-content">
      <div class="debate-side pros">
        <div class="side-header">
          <span class="side-icon">✓</span>
          <h5>正方观点</h5>
        </div>
        <p class="side-content">{{ pros }}</p>
      </div>
      
      <div class="debate-side cons">
        <div class="side-header">
          <span class="side-icon">✗</span>
          <h5>反方观点</h5>
        </div>
        <p class="side-content">{{ cons }}</p>
      </div>
    </div>
    
    <div class="solution-section">
      <h5>折中方案</h5>
      <div class="solution-input">
        <textarea 
          v-model="userSolution"
          placeholder="请基于区域协调发展理论提出您的折中方案..."
          rows="4"
        ></textarea>
        <button class="submit-btn" @click="submitSolution">提交方案</button>
      </div>
      <div v-if="showSolution" class="reference-solution">
        <h6>参考方案：</h6>
        <p>{{ solution }}</p>
        <p class="solution-note">
          💡 参考《人文地理·区域协调发展》中"建立钢铁产业绿色转型示范区"的实践案例
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const props = defineProps<{
  pros: string;
  cons: string;
  solution: string;
}>();

const userSolution = ref('');
const showSolution = ref(false);

function submitSolution() {
  if (!userSolution.value.trim()) {
    alert('请输入您的方案');
    return;
  }
  showSolution.value = true;
}
</script>

<style scoped lang="scss">
.policy-debate {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  .description {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 12px;
    color: var(--color-text-secondary);
  }
}

.debate-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.debate-side {
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  border-left: 4px solid;
  
  &.pros {
    background: rgba(82, 196, 26, 0.1);
    border-left-color: #52c41a;
  }
  
  &.cons {
    background: rgba(245, 108, 108, 0.1);
    border-left-color: #f56c6c;
  }
}

.side-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-base);
  
  .side-icon {
    font-size: 20px;
    font-weight: bold;
  }
  
  h5 {
    margin: 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.side-content {
  margin: 0;
  font-size: 13px;
  line-height: 1.6;
  color: var(--color-text-primary);
}

.solution-section {
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  
  h5 {
    margin: 0 0 var(--spacing-base) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.solution-input {
  margin-bottom: var(--spacing-base);
  
  textarea {
    width: 100%;
    padding: var(--spacing-base);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    font-size: 13px;
    font-family: inherit;
    resize: vertical;
    margin-bottom: var(--spacing-base);
    
    &:focus {
      outline: none;
      border-color: var(--color-primary);
    }
  }
}

.submit-btn {
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
  }
}

.reference-solution {
  padding: var(--spacing-base);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-primary);
  
  h6 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 13px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  p {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 13px;
    line-height: 1.6;
    color: var(--color-text-primary);
  }
  
  .solution-note {
    margin-top: var(--spacing-base);
    font-size: 12px;
    color: var(--color-text-secondary);
    font-style: italic;
  }
}
</style>


