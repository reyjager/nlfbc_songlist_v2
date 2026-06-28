import pdfplumber
import pytesseract
import re
import os
import sys

INPUT_DIR = "assets/song_list"
OUTPUT_DIR = "assets/song_list_text"

chord_pattern = re.compile(r'^[A-G][#b]?(m|maj|min|dim|aug|sus|add|7|9|11|13|6|2|4)*(/[A-G][#b]?)?$')


def is_chord_line(words):
    chord_count = 0
    total = 0
    for w in words:
        token = w['text'].strip().rstrip(';').rstrip(',').rstrip(':')
        if not token:
            continue
        total += 1
        if chord_pattern.match(token):
            chord_count += 1
    return total > 0 and chord_count >= total * 0.6


def merge_chord_lyric(chord_words, lyric_words):
    if not lyric_words:
        return ' '.join(f"[{w['text'].strip().rstrip(';').rstrip(',')}]" for w in chord_words)

    result = []
    used_chords = set()

    for lw in lyric_words:
        lw_left = lw['left']
        lw_right = lw['left'] + lw['width']
        chords_here = []

        for ci, cw in enumerate(chord_words):
            if ci in used_chords:
                continue
            cw_center = cw['left'] + cw['width'] / 2
            if lw_left - 20 <= cw_center <= lw_right + 20:
                chord_text = cw['text'].strip().rstrip(';').rstrip(',').rstrip(':')
                if chord_pattern.match(chord_text):
                    chords_here.append(chord_text)
                    used_chords.add(ci)

        if chords_here:
            prefix = ''.join(f'[{c}]' for c in chords_here)
            result.append(f"{prefix}{lw['text']}")
        else:
            result.append(lw['text'])

    # Handle chords that appear before the first lyric word
    pre_chords = []
    if lyric_words:
        first_left = lyric_words[0]['left']
        for ci, cw in enumerate(chord_words):
            if ci not in used_chords:
                chord_text = cw['text'].strip().rstrip(';').rstrip(',').rstrip(':')
                if chord_pattern.match(chord_text) and cw['left'] + cw['width'] < first_left:
                    pre_chords.append(f"[{chord_text}]")
                    used_chords.add(ci)

    if pre_chords:
        return ''.join(pre_chords) + ' '.join(result)
    return ' '.join(result)


def extract_lines_from_pdf(pdf_path):
    all_lines = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            im = page.to_image(resolution=300)
            img = im.original
            data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)

            lines = {}
            for i in range(len(data['text'])):
                if data['text'][i].strip():
                    key = (data['block_num'][i], data['line_num'][i])
                    if key not in lines:
                        lines[key] = []
                    lines[key].append({
                        'text': data['text'][i],
                        'left': data['left'][i],
                        'top': data['top'][i],
                        'width': data['width'][i],
                    })

            sorted_lines = sorted(lines.items(), key=lambda x: x[1][0]['top'])
            all_lines.extend([words for _, words in sorted_lines])
    return all_lines


def convert_to_chordpro(pdf_path):
    all_lines = extract_lines_from_pdf(pdf_path)
    output = []
    i = 0
    while i < len(all_lines):
        words = all_lines[i]
        if is_chord_line(words):
            if i + 1 < len(all_lines) and not is_chord_line(all_lines[i + 1]):
                merged = merge_chord_lyric(words, all_lines[i + 1])
                output.append(merged)
                i += 2
            else:
                chords = ' '.join(f"[{w['text'].strip()}]" for w in words)
                output.append(chords)
                i += 1
        else:
            text = ' '.join(w['text'] for w in words)
            output.append(text)
            i += 1
    return '\n'.join(output)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    pdf_files = sorted([f for f in os.listdir(INPUT_DIR) if f.lower().endswith('.pdf')])
    total = len(pdf_files)

    for idx, filename in enumerate(pdf_files, 1):
        pdf_path = os.path.join(INPUT_DIR, filename)
        txt_filename = os.path.splitext(filename)[0] + '.txt'
        txt_path = os.path.join(OUTPUT_DIR, txt_filename)

        print(f"[{idx}/{total}] Converting: {filename}")
        try:
            result = convert_to_chordpro(pdf_path)
            with open(txt_path, 'w', encoding='utf-8') as f:
                f.write(result)
        except Exception as e:
            print(f"  ERROR: {e}")

    print(f"\nDone! Converted {total} files to {OUTPUT_DIR}/")


if __name__ == '__main__':
    main()
