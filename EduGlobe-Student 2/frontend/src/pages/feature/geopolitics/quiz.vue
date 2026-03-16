<template>
  <div class="quiz-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>🎯 经纬瞰政 · 闯关答题</h2>
      <div class="progress-info">
        <span>第 {{ idx + 1 }} / {{ questions.length }} 题</span>
        <span class="score">正确率：{{ accuracy }}%</span>
      </div>
    </header>
    
    <section class="quiz-content" v-if="current">
      <div class="question-card">
        <div class="question-header">
          <span class="question-type">{{ current.type === 'single' ? '单选题' : '判断题' }}</span>
          <span class="question-number">题目 {{ idx + 1 }}</span>
        </div>
        
        <p class="stem">{{ current.stem }}</p>
        
        <div v-if="current.type==='single'" class="options-list">
          <label 
            v-for="(opt,i) in current.options" 
            :key="i" 
            class="option-item"
            :class="{ selected: choice === i, correct: submitted && i === current.answer, wrong: submitted && choice === i && choice !== current.answer }"
          >
            <input 
              type="radio" 
              name="opt" 
              :value="i" 
              v-model="choice"
              :disabled="submitted"
            />
            <span class="option-label">{{ String.fromCharCode(65 + i) }}. {{ opt }}</span>
          </label>
        </div>
        
        <!-- 知识点匹配题 -->
        <div v-if="current.type==='match'" class="match-section">
          <p class="match-instruction">请将以下知识点与案例进行匹配（可多选）：</p>
          <div class="knowledge-items">
            <div 
              v-for="(knowledge, idx) in current.knowledgeItems" 
              :key="idx"
              class="knowledge-item"
              :class="{ selected: selectedKnowledge.includes(idx) }"
              @click="toggleKnowledge(idx)"
            >
              <input 
                type="checkbox" 
                :value="idx"
                v-model="selectedKnowledge"
                :disabled="submitted"
              />
              <span>{{ knowledge }}</span>
            </div>
          </div>
          <div class="match-result" v-if="submitted">
            <p class="result-text" :class="matchResult.correct ? 'correct' : 'wrong'">
              {{ matchResult.correct ? '✓ 匹配正确！' : '✗ 匹配不完整' }}
            </p>
            <p class="result-detail">{{ matchResult.message }}</p>
          </div>
        </div>
        
        <div v-else-if="current.type==='truefalse'" class="tf-options">
          <button 
            :class="{active: choice===1, correct: submitted && current.answer===1, wrong: submitted && choice===1 && choice!==current.answer}"
            @click="choice=1"
            :disabled="submitted"
          >
            ✓ 正确
          </button>
          <button 
            :class="{active: choice===0, correct: submitted && current.answer===0, wrong: submitted && choice===0 && choice!==current.answer}"
            @click="choice=0"
            :disabled="submitted"
          >
            ✗ 错误
          </button>
        </div>
        
        <div class="feedback-section" v-if="feedback">
          <div class="feedback-card" :class="feedbackType">
            <span class="feedback-icon">{{ feedbackType === 'correct' ? '✓' : '✗' }}</span>
            <div class="feedback-content">
              <p class="feedback-text">{{ feedback }}</p>
              <p v-if="current.explain" class="feedback-explain">{{ current.explain }}</p>
            </div>
          </div>
        </div>
        
        <div class="actions">
          <button 
            class="btn-submit" 
            @click="submit"
            :disabled="(current.type !== 'match' && choice===null) || (current.type === 'match' && selectedKnowledge.length === 0) || submitted"
          >
            {{ submitted ? '已提交' : '提交答案' }}
          </button>
          <button 
            class="btn-next" 
            @click="next"
            :disabled="!submitted"
          >
            下一题
          </button>
        </div>
      </div>
    </section>
    
    <div v-else class="empty-state">
      <p>暂无题目</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue';
import { getHotspots } from '../../../services/api';

type Q = { 
  id: string; 
  type: 'single' | 'truefalse' | 'match'; 
  stem: string; 
  options?: string[]; 
  answer: number | number[]; 
  explain: string;
  knowledgeItems?: string[];
  requiredMatches?: number;
};

const questions = ref<Q[]>([]);
const idx = ref(0);
const choice = ref<number | null>(null);
const selectedKnowledge = ref<number[]>([]);
const feedback = ref('');
const submitted = ref(false);
const correctCount = ref(0);
const answeredCount = ref(0);
const matchResult = ref<{ correct: boolean; message: string }>({ correct: false, message: '' });

const current = computed(() => questions.value[idx.value]);

