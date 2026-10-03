import path from 'path';
import { fileURLToPath } from 'url';
import PDFDocument from 'pdfkit';
import bidiFactory from 'bidi-js';

const bidi = bidiFactory();
const VISUAL_MARK = '\uE000';
const PAGE_W = 595.28;
const PAGE_H = 841.89;
const M = 28;

const INK = '#1A1714';
const PAPER = '#F3EEE6';
const CARD = '#FFFCF8';
const GOLD = '#A68456';
const GOLD_DEEP = '#8C6B3E';
const MUTED = '#8A8178';
const TRACK = '#E6D9C8';
const UP = '#1E7A4A';
const DOWN = '#A33B32';
const LINE = '#E4D8C8';

const fontsDir = path.join(path.dirname(fileURLToPath(import.meta.url)), '../../assets/fonts');
const fontMedium = path.join(fontsDir, 'Heebo-Medium.ttf');
const fontBold = path.join(fontsDir, 'Heebo-Bold.ttf');

function hasHebrew(value) {
  return /[\u0590-\u05FF]/.test(String(value ?? ''));
}

function visual(text) {
  const levels = bidi.getEmbeddingLevels(text, 'rtl');
  const chars = Array.from(text);
  for (const [index, replacement] of bidi.getMirroredCharactersMap(text, levels)) {
    chars[index] = replacement;
  }
  for (const [start, end] of bidi.getReorderSegments(text, levels)) {
    let left = start;
    let right = end;
    while (left < right) {
      const swap = chars[left];
      chars[left] = chars[right];
      chars[right] = swap;
      left += 1;
      right -= 1;
    }
  }
  return chars.join('');
}

function present(value) {
  const shown = String(value ?? '');
  if (!shown || !hasHebrew(shown)) return shown;
  return VISUAL_MARK + visual(shown).replace(/ /g, '\u00A0');
}

function lockVisualOrder(doc) {
  const font = doc._font?.font;
  if (!font || font.__inkVisualLock) return;
  const original = font.layout.bind(font);
  font.layout = (string, features, script, language, direction) => {
    if (typeof string === 'string' && string.includes(VISUAL_MARK)) {
      return original(string.replaceAll(VISUAL_MARK, ''), features || [], 'latn', undefined, 'ltr');
    }
    return original(string, features, script, language, direction);
  };
  font.__inkVisualLock = true;
}

function textWidth(doc, value, size, bold) {
  doc.font(bold ? fontBold : fontMedium).fontSize(size);
  lockVisualOrder(doc);
  return doc.widthOfString(present(value));
}

function write(doc, value, x, y, width, options = {}) {
  const size = options.size || 12;
  const color = options.color || INK;
  const align = options.align || 'right';
  doc.font(options.bold ? fontBold : fontMedium).fontSize(size).fillColor(color);
  lockVisualOrder(doc);
  doc.text(present(value), x, y, {
    width,
    align,
    lineBreak: options.wrap === true,
    height: options.height,
    ellipsis: options.ellipsis === true,
    characterSpacing: 0,
  });
}

function card(doc, x, y, w, h) {
  doc.save();
  doc.fillColor(CARD).roundedRect(x, y, w, h, 14).fill();
  doc.restore();
}

function toneColor(tone) {
  if (tone === 'up') return UP;
  if (tone === 'down') return DOWN;
  return MUTED;
}

function drawKpis(doc, kpis, y) {
  const gap = 10;
  const cols = 3;
  const cardW = (PAGE_W - M * 2 - gap * (cols - 1)) / cols;
  const cardH = 86;
  kpis.slice(0, 6).forEach((item, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = M + (cols - 1 - col) * (cardW + gap);
    const top = y + row * (cardH + gap);
    card(doc, x, top, cardW, cardH);
    write(doc, item.label, x + 12, top + 12, cardW - 24, { size: 9, color: MUTED });
    write(doc, item.value, x + 12, top + 30, cardW - 24, { size: 22, color: INK, bold: true });
    if (item.sub) {
      write(doc, item.sub, x + 12, top + 60, cardW - 24, {
        size: 8.5,
        color: toneColor(item.tone),
        align: 'right',
      });
    }
  });
  return y + 2 * (cardH + gap) - gap;
}

