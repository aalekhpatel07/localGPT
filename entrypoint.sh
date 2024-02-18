#!/usr/bin/env sh

pip install streamlit-extras --upgrade
python -m nltk.downloader all
unzip ~/nltk_data/tokenizers/punkt.zip
python /app/ingest.py --data-dir /data
streamlit run /app/localGPT_UI.py
