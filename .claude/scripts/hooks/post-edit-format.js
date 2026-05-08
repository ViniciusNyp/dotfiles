#!/usr/bin/env node
/**
 * PostToolUse format hook (Edit | Write | MultiEdit)
 *
 * Walks up from the edited file looking for a formatter config
 * (.prettierrc*, biome.json, deno.json, .eslintrc.*). If found and the file
 * extension is supported, runs the formatter in-place. No-ops otherwise.
 *
 * Best-effort: never blocks the tool, never throws on stdin parse errors.
 *
 * Hook ID: post:edit:format-auto
 */

'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const MAX_STDIN = 1024 * 1024;
const FORMAT_TIMEOUT_MS = 10000;

const PRETTIER_CONFIGS = [
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.toml',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
];
const BIOME_CONFIGS = ['biome.json', 'biome.jsonc'];
const DENO_CONFIGS = ['deno.json', 'deno.jsonc'];

const FORMATTABLE_EXTS = new Set([
  '.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs',
  '.json', '.jsonc', '.css', '.scss', '.less',
  '.html', '.vue', '.svelte', '.md', '.mdx', '.yaml', '.yml',
]);

function findUpwards(startDir, candidates) {
  let dir = path.resolve(startDir);
  const root = path.parse(dir).root;
  while (true) {
    for (const c of candidates) {
      const candidate = path.join(dir, c);
      if (fs.existsSync(candidate)) return { configPath: candidate, dir };
    }
    if (dir === root) return null;
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

function detectFormatter(filePath) {
  const startDir = path.dirname(filePath);
  const biome = findUpwards(startDir, BIOME_CONFIGS);
  if (biome) return { kind: 'biome', dir: biome.dir };
  const prettier = findUpwards(startDir, PRETTIER_CONFIGS);
  if (prettier) return { kind: 'prettier', dir: prettier.dir };
  const deno = findUpwards(startDir, DENO_CONFIGS);
  if (deno) return { kind: 'deno', dir: deno.dir };
  return null;
}

function runFormatter(filePath, formatter) {
  const ext = path.extname(filePath).toLowerCase();
  if (!FORMATTABLE_EXTS.has(ext)) return;
  if (!fs.existsSync(filePath)) return;

  let cmd, args;
  switch (formatter.kind) {
    case 'biome':
      cmd = 'npx';
      args = ['--no-install', 'biome', 'format', '--write', filePath];
      break;
    case 'prettier':
      cmd = 'npx';
      args = ['--no-install', 'prettier', '--write', filePath];
      break;
    case 'deno':
      cmd = 'deno';
      args = ['fmt', filePath];
      break;
    default:
      return;
  }

  spawnSync(cmd, args, {
    cwd: formatter.dir,
    stdio: ['ignore', 'ignore', 'pipe'],
    timeout: FORMAT_TIMEOUT_MS,
  });
}

function run(raw) {
  try {
    const input = raw.trim() ? JSON.parse(raw) : {};
    const filePath = input?.tool_input?.file_path;
    if (!filePath || typeof filePath !== 'string') return raw;

    const formatter = detectFormatter(filePath);
    if (!formatter) return raw;

    runFormatter(filePath, formatter);
  } catch {
    // best-effort: never block the tool
  }
  return raw;
}

module.exports = { run };

if (require.main === module) {
  let data = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => {
    if (data.length < MAX_STDIN) data += chunk.substring(0, MAX_STDIN - data.length);
  });
  process.stdin.on('end', () => {
    process.stdout.write(run(data));
  });
}