const accuracy = computed(() => {
  if (answeredCount.value === 0) return 0;
  return Math.round((correctCount.value / answeredCount.value) * 100);
});

const feedbackType = computed(() => {
  if (!feedback.value) return '';
  return feedback.value.includes('正确') ? 'correct' : 'wrong';
});

onMounted(async () => {
  try {
    const data = await getHotspots();
    questions.value = (data.quiz || []) as Q[];
  } catch (error) {
    console.error('加载题目失败:', error);
    questions.value = [];
  }
});

function submit() {
  if (!current.value || submitted.value) return;
  
  // 检查是否已选择答案
  if (current.value.type === 'match') {
    if (selectedKnowledge.value.length === 0) {
      alert('请至少选择一个知识点');
      return;
    }
  } else {
    if (choice.value === null) {
      alert('请选择一个答案');
      return;
    }
  }
  
  submitted.value = true;
  answeredCount.value++;
  
  let ok = false;
  
  if (current.value.type === 'match') {
    // 知识点匹配题：检查是否匹配了足够的知识点
    const requiredMatches = current.value.requiredMatches || 3;
    const correctAnswers = Array.isArray(current.value.answer) 
      ? current.value.answer 
      : [current.value.answer];
    
    const selectedSet = new Set(selectedKnowledge.value.sort());
    const correctSet = new Set(correctAnswers.sort());
    
    // 检查是否完全匹配
    const isExactMatch = selectedSet.size === correctSet.size && 
      [...selectedSet].every(v => correctSet.has(v));
    
    ok = isExactMatch && selectedKnowledge.value.length >= requiredMatches;
    
    if (ok) {
      correctCount.value++;
      matchResult.value = {
        correct: true,
        message: `正确匹配了 ${selectedKnowledge.value.length} 个知识点！`
      };
      feedback.value = '匹配正确！';
    } else {
      matchResult.value = {
        correct: false,
        message: `需要匹配至少 ${requiredMatches} 个知识点，当前匹配了 ${selectedKnowledge.value.length} 个。正确答案：${correctAnswers.map(i => current.value?.knowledgeItems?.[i]).join('、')}`
      };
      feedback.value = '匹配不完整';
    }
  } else {
    // 单选题或判断题
    ok = choice.value === current.value.answer;
    if (ok) {
      correctCount.value++;
      feedback.value = '回答正确！';
      
      // 如果题目有教材链接，显示跳转提示
      if ((current.value as any).textbookLink) {
        const link = (current.value as any).textbookLink;
        setTimeout(() => {
          if (confirm(`回答正确！是否跳转到教材章节：${link.chapter} - ${link.section}？`)) {
            handleTextbookJump(link);
          }
        }, 500);
      }
    } else {
      feedback.value = '回答错误';
    }
  }
}

function handleTextbookJump(link: any) {
  // 跳转到教材章节
  console.log('跳转到教材:', link);
  alert(`跳转到教材：${link.chapter}\n章节：${link.section}\n页码：第${link.page}页\n重点标注：${link.highlight || ''}`);
}

function toggleKnowledge(idx: number) {
  if (submitted.value) return;
  const index = selectedKnowledge.value.indexOf(idx);
  if (index > -1) {
    selectedKnowledge.value.splice(index, 1);
  } else {
    selectedKnowledge.value.push(idx);
  }
}

function next() {
  if (!submitted.value) return;
  
  feedback.value = '';
  choice.value = null;
  selectedKnowledge.value = [];
  submitted.value = false;
  matchResult.value = { correct: false, message: '' };
  
  if (idx.value < questions.value.length - 1) {
    idx.value++;
  } else {
    // 所有题目完成，可以跳转到报告页
    if (confirm('所有题目已完成！是否查看报告？')) {
      history.pushState({}, '', '/feature/geopolitics/report');
      window.dispatchEvent(new PopStateEvent('popstate'));
    } else {
      idx.value = 0; // 重新开始
    }
  }
}
</script>

<style scoped lang="scss">
.quiz-page {
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

.progress-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
  font-size: 12px;
  color: var(--color-text-secondary);
  
  .score {
    font-weight: 600;
    color: var(--color-primary);
  }
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

.quiz-content {
  max-width: 800px;
  margin: 0 auto;
}

.question-card {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-large);
  box-shadow: var(--shadow-base);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);
  padding-bottom: var(--spacing-base);
  border-bottom: 2px solid var(--color-border);
  
  .question-type {
    padding: 4px var(--spacing-small);
    background: var(--color-primary);
    color: white;
    border-radius: var(--radius-small);
    font-size: 12px;
    font-weight: 600;
  }
  
  .question-number {
    font-size: 14px;
    color: var(--color-text-secondary);
  }
}

