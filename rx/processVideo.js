const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');
const { OpenAI } = require('openai');
const WaveFile = require('wavefile').WaveFile;

// Initialize OpenAI client
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
});

async function extractAudio(videoPath, audioPath) {
    execSync(`ffmpeg -i "${videoPath}" -vn -acodec pcm_s16le -ar 16000 -ac 1 "${audioPath}" -y`);
}

async function detectSegments(audioPath) {
    const wav = new WaveFile(await fs.readFile(audioPath));
    const samples = wav.getSamples();
    const sampleRate = wav.fmt.sampleRate;
    const frame_duration_ms = 30;
    const padding_duration_ms = 300;
    const post_speech_padding_sec = 0.2;
    const frameSize = Math.floor(sampleRate * frame_duration_ms / 1000);
    const threshold = 0.05; // amplitude threshold for speech detection

    let segments = [];
    let segmentStart = null;
    let lastSpeechTimestamp = null;

    for (let i = 0; i < samples.length; i += frameSize) {
        const frame = samples.slice(i, i + frameSize);
        const timestamp = i / sampleRate;
        const rms = Math.sqrt(frame.reduce((sum, val) => sum + val * val, 0) / frame.length);
        const isSpeech = rms > threshold;

        if (isSpeech) {
            if (segmentStart === null) segmentStart = timestamp;
            lastSpeechTimestamp = timestamp;
        } else if (segmentStart !== null && lastSpeechTimestamp !== null) {
            segments.push({
                start: segmentStart,
                end: lastSpeechTimestamp + post_speech_padding_sec
            });
            segmentStart = null;
            lastSpeechTimestamp = null;
        }
    }

    if (segmentStart !== null) {
        segments.push({
            start: segmentStart,
            end: samples.length / sampleRate
        });
    }

    // Merge close segments
    const mergedSegments = [];
    let current = segments[0];
    for (let i = 1; i < segments.length; i++) {
        if (segments[i].start - current.end < padding_duration_ms / 1000) {
            current.end = segments[i].end;
        } else {
            mergedSegments.push(current);
            current = segments[i];
        }
    }
    if (current) mergedSegments.push(current);

    return mergedSegments;
}

async function transcribeAudioSegment(audioPath, start, end) {
    const duration = end - start;
    const tempFile = `temp_${Date.now()}.wav`;
    execSync(`ffmpeg -i "${audioPath}" -ss ${start} -t ${duration} -acodec pcm_s16le -ar 16000 -ac 1 "${tempFile}" -y`);
    
    const audioBuffer = await fs.readFile(tempFile);
    const transcript = await openai.audio.transcriptions.create({
        model: "whisper-1",
        file: {
            buffer: audioBuffer,
            name: 'audio.wav',
            mimetype: 'audio/wav'
        }
    });
    
    await fs.unlink(tempFile);
    return transcript.text.trim();
}

async function transcribeSegments(audioPath, segments) {
    const transcriptions = [];
    for (const seg of segments) {
        const text = await transcribeAudioSegment(audioPath, seg.start, seg.end);
        transcriptions.push({ start: seg.start, end: seg.end, text });
    }
    return transcriptions;
}

async function getLLMSuggestion(rawTranscription) {
    const prompt = `You are given a raw JSON transcription of a video as an array of objects. Each object has 'start' (start time in seconds), 'end' (end time in seconds), and 'text' (transcribed speech).

Task: Remove redundant or duplicate segments. If segments have same or nearly identical text (ignoring minor differences), keep only the last occurrence (highest start time). Return a JSON object with key "filtered_transcription" containing the filtered array in chronological order.

Example:
Input: [
  {"start": 6.84, "end": 9.8, "text": "In my previous video, I've reached..."},
  {"start": 12.24, "end": 15.08, "text": "In my previous video, I've reached many comments."},
  {"start": 15.84, "end": 24.17, "text": "In my previous video I've received many comments asking why use an LLM..."}
]
Output: {
  "filtered_transcription": [
    {"start": 15.84, "end": 24.17, "text": "In my previous video I've received many comments asking why use an LLM..."}
  ]
}

Raw transcription:
${JSON.stringify(rawTranscription, null, 2)}

Respond with JSON only:
{
  "filtered_transcription": []
}`;

    const response = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        temperature: 0
    });

    return JSON.parse(response.choices[0].message.content).filtered_transcription;
}

async function createFinalVideo(videoPath, segments) {
    const outputDir = 'edited';
    await fs.mkdir(outputDir, { recursive: true });
    const outputPath = path.join(outputDir, path.basename(videoPath));
    const filterComplex = segments
        .filter(seg => seg.end - seg.start > 0.1)
        .map((seg, i) => `[0:v]trim=start=${seg.start}:end=${seg.end},setpts=PTS-STARTPTS[v${i}];[0:a]atrim=start=${seg.start}:end=${seg.end},asetpts=PTS-STARTPTS[a${i}]`)
        .join(';');
    const concat = segments
        .filter(seg => seg.end - seg.start > 0.1)
        .map((_, i) => `[v${i}][a${i}]`)
        .join('');
    execSync(`ffmpeg -i "${videoPath}" -filter_complex "${filterComplex}${concat}concat=n=${segments.length}:v=1:a=1[outv][outa]" -map "[outv]" -map "[outa]" -c:v libx264 -c:a aac "${outputPath}" -y`);
}

async function processVideo(videoPath) {
    console.log(`Processing ${videoPath}`);
    const baseName = path.basename(videoPath, path.extname(videoPath));
    const tempAudioFile = `${baseName}_temp_audio.wav`;

    await extractAudio(videoPath, tempAudioFile);
    const rawSegments = await detectSegments(tempAudioFile);
    await fs.writeFile(`${baseName}_raw_segments.json`, JSON.stringify(rawSegments, null, 2));
    console.log(`Saved raw segments JSON to ${baseName}_raw_segments.json`);

    const rawTranscription = await transcribeSegments(tempAudioFile, rawSegments);
    await fs.writeFile(`${baseName}_transcription.json`, JSON.stringify(rawTranscription, null, 2));
    console.log(`Saved raw transcription JSON to ${baseName}_transcription.json`);

    await fs.unlink(tempAudioFile);

    const suggestion = await getLLMSuggestion(rawTranscription);
    await fs.writeFile(`${baseName}_suggestion.json`, JSON.stringify(suggestion, null, 2));
    console.log(`Saved LLM suggestion JSON to ${baseName}_suggestion.json`);

    await createFinalVideo(videoPath, suggestion);
}

async function main() {
    const videoFiles = (await fs.readdir('raw'))
        .filter(f => /\.(mp4|mov|avi|mkv)$/i.test(f))
        .map(f => path.join('raw', f));
    
    for (const videoFile of videoFiles) {
        await processVideo(videoFile);
    }
}

main().catch(console.error);
