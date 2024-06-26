#!/bin/env bash

# Schleife durch alle .sh, .md, .conf, .dcol und .themne Dateien im aktuellen Verzeichnis und in allen Unterverzeichnissen
find . \( -name "*.sh" -o -name "*.md" -o -name "*.conf" -o -name "*.dcol" -o -name "*.themne" -o -name "*.zsh" -o -name "*.zshrc" -o -name "*.lst" \) -type f | while read -r file; do
    # CR (Carriage Return) entfernen und die Datei überschreiben
    tr -d '\r' <"$file" >temp_file && mv temp_file "$file"
    echo "Bearbeitet: $file"
done

echo "Alle angegebenen Dateien wurden bearbeitet."
