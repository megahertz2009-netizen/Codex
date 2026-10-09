export const meta = {
  name: 'episode-continuity-qa',
  description: 'Independent continuity/quality review of the АДМИН episode v11 cut, then adversarial verification of each finding',
  phases: [
    { title: 'Review', detail: 'segment reviewers inspect frames, subtitles and audio of light.mp4 in the Higgsfield sandbox' },
    { title: 'Verify', detail: 'one skeptic per non-trivial finding re-inspects the exact moment and tries to refute it' },
  ],
}

const COMMON = `
You are QA-reviewing a finished vertical (1080x1920, 24 fps, 98.43 s) cinematic Instagram Reels episode stored in a REMOTE Higgsfield cloud sandbox at /home/user/p8/light.mp4.
Access it ONLY through the MCP tool mcp__https_mcp_higgsfield_ai_mcp__sandbox_exec (load it first with ToolSearch query "select:mcp__https_mcp_higgsfield_ai_mcp__sandbox_exec"). It runs bash with ffmpeg, ImageMagick, python3 + faster-whisper. Foreground calls time out at 60-120 s (set timeout_seconds up to 120).
To actually SEE frames you must pass image_paths (max 4 JPEG/PNG, <=512 KiB total) in a foreground sandbox_exec call. Build contact sheets, e.g.:
  mkdir -p /home/user/qa/$NAME && cd /home/user/qa/$NAME && ffmpeg -v error -y -ss START -t DUR -i /home/user/p8/light.mp4 -vf "fps=3,scale=180:320,tile=8x2" -frames:v 1 -q:v 5 sheet1.jpg
and pass image_paths ["qa/$NAME/sheet1.jpg"]. For detail, grab single frames at 540x960. Look at the images carefully before judging.
STRICT RULES: work only inside /home/user/qa/<your own folder>; never modify, move or delete anything in /home/user/p8; never call generation, upload or any credit-spending tool; do not restart the sandbox.

STORY (Russian-language thriller ad; hero is a man; product = grey men's thermal underwear by brand АДМИН, placed covertly):
A helicopter with "АДМИН" lettering drops the hero at the North Pole; he searches for a signal with a tracker; he sees a polar bear (eye close-up with bear reflected in the pupil); bear chase; he jumps into the sea in a navy parka; underwater the bear dives in from above right behind him, tears the parka off him (feathers) and he slips out in the grey thermal; he climbs onto the ice in the thermal; the bear surfaces behind him with the torn parka in its jaws and the ice collapses under it; he stands up, steam rises off the thermal ("Промок насквозь… а тепло не уходит" = soaked through but the warmth stays); he finds a capsule/beacon and presses it; radio warns it is bait and bears are coming; a bloody bear; two bears close in from both sides on the red beacon; "Это ловушка…"; he pulls a flare; bear rears up; flare ignites red; black; base on radio "Север, ты меня слышишь? Ответь!"; a surveillance camera feed "АДМИН · CAM 03" shows him lying in bloody snow by the burning flare while the bears walk away, cold voice "Первое испытание пройдено"; close-up of his hand in bloody snow next to the flare, fingers clench into a fist (he is alive); blood-red dripping title "ДОБРО ПОЖАЛОВАТЬ В ИГРУ" with the voice; end card "АДМИН · СЕРИЯ 1 · СИГНАЛ".

TIMELINE (seconds in light.mp4): s0 intro 0-12.84 (heli 0-3.8, POV tracker+walk 3.8-9.01, crash zoom into eye 9.01-10.05, eye macro with bear reflection 10.05-12.84); s1 bear + chase + jump 12.84-27.89; s2 water 27.89-45.48 (entry 27.89-29.35, side view in parka 29.35-30.77, bear plunge 30.77-34.41, parka torn/escape/climb out/bear with parka/ice collapse 34.41-45.48); s3 steam 45.48-49.53; s4 tracker/capsule/press/bait/blood bear/two bears 49.53-74.04; s5 rear-up + flare 74.04-81.71; s6 ending 81.71-95.81 (black+radio 81.71-85.31, CCTV 85.31-88.31, hand 88.31-92.36, blood title 92.36-95.81); s7 end card 95.81-98.43.

PAST USER COMPLAINTS (must not recur): jacket logic contradictions (losing the jacket then wearing it again, throwing it on ice then bear pulling it from the water); a freezing/shivering scene (contradicts the thermal message); red glowing "Terminator" eye; a static split-screen "photo" in the water; constant radio hiss at the start; unclear transitions (water appearing from nowhere, two bears from nowhere); ugly/uninteresting end text; unclear whether he survived.

Report only concrete, verifiable problems a viewer would notice: continuity errors (clothing/jacket/backpack/blood/injuries/location/lighting/time of day/number of bears), logic holes, jarring cuts or duplicated moments, visual glitches/artifacts, subtitle problems (wrong text vs speech, timing off, unreadable, overlapping UI zones: keep important content clear of top ~250 px and bottom ~400 px), audio problems (silence gaps, clipping, voice unintelligible, hiss). For each give the exact time, what you saw, why it matters, severity (high = breaks story or obvious glitch; medium = noticeable; low = nitpick) and a concrete fix using existing footage/edit when possible. If a segment is clean, return an empty findings list — do not invent problems.`

