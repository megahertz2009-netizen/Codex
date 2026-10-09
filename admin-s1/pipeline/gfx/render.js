const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
await p.goto('file://' + __dirname + '/title.html'); await p.evaluate(() => document.fonts.ready); await p.screenshot({ path: __dirname + '/title.png' }); await b.close(); })();
