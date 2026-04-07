<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/2h/waza.svg" width="120" />
  <h1>Waza</h1>
  <p><b>Engineering habits you already know, turned into skills Claude can run.</b></p>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/AiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## Why

Waza is a Japanese martial arts term for technique: a move practiced until it becomes instinct.

A good engineer does not just write code. They think through requirements, review their own work, debug systematically, design interfaces that feel intentional, and read primary sources. They write clearly, and learn new domains by producing output, not consuming content.

AI makes you faster. It does not make you think more clearly, ship more carefully, or understand more deeply. Waza turns each of these habits into a skill Claude can execute.

<img src="https://gw.alipayobjects.com/zos/k/qa/waza_repaired_v4.svg" width="800" />

## Skills

Each engineering habit gets a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills). Type the slash command, Claude follows the playbook.

| Skill | When | What it does |
| :--- | :--- | :--- |
| [`/think`](skills/think/SKILL.md) | Before building anything new | Challenges the problem, pressure-tests the design, validates architecture before any code is written. |
| [`/design`](skills/design/SKILL.md) | Building frontend interfaces | Produces distinctive UI with a committed aesthetic direction, not generic defaults. |
| [`/check`](skills/check/SKILL.md) | After a task, before merging | Reviews the diff, auto-fixes safe issues, blocks destructive commands via hooks, verifies with evidence. |
| [`/hunt`](skills/hunt/SKILL.md) | Any bug or unexpected behavior | Systematic debugging. Root cause confirmed before any fix is applied. |
| [`/write`](skills/write/SKILL.md) | Writing or editing prose | Rewrites prose to sound natural in Chinese and English. Strips AI writing patterns. |
| [`/learn`](skills/learn/SKILL.md) | Diving into an unfamiliar domain | Six-phase research workflow: collect, digest, outline, fill in, refine, then self-review and publish. |
| [`/read`](skills/read/SKILL.md) | Any URL or PDF | Fetches content as clean Markdown via proxy cascade script. Dedicated handlers for WeChat and Feishu. |
| [`/health`](skills/health/SKILL.md) | Auditing Claude Code setup | Checks CLAUDE.md, rules, skills, hooks, MCP, and behavior. Flags issues by severity. |

Each skill is a folder, not just a markdown file. Skills include reference docs, helper scripts, scoped hooks, and gotchas sections built from real project failures.

## Extras

**Statusline**

A minimal Claude Code statusline that shows only what matters: context window usage, 5-hour quota, and 7-day quota, each with the time remaining until reset.

<img src="https://gw.alipayobjects.com/zos/k/y9/RUgevg.png" width="800" />

Color coding: green below 70%, yellow at 70-85%, red above 85% for context; blue, magenta, red for quota thresholds. No progress bars, no noise.

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/scripts/setup-statusline.sh | bash
```

**English Coaching**

English should be every engineer's first language when working with AI. The model thinks in English, the best resources are in English, and writing clearly in English is a skill that compounds over time.

Passive grammar correction on every reply. Claude flags mistakes with the pattern name so you learn why.

> 😇 it is not good to be read → it's hard to read (Unnatural phrasing)

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/templates/coaching-en.md >> ~/.claude/CLAUDE.md
```

## Install

**Claude Code:**

```bash
npx skills add tw93/Waza -g -y
```

**Other agents:** run without the `-a` flag to pick your agent interactively.

```bash
npx skills add tw93/Waza
```

Requires Node 18+. Skills are also available at `.agents/skills/` for agents that discover from that path automatically.

Install a single skill:

```bash
npx skills add tw93/Waza -s health -y
```

Replace `health` with any skill name.

**Compatibility:** Core instruction skills `/think`, `/hunt`, `/learn`, `/write`, `/design` run on any agent. Claude Code-specific features are skipped on other platforms: `/check` loses hook-based destructive command blocking and sub-agent reviewers; `/health` and `/read` lose their shell scripts for URL fetching and config auditing.

## Background

Tools like Superpowers and gstack are impressive, but they are heavy. Too many skills, too much configuration, too steep a learning curve for engineers who just want to get things done.

There is a deeper issue with heavy skill collections: every rule the author writes becomes a ceiling. The model can only do what the instructions prescribe, and it cannot outgrow them. Waza takes the opposite approach. Each skill states a goal and the constraints that matter, then gets out of the way. As models improve, that restraint pays compound interest.

Eight skills that cover the habits that actually matter. Each one does one thing, has a clear trigger, and stays out of the way. The goal is not completeness. It is the right amount, done well.

Built from patterns accumulated across real projects, then refined with real usage data. Every gotcha in a skill traces to a specific failure: a wrong code path that cost four rounds of debugging, a release announced before artifacts were uploaded, a server restarted eight times without reading the error. 30 days, 300+ sessions, 7 projects, 500 hours.

The `/health` skill is based on the six-layer framework described in [this post](https://tw93.fun/en/2026-03-12/claude.html).

## Support

- If Waza helped you, star the repo or [share it](https://twitter.com/intent/tweet?url=https://github.com/tw93/Waza&text=Waza%20-%20Claude%20Code%20skills%20for%20the%20complete%20engineer.) with friends.
- Have ideas or found bugs? Open an issue or PR.
- I have two cats, TangYuan and Coke. If you think Waza delights your life, you can feed them <a href="https://miaoyan.app/cats.html?name=Waza" target="_blank">canned food 🥩</a>.

<a href="https://miaoyan.app/cats.html?name=Waza"><img src="https://rawcdn.githack.com/tw93/MiaoYan/vercel/assets/sponsors.svg" width="1000" loading="lazy" /></a>

## License

MIT License. Feel free to use Waza and contribute.