function drawSectionLabel(doc, label, x, y, w) {
  write(doc, label, x, y, w, { size: 13, color: INK, bold: true });
  doc.save();
  doc.strokeColor(GOLD).lineWidth(1.5).moveTo(x + w - 36, y + 18).lineTo(x + w, y + 18).stroke();
  doc.restore();
  return y + 28;
}

function drawScreens(doc, screens, empty, x, y, w) {
  let cursor = drawSectionLabel(doc, 'מסכים', x, y, w);
  if (!screens.length) {
    write(doc, empty || 'אין נתונים', x, cursor, w, { size: 10, color: MUTED });
    return cursor + 24;
  }
  const max = Math.max(...screens.map((row) => row.value), 1);
  for (const row of screens) {
    const valueText = String(row.value);
    const labelW = textWidth(doc, row.label, 10, false);
    const valueW = textWidth(doc, valueText, 10, true);
    write(doc, row.label, x, cursor, w, { size: 10 });
    write(doc, valueText, x + w - labelW - valueW - 14, cursor, valueW + 4, {
      size: 10,
      align: 'right',
      bold: true,
    });
    const barW = Math.max(28, w - labelW - valueW - 28);
    const barY = cursor + 5;
    doc.save();
    doc.fillColor(TRACK).roundedRect(x, barY, barW, 5, 2).fill();
    if (row.value > 0) {
      const fill = Math.max(3, barW * (row.value / max));
      doc.fillColor(GOLD_DEEP).roundedRect(x + barW - fill, barY, fill, 5, 2).fill();
    }
    doc.restore();
    cursor += 24;
  }
  return cursor;
}

function drawActions(doc, actions, empty, x, y, w) {
  let cursor = drawSectionLabel(doc, 'פעולות', x, y, w);
  if (!actions.length) {
    write(doc, empty || 'אין נתונים', x, cursor, w, { size: 10, color: MUTED });
    return cursor + 24;
  }
  for (const row of actions) {
    const valueText = String(row.value);
    const labelW = textWidth(doc, row.label, 10, false);
    const valueW = textWidth(doc, valueText, 11, true);
    write(doc, row.label, x, cursor, w, { size: 10 });
    write(doc, valueText, x + w - labelW - valueW - 14, cursor, valueW + 4, {
      size: 11,
      align: 'right',
      bold: true,
    });
    cursor += 22;
  }
  return cursor;
}

function drawStats(doc, stats, y) {
  const gap = 8;
  const cols = 3;
  const cardW = (PAGE_W - M * 2 - gap * (cols - 1)) / cols;
  const cardH = 58;
  stats.slice(0, 6).forEach((item, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = M + (cols - 1 - col) * (cardW + gap);
    const top = y + row * (cardH + gap);
    card(doc, x, top, cardW, cardH);
    write(doc, item.label, x + 12, top + 10, cardW - 24, { size: 8.5, color: MUTED });
    write(doc, item.value, x + 12, top + 26, cardW - 78, { size: 16, bold: true });
    if (item.sub) {
      write(doc, item.sub, x + 12, top + 32, cardW - 24, {
        size: 8,
        color: toneColor(item.tone),
        align: 'left',
      });
    }
  });
  return y + 2 * (cardH + gap);
}

function wrapLines(doc, text, width, size) {
  const words = String(text).split(/\s+/).filter(Boolean);
  const lines = [];
  let current = [];
  for (const word of words) {
    const trial = [...current, word].join(' ');
    if (current.length && textWidth(doc, trial, size, false) > width) {
      lines.push(current.join(' '));
      current = [word];
    } else {
      current.push(word);
    }
  }
  if (current.length) lines.push(current.join(' '));
  return lines.length ? lines : [''];
}

