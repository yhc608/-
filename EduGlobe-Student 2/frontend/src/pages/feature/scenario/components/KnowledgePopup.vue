<template>
  <div class="popup" @click.self="emit('close')">
    <section>
      <header>
        <h3>知识提示</h3>
        <button class="close" @click="emit('close')">×</button>
      </header>
      <p>{{ content }}</p>
      <footer>
        <button class="cta" @click="emit('close')">继续探索</button>
      </footer>
    </section>
  </div>
</template>

<script setup lang="ts">
defineProps<{ content: string }>();
const emit = defineEmits<{ (e: 'close'): void }>();
</script>

<style scoped>
.popup {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20;
}
section {
  width: min(400px, 90vw);
  background: rgba(15, 23, 42, 0.92);
  color: #f8fafc;
  border-radius: 20px;
  padding: 20px;
  box-shadow: 0 20px 45px rgba(15, 23, 42, 0.45);
}
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
h3 {
  margin: 0;
  font-size: 18px;
}
.close {
  border: none;
  background: transparent;
  color: inherit;
  font-size: 20px;
  cursor: pointer;
}
p {
  line-height: 1.6;
  margin: 0 0 16px;
}
.cta {
  border: none;
  background: #38bdf8;
  color: #0f172a;
  padding: 8px 18px;
  border-radius: 999px;
  font-weight: 600;
  cursor: pointer;
}
</style>


