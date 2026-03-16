# 🧠 AI地理伴学模块功能开发指令（Cursor 专用）

> 本文档为 **EduGlobe-Student 项目（Vue3 + Vite + TypeScript + ECharts + Three.js）** 的子模块开发专用指令。  
> 目标：基于项目架构，生成完整的 “AI地理伴学（Companion）” 模块，包括页面、组件、mock 数据与交互逻辑。  
> 要求：代码清晰、注释详尽、交互流畅、可在 `npm run dev` 后直接体验完整功能。

---

## 🧭 一、功能定位与创新目标

### 🌍 模块定位
AI地理伴学模块突破传统“问答式AI”的局限，通过 **思维可视化 + 本地化资源融合 + 智能路径对比**，  
构建“课堂教学 → 学情分析 → 思维成长”的动态闭环系统，  
让地理学习从“会答题”进阶到“会思考、会迁移、会应用”。

### 💡 核心创新
| 功能机制 | 创新说明 |
|-----------|-----------|
| **动态资源校准系统** | 基于“教学进度 + 本地化数据”双维度动态匹配，生成精准教学资源与任务。 |
| **地理思维拆解引导** | 通过阶梯式设问体系引导学生构建解题逻辑链，而非直接输出答案。 |
| **思维路径对比系统** | 自动对比学生与名师的思维树结构，标注遗漏与逻辑断点，强化分析能力。 |
| **区域数据共创机制** | 允许教师与学生共同上传本地地理素材，构建跨区知识数据库。 |

---

## 🧩 二、项目结构扩展

```
src/pages/feature/companion/
 ├── index.vue          # 班级学情总览
 ├── question.vue       # 分层引导式答疑页（思维树生成）
 ├── compare.vue        # 名师与学生思维路径对比页
 ├── resource.vue       # 本地化地理资源展示页
 └── components/
     ├── ProgressRadar.vue      # 学情雷达图
     ├── MindTree.vue           # 学生思维树可视化
     ├── CompareView.vue        # 名师-学生思维对比
     ├── LocalDataPanel.vue     # 本地化数据面板
```

并在 `src/router/index.ts` 注册路由：
```ts
{ path: '/feature/companion', component: () => import('../pages/feature/companion/index.vue') },
```

---

## ⚙️ 三、功能模块详细规范

### 1️⃣ 动态资源校准系统（Dynamic Alignment）

**功能目标**  
实现“课堂进度 + 本地数据”的双维精准匹配，让资源自动跟随教学节奏与区域差异更新。

**交互逻辑**
- 读取教师上传的教学计划 JSON（如 `湘教版 必修一 第三章 第二课时`）。
- 通过知识图谱关联，动态生成当前课时的“知识链-知识面-知识空间”结构。
- 调用 `/mock/resources.json` 数据，按班级进度、地区标签生成推荐资源。
- 生成“进度匹配度、认知盲区、能力短板”三维可视化图谱。

**核心组件**
- `ProgressRadar.vue`  
  - ECharts 雷达图展示班级-个人学情  
  - 动态更新三项指标：`progressMatch`, `cognitiveGap`, `abilityTag`  
  - 鼠标悬停显示学生细节数据（tooltip）

---

### 2️⃣ 地理思维拆解工具（Guided Reasoning）

**功能目标**  
将“隐性思维”转化为“可视路径”，帮助学生形成严谨的地理分析逻辑。

**交互逻辑**
- 用户输入问题文本 → 系统识别问题类型（自然地理 / 人文地理 / 综合）；
- 依据地理分析框架（自然条件、经济条件、社会条件）自动生成阶梯式提问序列；
- 每个提问节点回答后生成思维树分支；
- 最终形成完整的学生“思维树”结构，可导出 JSON。

**核心组件**
- `MindTree.vue`  
  - 使用 ECharts Tree 展示学生思维路径；
  - 节点颜色区分思维深度；
  - 动态动画演示思考展开过程；
  - 支持“自动补全逻辑断点”提示。

---

### 3️⃣ 思维路径对比系统（Expert Compare）

**功能目标**  
可视化呈现学生与名师在分析逻辑、维度覆盖、考点关联上的差异。

**交互逻辑**
- 调用 `/mock/expert_mindtree.json` 获取名师标准思维树；
- 读取学生思维树；
- 对比层级结构并高亮缺失节点；
- 弹窗显示名师解析。