.stem {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-large) 0;
  line-height: 1.6;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
}

.option-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover:not(:disabled) {
    background: var(--color-bg-secondary);
    border-color: var(--color-primary);
  }
  
  &.selected {
    border-color: var(--color-primary);
    background: rgba(123, 107, 82, 0.1);
  }
  
  &.correct {
    border-color: #52c41a;
    background: rgba(82, 196, 26, 0.1);
  }
  
  &.wrong {
    border-color: #f56c6c;
    background: rgba(245, 108, 108, 0.1);
  }
  
  input[type="radio"] {
    cursor: pointer;
  }
  
  .option-label {
    flex: 1;
    font-size: 16px;
    color: var(--color-text-primary);
  }
}

.tf-options {
  display: flex;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
  
  button {
    flex: 1;
    padding: var(--spacing-base) var(--spacing-large);
    border: 2px solid var(--color-border);
    border-radius: var(--radius-base);
    background: var(--color-bg-tertiary);
    color: var(--color-text-primary);
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition-base);
    
    &:hover:not(:disabled) {
      background: var(--color-bg-secondary);
      border-color: var(--color-primary);
    }
    
    &.active {
      background: var(--color-primary);
      color: white;
      border-color: var(--color-primary);
    }
    
    &.correct {
      background: #52c41a;
      color: white;
      border-color: #52c41a;
    }
    
    &.wrong {
      background: #f56c6c;
      color: white;
      border-color: #f56c6c;
    }
    
    &:disabled {
      cursor: not-allowed;
      opacity: 0.7;
    }
  }
}

.feedback-section {
  margin: var(--spacing-large) 0;
}

.feedback-card {
  display: flex;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  border-left: 4px solid;
  
  &.correct {
    background: rgba(82, 196, 26, 0.1);
    border-left-color: #52c41a;
  }
  
  &.wrong {
    background: rgba(245, 108, 108, 0.1);
    border-left-color: #f56c6c;
  }
  
  .feedback-icon {
    font-size: 24px;
    font-weight: bold;
    flex-shrink: 0;
  }
  
  .feedback-content {
    flex: 1;
  }
  
  .feedback-text {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  .feedback-explain {
    margin: 0;
    font-size: 14px;
    color: var(--color-text-secondary);
    line-height: 1.6;
  }
}

.actions {
  display: flex;
  gap: var(--spacing-base);
  margin-top: var(--spacing-large);
}

.btn-submit,
.btn-next {
  flex: 1;
  padding: var(--spacing-base) var(--spacing-large);
  border: none;
  border-radius: var(--radius-base);
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition-base);
  
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.btn-submit {
  background: var(--color-primary);
  color: white;
  
  &:hover:not(:disabled) {
    background: var(--color-primary-dark);
    transform: translateY(-1px);
  }
}

.btn-next {
  background: #52c41a;
  color: white;
  
  &:hover:not(:disabled) {
    background: #73d13d;
    transform: translateY(-1px);
  }
}

.empty-state {
  text-align: center;
  padding: var(--spacing-xlarge);
  color: var(--color-text-secondary);
}

@media (max-width: 768px) {
  .feature-header {
    flex-direction: column;
    gap: var(--spacing-small);
    
    h2 {
      text-align: left;
    }
    
    .progress-info {
      align-items: flex-start;
    }
  }
  
  .question-card {
    padding: var(--spacing-base);
  }
  
  .tf-options {
    flex-direction: column;
  }
}

.match-section {
  margin-bottom: var(--spacing-large);
}

.match-instruction {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-base);
}

.knowledge-items {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
}

.knowledge-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover:not(:disabled) {
    background: var(--color-bg-secondary);
    border-color: var(--color-primary);
  }
  
  &.selected {
    border-color: var(--color-primary);
    background: rgba(123, 107, 82, 0.1);
  }
  
  input[type="checkbox"] {
    cursor: pointer;
  }
  
  span {
    flex: 1;
    font-size: 14px;
    color: var(--color-text-primary);
  }
}

.match-result {
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  margin-top: var(--spacing-base);
  
  .result-text {
    font-size: 16px;
    font-weight: 600;
    margin: 0 0 var(--spacing-small) 0;
    
    &.correct {
      color: #52c41a;
    }
    
    &.wrong {
      color: #f56c6c;
    }
  }
  
  .result-detail {
    margin: 0;
    font-size: 14px;
    color: var(--color-text-secondary);
    line-height: 1.6;
  }
}
</style>


