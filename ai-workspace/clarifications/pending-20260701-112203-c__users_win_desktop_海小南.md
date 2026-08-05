# Clarification Draft (auto)

- **Created**: 2026-07-01 11:22:03
- **CWD**: c:\users\win\desktop\海小南
- **Message type**: B
- **Gate**: pending 鈥?user must confirm Mini-Spec before code edits

## User prompt

整个项目演示完发现很多问题：
1、唤起小南小南时，要要加一个语音反馈说“我在”，现在已经有tts了，在调用智能体的时候会说话，这部分要说的话需要给个入口配置，确保说的话是我希望它说的
2、数字人形象改成live2d，不要气泡和图片动 ，之前做一版有几个动作，眼睛、鼻子、嘴和肢体都有动作响应，现在就是纯粹的图片整体动加上气泡在动
3、现在语音唤起任务响应不了，喊完小南小南后，后面接的是具体任务，现在预设的就只有3个，按照预设的演示内容喊了还是无法响应，这个链路之前是通的，你需要进行修改和优化。
4、还有很多细节和交互上的问题，你都整体全局检查一下吧，在海小南Demo-分享包的文件夹里进行修改

## Detected intents

- 配置/安装/环境/工具链 (config_infra)
- 记忆/续接/历史会话 (memory_session)
- 编码/实现/重构 (coding_task)
- 验证/交付/声称完成 (verify_delivery)
- 模糊/口语化需求 (fuzzy_requirement)

## Agent: fill before execute

1. HYPOTHESIS + CONFIDENCE (interview-protocol)
2. Section 4.5 Mini-Spec (mini-spec-template.md)
3. Section 7 pending questions (<=5)
4. User explicit confirm -> gate clears
