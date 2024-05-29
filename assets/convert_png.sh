for file in $(ls ../output/*.pdf); do
    echo "Processing ${file}..."
    convert -density 150 -depth 8 -quality 85 "${file}" "../assets/${file%.*}.png"
done
