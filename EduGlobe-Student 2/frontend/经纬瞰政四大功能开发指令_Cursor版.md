# 经纬瞰政地理教学系统四大功能开发指令（Cursor专用）

> 本文档为 **Cursor AI 代码生成工具专用指令模板**，用于在现有 `EduGlobe-Student` 项目架构下，快速生成完整的四大地理功能模块代码。
> 生成目标包括前端页面、组件、接口、mock 数据、3D交互与知识图谱展示。

---

## 🧭 一、总体目标

在现有 **EduGlobe-Student（Vue3 + Vite + TypeScript + ECharts + Three.js）** 架构基础上，新增并实现以下四大模块：

1. 🌍 **经纬瞰政（Geopolitics）**：时政热点-地理知识关联模块  
2. 🧠 **AI地理伴学（Companion）**：智能学情与思维路径可视化系统  
3. 🔬 **赛博实验（CyberLab）**：虚拟地理实验平台  
4. 🎮 **情景互动（Scenario）**：沉浸式地理探索系统

所有模块统一在 `/feature/` 下创建，并通过路由注册。要求：
- 可独立运行、互相跳转；
- mock 数据可演示完整交互逻辑；
- 可扩展接入真实后端接口；
- 兼容移动端 H5 展示。

---

## 🧩 二、项目结构扩展

在 `src/pages/feature/` 下新增四个主模块：

```
src/pages/feature/
 ├── geopolitics/        # 经纬瞰政模块
 ├── companion/          # AI地理伴学模块
 ├── cyberlab/           # 赛博实验模块
 └── scenario/           # 情景互动模块
```

并在 `src/router/index.ts` 中新增路由：

```ts
{ path: '/feature/geopolitics', component: () => import('../pages/feature/geopolitics/index.vue') },
{ path: '/feature/companion', component: () => import('../pages/feature/companion/index.vue') },
{ path: '/feature/cyberlab', component: () => import('../pages/feature/cyberlab/index.vue') },
{ path: '/feature/scenario', component: () => import('../pages/feature/scenario/index.vue') },
```

---

## ⚙️ 三、功能模块详细规范

### 1️⃣ 经纬瞰政模块（Geopolitics）

**功能目标**  
通过“热点追踪 - 知识拆解 - 案例分析 - 教学包推送”实现地理与时政融合。

**页面结构**
```
pages/feature/geopolitics/
 ├── index.vue              # 热点总览页（地图 + 列表）
 ├── detail.vue             # 热点详情页（知识图谱 + 案例）
 ├── quiz.vue               # 闯关题模式
 ├── report.vue             # 自动报告页
```

**核心组件**
- `HotspotMap.vue`：ECharts 地图 + 热度叠加层  
- `KnowledgeGraph.vue`：知识图谱可视化（D3/ForceGraph）  
- `CaseCard.vue`：时政案例展示卡  
- `QuizPanel.vue`：题库闯关交互区  

**主要功能点**
- 从 `/mock/hotspots.json` 读取热点数据并渲染地图标注  
- 点击热点进入详情页 → 展示地理因素分析（地形、气候、资源）  
- 右侧加载知识图谱，显示教材关联章节  
- “闯关模式”答题后显示反馈与跳转教材页  
- 自动生成分析报告（导出 Markdown）  

---

### 2️⃣ AI地理伴学模块（Companion）

**功能目标**  
实现“动态资源校准 + 思维拆解答疑 + 名师思维对比”。

**页面结构**
```
pages/feature/companion/
 ├── index.vue          # 班级进度与学情总览
 ├── question.vue       # 引导式答疑页（思维树生成）
 ├── compare.vue        # 名师与学生思维路径对比
 ├── resource.vue       # 本地化地理资源展示
```

**核心组件**
- `ProgressRadar.vue`：班级-个人双维学情图谱  
- `MindTree.vue`：ECharts Tree 思维树可视化  
- `CompareView.vue`：思维路径对比界面  
- `LocalDataPanel.vue`：本地地理数据展示面板  

**主要功能点**
- 首页展示进度匹配度、认知盲区、能力短板  
- question.vue 提供层级式提问 → 动态生成学生思维树  
- compare.vue 加载名师标准树并高亮差异  
- resource.vue 展示区域生态、产业、本地地貌数据  

