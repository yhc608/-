<template>
  <div class="panel">
    <header>
      <h3>{{ data.region }}</h3>
      <span class="tag">本地画像</span>
    </header>
    <section>
      <h4>生态特征</h4>
      <ul>
        <li v-for="item in data.ecology" :key="`eco-${item}`">· {{ item }}</li>
      </ul>
    </section>
    <section>
      <h4>核心产业</h4>
      <ul>
        <li v-for="item in data.industry" :key="`ind-${item}`">· {{ item }}</li>
      </ul>
    </section>
    <section>
      <h4>典型地貌</h4>
      <ul>
        <li v-for="item in data.landform" :key="`land-${item}`">· {{ item }}</li>
      </ul>
    </section>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  data: {
    region: string;
    ecology: string[];
    industry: string[];
    landform: string[];
  };
}>();
</script>

<style scoped>
.panel {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 16px;
  background: rgba(248, 250, 252, 0.95);
  display: flex;
  flex-direction: column;
  gap: 12px;
}
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
header h3 {
  margin: 0;
}
.tag {
  font-size: 12px;
  background: rgba(56, 189, 248, 0.2);
  color: #0284c7;
  padding: 4px 10px;
  border-radius: 999px;
}
section {
  border-radius: 12px;
  padding: 12px;
  background: rgba(148, 163, 184, 0.12);
}
h4 {
  margin: 0 0 8px;
  font-size: 14px;
  color: #0f172a;
}
ul {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: #475569;
}
</style>


