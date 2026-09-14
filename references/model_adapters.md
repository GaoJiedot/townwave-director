# 模型适配层 · 适配器注册表（references/model_adapters.md）

> 作用：本 skill 以**规范形式（canonical）**撰写提示词（两区制 + 首尾帧 + 负向约束），生成时按 `bible.img_model` / `bible.vid_model` 选对应适配器，翻译成该模型语法/参数。**同一份资产，换模型只换适配，不改真相源。**

---

## A. 两类模型（决定"描写放哪"）

| 类型 | 含义 | 描写如何处理 | 代表模型 |
|---|---|---|---|
| **R 类（参考图/首尾帧）** | 支持传入定稿图/首末帧 | 描写由**定稿图锚定**，提示词只写镜头语言（引用区粘贴 ID 即可） | Seedance、可灵、Runway、MiniMax H3、即梦、WorkBuddy VideoGen/ImageGen |
| **T 类（纯文字）** | 只接受文字、无图输入 | 必须把 bible 锁定块**原样内联成文字**进提示词（仍是 bible 来的，非 AI 现编） | Sora(纯文字模式)、部分文本生图 |

> **关键**：无论 R 类还是 T 类，"描写来自 bible、AI 不现编"这条铁律不变。差别只是描写**物理位置**（引用区/定稿图锚 vs 内联文字）。机制 5 自检对两者都生效。

---

## B. 规范形式（canonical）字段

适配器消费的统一输入：

```
CANON = {
  style_prefix,                       # 契约A
  ref_zone: {char_locked, scene_locked, prop_locked},  # 从 bible 原样取
  shot: {size, camera, movement, duration, action, sound, continuity},
  first_frame: <定稿图URL或"无">,
  last_frame: <目标图URL或"无">,
  negatives: [list],                 # 继承角色/场景引擎绝对禁令
  params: {aspect, resolution, fps, duration_sec, seed, ...}
}
```

---

## C. 适配器注册表

> 参数语法以各模型**当前官方文档**为准；下表为可用起点模板。未登记模型 → 按 CANON 输出 + 标注"需手动转写"，并回填本表。

### 🖼 图片模型

> **用户默认图片模型（高频）**：`nanobanana`（Gemini 2.5 Flash Image）+ `gpt-image`（别名 image2）。模块②候选优先给这两个。

| id | 标签 | 类型 | 提示词包裹 | 负向写法 | 参数 | 能力/坑 |
|---|---|---|---|---|---|---|
| `nanobanana` | Gemini 2.5 Flash Image（nano banana） | R/T | `style_prefix + 引用区/内联 + 镜头语言`（可附参考图做一致/编辑） | 句中"避免…/不要…" | 比例/尺寸；支持参考图 | 角色一致性好（给参考图）；理解力强；注意 SynthID 水印；偶发过度光滑 |
| `gpt-image` | GPT-Image（别名 image2） | R/T | 自然语言 + 可附参考图（多图参考） | 句中"避免…" | 尺寸/质量 | 理解力强、中文 OK；可多图参考 |
| `workbuddy-imagen` | WorkBuddy 生图 | R | `style_prefix + 引用区/内联 + 镜头语言` | 文末加"禁止：…" | 尺寸/比例 | 本地默认，自然语言 |
| `midjourney` | Midjourney | T | `prompt --ar 比例 --style raw --no 负向词` | `--no ugly, extra` | `--ar`,`--style`,`--v`,`--seed` | 负向走 `--no`；比例必带 |
| `flux-sd` | Flux / SD | T | 正向提示词（另附负向框） | 独立负向框 | steps/cfg/seed/尺寸 | 正负面分离；中英混写稳 |
| `jimeng-image` | 即梦生图 | R | `style_prefix + 描写 + 镜头` | 文末"不要…" | 比例/尺寸 | 中文友好，可参考图 |

### 🎬 视频模型

| id | 标签 | 类型 | 首/尾帧 | 提示词包裹 | 参数 | 能力/坑 |
|---|---|---|---|---|---|---|
| `minimax-h3` | MiniMax H3 | R | 支持首帧/参考图 | `style_prefix + 镜头语言 + 首帧图` | 时长/比例/运镜词 | 电影感强，用户《结婚照》指定；运镜词直接写 |
| `seedance` | Seedance | R | ✅首末帧+音频参考 | `首帧/末帧 + 镜头语言`，对白镜传音频做口型同步 | 时长/比例/fps | 首尾帧最大连续；音频驱动口型 |
| `kling` | 可灵 | R | ✅参考图+尾帧+运动笔刷 | `参考图 + 镜头语言 + 尾帧` | 时长/比例/运动笔刷/运镜 | 运动笔刷控局部；尾帧锁构图 |
| `runway` | Runway Gen-4 | R | ✅首末帧+运动笔刷 | `首末帧 + 镜头语言 + 镜头运动(pan/zoom)` | 时长/比例/运动笔刷 | 镜头运动指令强 |
| `sora` | Sora | T/R | 支持图输入 | `自然语言长提示词`（纯文字模式需内联描写） | 时长/比例 | 理解复杂语义；纯文字须内联 bible 锁定块 |
| `jimeng-video` | 即梦视频 | R | 支持首帧 | `首帧 + 镜头语言` | 时长/比例 | 中文友好 |
| `workbuddy-videogen` | WorkBuddy 视频 | R | 支持首尾帧 | `首末帧 + 镜头语言` | 时长/比例 | 本地默认 |

---

## D. 翻译例程（生成节点执行）

```
1. 取 CANON（来自两区制输出 + bible 锁定块）。
2. 读 bible.img_model / vid_model → 查本表取适配器。
3. 按适配器类型：
   - R 类：提示词 = 引用区(ID) + 镜头语言；附首/末帧定稿图 URL；参数按表填。
   - T 类：提示词 = style_prefix + 引用区锁定块原样内联(转文字) + 镜头语言；无图输入。
4. 负向：按适配器"负向写法"附加。
5. 展示适配后完整提示词（门禁）→ 你确认 → 调 `IMG`/`VID` 或你手动生成。
```

---

## E. 未登记模型的处理

- 不在表的模型：先按 CANON 输出规范提示词 + 标注「⚠ 模型未登记，参数/负向需你手动核对」。
- 跑通后鼓励把该模型的适配器补回本表（id/标签/类型/包裹格式/参数/能力/坑），下次自动适配。