---

### 3️⃣ 赛博实验模块（CyberLab）

**功能目标**  
构建“虚拟实验 + 数据可视化分析”的交互系统，模拟地理现象。

**页面结构**
```
pages/feature/cyberlab/
 ├── index.vue           # 实验选择页
 ├── experiment.vue      # 实验主界面（3D场景 + 控制面板）
 ├── result.vue          # 实验结果可视化页
```

**核心组件**
- `ExperimentSelector.vue`：实验项目选择  
- `VariableControlPanel.vue`：左侧变量控制面板  
- `ExperimentScene.vue`：Three.js 实验模拟场景  
- `ResultChart.vue`：ECharts 数据可视化组件  

**主要功能点**
- 三类实验：水土流失 / 热力环流 / 大气保温  
- 可切换变量（温度、坡度、降水强度等）  
- 实验画面动态变化（流线、降雨、温度变化）  
- 实验数据实时显示 + 对比图表  
- 实验原理与科学解读弹窗  

---

### 4️⃣ 情景互动模块（Scenario）

**功能目标**  
打造“第一视角地理探索 + 任务驱动学习”系统。

**页面结构**
```
pages/feature/scenario/
 ├── index.vue             # 场景大厅
 ├── explore.vue           # 第一视角探索界面（Three.js）
 ├── task.vue              # 任务与成就系统
 ├── record.vue            # 探索日志与报告
```

**核心组件**
- `SceneMap.vue`：3D 场景选择器  
- `FirstPersonView.vue`：第一视角控制系统（WASD/摇杆）  
- `TaskPanel.vue`：任务进度与奖励系统  
- `KnowledgePopup.vue`：交互点知识弹窗  

**主要功能点**
- 支持行走、观察、工具、记录四类交互  
- 场景类型：火山喷发、季风环流、城市功能区  
- 每个交互点触发知识弹窗与任务评分  
- 可导出任务完成报告（JSON/Markdown）  

---

## 🧠 四、Mock 数据与接口规范

**Mock 数据文件结构：**
```
src/mock/
 ├── hotspots.json       # 经纬瞰政热点数据
 ├── experiments.json    # 实验配置参数
 ├── resources.json      # 本地资源与知识映射
 └── tasks.json          # 探索任务定义
```

**API 封装（`src/services/api.ts`）**
```ts
export async function getHotspots(){ return fetch('/mock/hotspots.json').then(r=>r.json()) }
export async function getExperiments(){ return fetch('/mock/experiments.json').then(r=>r.json()) }
export async function getTasks(){ return fetch('/mock/tasks.json').then(r=>r.json()) }
```

---

## 🎨 五、UI与交互标准

- **技术栈**：Vue3 + Vite + TypeScript + Tailwind + SCSS  
- **动画**：Framer Motion（场景切换与图表更新动画）  
- **图表库**：ECharts  
- **3D引擎**：Three.js  
- **视觉风格**：信息可视化+教育科技感  
- **移动端适配**：flex 布局 + vw 单位  
- **交互规范**：所有点击、变量变化需动画反馈。  

---

## 🧰 六、开发输出要求

Cursor 生成代码时应包含：  
1. 每个模块的完整文件夹结构；  
2. `.vue` 页面与核心组件文件；  
3. Mock 数据 JSON；  
4. 在 `router/index.ts` 注册路由；  
5. 完整注释与可运行逻辑；  
6. 各模块页面默认可演示完整交互流程（无需后端）。

---

## ✅ 七、Prompt 模板（复制给 Cursor）

> 请在现有 EduGlobe-Student 项目架构基础上，创建 `/feature/` 下四大模块：
> - 经纬瞰政（geopolitics）
> - AI地理伴学（companion）
> - 赛博实验（cyberlab）
> - 情景互动（scenario）
>
> 按本文件中详细规范实现页面、组件、接口与 mock 数据。要求：  
> - 结构清晰、注释完整；  
> - 动态数据使用 mock 文件；  
> - 支持移动端展示；  
> - ECharts、Three.js、Tailwind 效果完整；  
> - 可在 `npm run dev` 后直接预览全部功能。
