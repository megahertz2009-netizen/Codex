const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
await p.goto('file://' + __dirname + '/blood.html'); await p.evaluate(() => document.fonts.ready); await p.waitForTimeout(300);
const N=parseInt(process.argv[2]||'82');
for (let i=0;i<N;i++){ await p.evaluate(t=>window.render(t), i/24); await p.screenshot({ path: __dirname + '/f_' + String(i).padStart(3,'0') + '.png' }); }
await b.close(); console.log('frames', N); })();
