#!/usr/bin/env node
// Generador procedural de SFX 8-bit para Godot 2D (jsfxr)
// Uso: node gen.js <tipo> [archivo_salida.wav]
// Tipos: pickup|coin, laser|shoot, explosion|boom, powerup, hit|hurt,
//        jump, blip|select, random
import { sfxr } from "jsfxr";
import { writeFileSync } from "node:fs";
import { resolve } from "node:path";

const TYPES = {
  pickup: "pickupCoin",
  coin: "pickupCoin",
  laser: "laserShoot",
  shoot: "laserShoot",
  explosion: "explosion",
  boom: "explosion",
  powerup: "powerUp",
  hit: "hitHurt",
  hurt: "hitHurt",
  jump: "jump",
  blip: "blipSelect",
  select: "blipSelect",
  random: "random",
};

const type = (process.argv[2] || "blip").toLowerCase();
const out = process.argv[3] || "out.wav";
const key = TYPES[type] || "random";

// toBuffer devuelve PCM crudo (sin header) del sonido
const pcm = new Uint8Array(sfxr.toBuffer(sfxr.generate(key)));

// Parámetros por defecto de jsfxr (sample_rate 44100, 16 bit, mono)
const sampleRate = 44100;
const bitsPerSample = 16;
const channels = 1;
const dataSize = pcm.length;
const byteRate = (sampleRate * channels * bitsPerSample) / 8;
const blockAlign = (channels * bitsPerSample) / 8;

const header = Buffer.alloc(44);
header.write("RIFF", 0, "ascii");
header.writeUInt32LE(36 + dataSize, 4);
header.write("WAVE", 8, "ascii");
header.write("fmt ", 12, "ascii");
header.writeUInt32LE(16, 16);               // fmt chunk size
header.writeUInt16LE(1, 20);                // audio format: PCM
header.writeUInt16LE(channels, 22);
header.writeUInt32LE(sampleRate, 24);
header.writeUInt32LE(byteRate, 28);
header.writeUInt16LE(blockAlign, 32);
header.writeUInt16LE(bitsPerSample, 34);
header.write("data", 36, "ascii");
header.writeUInt32LE(dataSize, 40);

writeFileSync(resolve(out), Buffer.concat([header, Buffer.from(pcm)]));
console.log(`OK: generated SFX '${key}' -> ${out} (${(dataSize / 1024).toFixed(1)} KiB PCM)`);