**核心组件**
- `CompareView.vue`  
  - 双栏视图：左为学生思维树，右为名师思维树；
  - 缺失节点绿色高亮；
  - 点击节点弹出详细名师解析与知识延伸链接。

---

### 4️⃣ 本地化地理资源融合系统（Local Data Fusion）

**功能目标**  
建立官方、跨区、师生共创的多维地理数据库，实现“知识与家乡结合”。

**交互逻辑**
- 从 `/mock/resources.json` 加载官方与本地资源；
- 支持学生上传图片、文字、地貌调查记录；
- 资源展示采用卡片+地图视图；
- 每月自动生成“区域地理数据报告”。

**核心组件**
- `LocalDataPanel.vue`  
  - 以卡片方式展示资源；
  - 可按地区、主题筛选；
  - 点击展开详细地理素材（图片 + 简述 + 来源）。

---

## 🧠 四、Mock 数据与接口规范

```
src/mock/
 ├── resources.json          # 本地与官方地理资源
 ├── mindtree_student.json   # 学生思维树结构
 ├── expert_mindtree.json    # 名师思维树标准
 ├── progress.json           # 班级学情与进度数据
```

**示例：`mindtree_student.json`**
```json
{
  "root": {
    "name": "热岛效应成因分析",
    "children": [
      { "name": "自然因素", "children": [{ "name": "气温升高" }, { "name": "下垫面特性" }] },
      { "name": "人为因素", "children": [{ "name": "建筑密集" }, { "name": "绿地减少" }] }
    ]
  }
}
```

**API 封装**
```ts
export async function getProgress(){ return fetch('/mock/progress.json').then(r=>r.json()) }
export async function getMindTree(){ return fetch('/mock/mindtree_student.json').then(r=>r.json()) }
export async function getExpertMindTree(){ return fetch('/mock/expert_mindtree.json').then(r=>r.json()) }
export async function getResources(){ return fetch('/mock/resources.json').then(r=>r.json()) }
```

---

## 🎨 五、UI 与技术实现标准

| 项目 | 标准说明 |
|------|-----------|
| **UI 风格** | 教育科技感、简洁高亮、信息图谱化布局 |
| **技术栈** | Vue3 + Vite + TypeScript + Tailwind + SCSS |
| **图表库** | ECharts（Tree / Radar / Map） |
| **动画框架** | Framer Motion（页面与组件切换动画） |
| **数据层** | Mock 数据驱动，可无后端运行 |
| **移动端适配** | Flex + vw 单位，支持竖屏交互 |
| **交互规范** | 每次点击、提交、变化均需动画反馈与过渡效果 |

---

## ✅ 六、开发输出要求

生成代码时，请确保：
1. 每个页面和组件包含完整结构与注释；
2. Mock 数据可直接演示功能；
3. 所有功能逻辑均可运行展示；
4. 路由与页面跳转完整；
5. 思维树、学情雷达、对比图表均可交互；
6. 页面默认加载示例数据（无需后端）。

---

## 🚀 七、Cursor Prompt 模板

> 请在现有 **EduGlobe-Student** 项目架构基础上，创建 `/feature/companion` 模块，  
> 按本文件规范生成以下页面与组件：
> - index.vue、question.vue、compare.vue、resource.vue  
> - ProgressRadar.vue、MindTree.vue、CompareView.vue、LocalDataPanel.vue  
>
> 并实现：
> - 动态资源校准系统  
> - 地理思维拆解引导  
> - 思维路径对比系统  
> - 本地资源融合展示  
>
> 要求：
> - 使用 Mock 数据驱动交互；
> - 所有页面含完整注释与可演示逻辑；
> - ECharts/Three.js/Tailwind 效果完整；
> - 可在 `npm run dev` 后直接体验完整流程；
> - 风格保持科技感与教育属性统一。

---

🧩 **完成后效果预期**  
- 首页展示学生与班级学习进度雷达图  
- 点击问题进入思维树答疑页  
- 可与名师思维树进行交互对比  
- 支持上传与展示本地地理素材  
- 全程动画流畅、数据响应即时  

---

✨ **文件保存名建议：**
```
AI地理伴学功能开发指令_Cursor版.md
```