function drawRecommendations(doc, items, title) {
  doc.addPage({ size: 'A4', margin: 0 });
  doc.save();
  doc.rect(0, 0, PAGE_W, PAGE_H).fill(PAPER);
  doc.rect(0, 0, PAGE_W, 96).fill(INK);
  doc.rect(0, 96, PAGE_W, 3).fill(GOLD);
  doc.restore();

  doc.font(fontBold).fontSize(12).fillColor(GOLD);
  doc.text('INK', M, 28, { lineBreak: false, characterSpacing: 3.2 });
  write(doc, 'חמישה דברים שהייתי משפר', M, 22, PAGE_W - M * 2, {
    size: 22,
    color: '#F6F1E8',
    bold: true,
  });
  write(doc, title, M, 58, PAGE_W - M * 2, { size: 12, color: '#E4D3BE' });

  const textW = PAGE_W - M * 2 - 72;
  let y = 122;
  items.slice(0, 5).forEach((text, index) => {
    const lines = wrapLines(doc, text, textW, 12);
    const height = Math.max(72, 28 + lines.length * 20);
    card(doc, M, y, PAGE_W - M * 2, height);
    write(doc, String(index + 1), PAGE_W - M - 44, y + 18, 28, {
      size: 18,
      color: GOLD_DEEP,
      bold: true,
    });
    lines.forEach((line, lineIndex) => {
      write(doc, line, M + 18, y + 18 + lineIndex * 20, textW, { size: 12 });
    });
    y += height + 12;
  });
}

function drawFooter(doc, parts) {
  doc.save();
  doc.rect(0, PAGE_H - 48, PAGE_W, 48).fill(INK);
  doc.restore();
  const text = parts.filter(Boolean).join('   ·   ');
  write(doc, text, M, PAGE_H - 30, PAGE_W - M * 2, { size: 9, color: '#E7D7C3' });
}

export function renderDailyReportPdf(model) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: 'A4',
      margin: 0,
      info: { Title: `INK daily ${model.stamp}`, Author: 'INK' },
    });
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    doc.save();
    doc.rect(0, 0, PAGE_W, PAGE_H).fill(PAPER);
    doc.rect(0, 0, PAGE_W, 118).fill(INK);
    doc.rect(0, 118, PAGE_W, 3).fill(GOLD);
    doc.restore();

    doc.font(fontBold).fontSize(12).fillColor(GOLD);
    doc.text('INK', M, 36, { lineBreak: false, characterSpacing: 3.2 });
    write(doc, 'דוח יומי', M, 28, PAGE_W - M * 2, { size: 28, color: '#F6F1E8', bold: true });
    write(doc, model.title, M, 66, PAGE_W - M * 2, { size: 13, color: '#E4D3BE' });
    write(doc, 'סיכום היום הקודם, בהשוואה ליום שלפניו', M, 88, PAGE_W - M * 2, {
      size: 9,
      color: '#B7A894',
    });

    let y = 140;
    y = drawKpis(doc, model.kpis, y) + 16;

    if (model.people.length) {
      card(doc, M, y, PAGE_W - M * 2, 36);
      write(doc, model.people.join('   ·   '), M + 14, y + 12, PAGE_W - M * 2 - 28, {
        size: 9,
        color: INK,
        wrap: true,
        height: 16,
        ellipsis: true,
      });
      y += 48;
    }

    const gap = 16;
    const colW = (PAGE_W - M * 2 - gap) / 2;
    const left = M;
    const right = M + colW + gap;
    const screensBottom = drawScreens(doc, model.screens, model.screensEmpty, right, y, colW);
    const actionsBottom = drawActions(doc, model.actions, model.actionsEmpty, left, y, colW);
    y = Math.max(screensBottom, actionsBottom) + 18;

    write(doc, 'תוכן וחריגות', M, y, PAGE_W - M * 2, { size: 13, bold: true });
    doc.save();
    doc.strokeColor(LINE).lineWidth(1).moveTo(M, y + 20).lineTo(PAGE_W - M, y + 20).stroke();
    doc.restore();
    y += 30;
    drawStats(doc, model.stats, y);
    drawFooter(doc, model.footer);
    if (model.recommendations?.length) {
      drawRecommendations(doc, model.recommendations, model.title);
    }
    doc.end();
  });
}
