#!/usr/bin/env python3
import sys
import re


def calculate_check_digit(data):
    weights = [7, 3, 1]
    total = 0
    char_values = {str(i): i for i in range(10)}
    char_values.update(
        {chr(c): c - ord('A') + 10 for c in range(ord('A'), ord('Z') + 1)})
    char_values['<'] = 0

    for i, char in enumerate(data):
        total += char_values.get(char.upper(), 0) * weights[i % 3]

    return str(total % 10)


def update_mrz_document_number(mrz, new_doc_number):
    # Pad document number to 9 characters
    new_doc_number = new_doc_number.ljust(9, '<')[:9]
    check_digit = calculate_check_digit(new_doc_number)
    new_field = new_doc_number + check_digit

    # MRZ is 90 chars (TD1 format), document number is at positions 5-14 (0-indexed)
    mrz = mrz[:5] + new_field + mrz[15:]
    return mrz, new_doc_number, check_digit


def update_perso_file(perso_path, new_doc_number):
    with open(perso_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find and replace MRZ
    mrz_pattern = re.compile(r'(<mrz>)([^<]+)(</mrz>)')
    match = mrz_pattern.search(content)

    if not match:
        print("ERROR: No MRZ found in perso file!")
        sys.exit(1)

    # Unescape XML entities before processing
    old_mrz = match.group(2).replace('&lt;', '<')
    print(f"Old MRZ: {old_mrz}")
    print(f"Old document number: {old_mrz[5:14]} (check digit: {old_mrz[14]})")

    new_mrz, padded_doc_number, check_digit = update_mrz_document_number(
        old_mrz, new_doc_number)
    print(f"New MRZ: {new_mrz}")
    print(f"New document number: {new_mrz[5:14]} (check digit: {new_mrz[14]})")

    # Re-escape < back to &lt; for XML
    new_mrz_escaped = new_mrz.replace('<', '&lt;')

    content = content.replace(
        match.group(1) + match.group(2) + match.group(3),
        match.group(1) + new_mrz_escaped + match.group(3)
    )

    # Update idPicc - it's the document number + check digit encoded as hex ASCII
    new_id_picc = (padded_doc_number + check_digit).encode().hex()
    old_id_picc_pattern = re.compile(r'(<idPicc[^>]*>)([^<]+)(</idPicc>)')
    id_picc_match = old_id_picc_pattern.search(content)

    if id_picc_match:
        old_id_picc = id_picc_match.group(2)
        print(f"\nOld idPicc: {old_id_picc} ({
              bytes.fromhex(old_id_picc).decode()})")
        print(f"New idPicc: {new_id_picc} ({
              bytes.fromhex(new_id_picc).decode()})")
        content = content.replace(
            id_picc_match.group(1) + old_id_picc + id_picc_match.group(3),
            id_picc_match.group(1) + new_id_picc + id_picc_match.group(3)
        )
    else:
        print("WARNING: No idPicc found in perso file!")

    with open(perso_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"\nDone! Updated {perso_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 update_doc_number.py <perso_file> <new_document_number>")
        print("Example: python3 update_doc_number.py profile.perso L01X02Y34")
        sys.exit(1)

    update_perso_file(sys.argv[1], sys.argv[2])