const FINDINGS = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          time_sec: { type: 'number' },
          category: { type: 'string' },
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
          description: { type: 'string' },
          evidence: { type: 'string' },
          suggested_fix: { type: 'string' },
        },
        required: ['time_sec', 'category', 'severity', 'description', 'evidence', 'suggested_fix'],
      },
    },
    segment_summary: { type: 'string' },
  },
  required: ['findings', 'segment_summary'],
}

const VERDICT = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    reasoning: { type: 'string' },
    corrected_description: { type: 'string' },
    best_fix: { type: 'string' },
  },
  required: ['refuted', 'reasoning', 'corrected_description', 'best_fix'],
}

const REVIEWERS = [
  { key: 'intro', range: '0-27.89 (s0 intro + s1 chase/jump)', focus: 'helicopter lettering legibility, location caption, POV tracker, eye crash zoom + bear reflection (must be natural, not red), cut from eye to bear, chase continuity (parka, backpack), the jump into water.' },
  { key: 'water', range: '27.2-49.53 (end of s1, s2 water, s3 steam)', focus: 'jacket logic frame by frame: is he wearing the parka in every shot until the bear tears it off? does he climb out WITHOUT the parka? does the bear surface WITH the torn parka? any shot where the parka reappears? Any split-screen/static photo artifacts, upscaling blur, jump cuts, shivering. Steam shot and subtitle.' },
  { key: 'beacon', range: '49.53-74.04 (s4)', focus: 'tracker/capsule/press continuity, clothing (he must be in the grey thermal only, no parka), number and position of bears, whether two bears arrive logically, blood consistency, subtitles vs radio lines.' },
  { key: 'ending', range: '74.04-98.43 (s5 flare, s6 ending, s7 card)', focus: 'flare continuity (flare type/color between shots), does the CCTV shot read clearly and match (clothing, flare, bears, blood), CCTV overlay text legibility and Cyrillic rendering, order logic CCTV -> hand (he already moves in CCTV before the hand twitches?), hand shot (sleeve should be grey thermal; flare looks like a flare, not dynamite), blood title readability, end card.' },
  { key: 'audio', range: 'whole video, audio + subtitles', focus: 'transcribe the full audio with faster-whisper (model small, language ru, word timestamps) and compare against the burned-in subtitles (extract frames at subtitle times); check every voice line is intelligible and subtitled, timing within ~0.3 s, no lines overlapping each other, radio hiss level in the first 12 s, silence gaps, clipping/peaks (ffmpeg astats / ebur128), the cold game-master voice in the ending is clear.' },
]

const results = await pipeline(
  REVIEWERS,
  r => agent(
    `${COMMON}\n\nYOUR ASSIGNMENT (folder name: ${r.key}): review ${r.range}. Focus: ${r.focus}\nInspect densely (at least 3 fps contact sheets across your whole range, plus single detail frames where needed).`,
    { label: `review:${r.key}`, phase: 'Review', schema: FINDINGS },
  ),
  (rev, r) => {
    if (!rev) return []
    const toCheck = rev.findings.filter(f => f.severity !== 'low')
    const lows = rev.findings.filter(f => f.severity === 'low').map(f => ({ ...f, reviewer: r.key, verdict: { refuted: false, reasoning: 'low severity, not verified', corrected_description: f.description, best_fix: f.suggested_fix }, verified: false }))
    return parallel(toCheck.map((f, i) => () =>
      agent(
        `${COMMON}\n\nYou are an adversarial verifier (folder name: verify_${r.key}_${i}). Another reviewer claims this problem at t=${f.time_sec}s:\nCATEGORY: ${f.category}\nCLAIM: ${f.description}\nEVIDENCE: ${f.evidence}\nPROPOSED FIX: ${f.suggested_fix}\n\nTry hard to REFUTE it: re-inspect the exact moment yourself (frames at 6-8 fps around t-2..t+2 s, single 540x960 frames, audio if relevant). Mark refuted=true if the claim is wrong, exaggerated, or a viewer would not notice it; refuted=false only if you independently see the problem. If real, give the most practical fix using existing footage/edits (no new generation unless unavoidable).`,
        { label: `verify:${r.key}:${i}`, phase: 'Verify', schema: VERDICT },
      ).then(v => ({ ...f, reviewer: r.key, verdict: v, verified: true }))
    )).then(arr => [...arr.filter(Boolean), ...lows])
  },
)

const summaries = []
const all = []
results.forEach((arr, i) => { if (arr) all.push(...arr) })
const confirmed = all.filter(f => f.verified && f.verdict && !f.verdict.refuted)
const refuted = all.filter(f => f.verified && f.verdict && f.verdict.refuted)
const lows = all.filter(f => !f.verified)
log(`confirmed ${confirmed.length}, refuted ${refuted.length}, low-unverified ${lows.length}`)
return { confirmed, refuted, lows }
