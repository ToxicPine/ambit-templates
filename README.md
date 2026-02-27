# Ambit Templates

Ready-to-deploy templates for [Ambit](https://github.com/ToxicPine/ambit), a toolkit for hosting apps on a private cloud network that only your devices can reach.

| Template | What it does |
| --- | --- |
| [opencode](./opencode/) | Persistent [OpenCode](https://opencode.ai) workspace with mobile/desktop handoff |
| [wetty](./wetty/) | Browser-based terminal, works on iOS, no SSH needed |
| [chromatic](./chromatic/) | Headless Chrome exposing CDP for agents and automation |

## Usage

```bash
npx @cardelli/ambit create lab
npx @cardelli/ambit deploy my-app.lab --template ToxicPine/ambit-templates/<template>
```

See each template's README for details.
