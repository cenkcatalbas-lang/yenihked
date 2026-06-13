import streamlit as st
import pandas as pd
import requests

st.set_page_config(page_title="HKED 2026", layout="wide")
st.title("🏆 HKED 2026 Tahmin Paneli")

# 1. Dosya Yükleme (Sıfır hata garantisi için)
uploaded_file = st.file_uploader("Lütfen Excel dosyanızı yükleyin:", type=['xlsx'])

if uploaded_file:
    # 2. Veriyi Oku
    df = pd.read_excel(uploaded_file, header=None)
    
    # 3. Canlı Skorları Çek (API)
    url = "https://www.thesportsdb.com/api/v1/json/3/eventspastleague.php?id=4429"
    try:
        response = requests.get(url).json()
        live_results = {}
        if 'events' in response:
            for e in response['events']:
                key = f"{e['strHomeTeam']} - {e['strAwayTeam']}"
                home, away = int(e['intHomeScore'] or 0), int(e['intAwayScore'] or 0)
                res = "1" if home > away else ("2" if away > home else "0")
                live_results[key] = res
        
        # 4. Puanlama (Katılımcılar: 6-10 arası sütunlar)
        katilimcilar = {6: 'TOLGA', 7: 'MUSTAFA', 8: 'IŞITAN', 9: 'YİĞİT', 10: 'CENK'}
        skorlar = {isim: 0.0 for isim in katilimcilar.values()}
        
        for _, row in df.iterrows():
            mac_adi = row[0]
            if mac_adi in live_results:
                gercek_sonuc = live_results[mac_adi]
                # Katsayılar: 1=Sütun3, 0=Sütun4, 2=Sütun5
                katsayi_idx = {"1": 3, "0": 4, "2": 5}
                katsayi = float(row[katsayi_idx[gercek_sonuc]])
                
                for col, isim in katilimcilar.items():
                    if str(row[col]) == gercek_sonuc:
                        skorlar[isim] += katsayi
        
        # 5. Sonuçları Göster
        st.subheader("📊 Güncel Puan Durumu")
        st.table(pd.DataFrame(list(skorlar.items()), columns=['İsim', 'Puan']))
        
    except Exception as e:
        st.error(f"Sistem hatası: {e}")
else:
    st.info("Lütfen Excel dosyanızı (NEW HKED.xlsx) yükleyerek başlayın.")
