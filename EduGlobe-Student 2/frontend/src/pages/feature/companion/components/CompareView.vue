<template>
  <div class="compare">
    <section>
      <header>
        <h3>{{ teacherLabel }}</h3>
        <span class="tag">示范路径</span>
      </header>
      <MindTree :data="teacher" />
    </section>
    <section>
      <header>
        <h3>{{ studentLabel }}</h3>
        <span class="tag emphasis">你的路径</span>
      </header>
      <MindTree :data="student" highlight />
    </section>
  </div>
</template>

<script setup lang="ts">
import MindTree from './MindTree.vue';

defineProps<{
  teacher: any;
  student: any;
  teacherLabel?: string;
  studentLabel?: string;
}>();
</script>

<style scoped>
.compare {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
}
section {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  background: rgba(248, 250, 252, 0.92);
}
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
h3 {
  margin: 0;
}
.tag {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 999px;
  background: rgba(148, 163, 184, 0.22);
  color: #475569;
}
.tag.emphasis {
  background: rgba(56, 189, 248, 0.2);
  color: #0284c7;
}
</style>


