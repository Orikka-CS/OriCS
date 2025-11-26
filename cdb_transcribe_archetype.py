import os
import sqlite3
import pandas as pd

# 스크립트가 있는 디렉토리 경로를 설정합니다.
script_dir = os.path.dirname(os.path.abspath(__file__))
target_db_name = "cards.cdb"  # 타겟 파일 고정

# --- 상수 정의 (기존과 동일) ---
ATTRIBUTE_MAP = {
    0x01: "땅", 0x02: "물", 0x04: "화염", 0x08: "바람",
    0x10: "빛", 0x20: "어둠", 0x40: "신"
}

RACE_MAP = {
    0x1: "전사족", 0x2: "마법사족", 0x4: "천사족", 0x8: "악마족",
    0x10: "언데드족", 0x20: "기계족", 0x40: "물족", 0x80: "화염족",
    0x100: "암석족", 0x200: "비행야수족", 0x400: "식물족", 0x800: "곤충족",
    0x1000: "번개족", 0x2000: "드래곤족", 0x4000: "야수족", 0x8000: "야수전사족",
    0x10000: "공룡족", 0x20000: "어류족", 0x40000: "해룡족", 0x80000: "파충류족",
    0x100000: "사이킥족", 0x200000: "환신야수족", 0x400000: "창조신족",
    0x800000: "환룡족", 0x1000000: "사이버스족", 0x2000000: "환상마족"
}

# --- 헬퍼 함수 (기존과 동일) ---
def get_attribute_string(attr_val):
    parts = [name for val, name in ATTRIBUTE_MAP.items() if (attr_val & val)]
    return " / ".join(parts) if parts else "?"

def get_race_string(race_val):
    parts = [name for val, name in RACE_MAP.items() if (race_val & val)]
    return " / ".join(parts) if parts else "?"

def get_monster_line(type_val, level_val, attr_val, race_val, atk_val, def_val):
    parts = []
    level_num = level_val & 0xFF
    if (type_val & 0x4000000): parts.append(f"링크 {level_num}")
    elif (type_val & 0x800000): parts.append(f"랭크 {level_num}")
    else: parts.append(f"레벨 {level_num}")

    parts.append(get_attribute_string(attr_val))
    parts.append(get_race_string(race_val))

    summon_methods = []
    if (type_val & 0x40): summon_methods.append("융합")
    if (type_val & 0x80): summon_methods.append("의식")
    if (type_val & 0x2000): summon_methods.append("싱크로")
    if (type_val & 0x800000): summon_methods.append("엑시즈")
    if (type_val & 0x4000000): summon_methods.append("링크")
    if (type_val & 0x2000000): summon_methods.append("특수 소환")
    if summon_methods: parts.append(" / ".join(summon_methods))

    if (type_val & 0x1000000): parts.append("펜듈럼")

    categories = []
    if (type_val & 0x200000): categories.append("리버스")
    if (type_val & 0x400000): categories.append("툰")
    if (type_val & 0x200): categories.append("스피릿")
    if (type_val & 0x400): categories.append("유니온")
    if (type_val & 0x800): categories.append("듀얼")
    if (type_val & 0x1000): categories.append("튜너")
    if categories: parts.append(" / ".join(categories))

    if (type_val & 0x20): parts.append("효과")

    if not (type_val & 0x100):
        atk_str = str(atk_val) if atk_val >= 0 else "?"
        parts.append(f"ATK {atk_str}")
        if not (type_val & 0x4000000):
            def_str = str(def_val) if def_val >= 0 else "?"
            parts.append(f"DEF {def_str}")

    if (type_val & 0x1000000):
        scale_l = (level_val >> 24) & 0xFF
        scale_r = (level_val >> 16) & 0xFF
        scale_str = str(scale_l) if scale_l == scale_r else f"{scale_l}/{scale_r}"
        parts.append(f"PS {scale_str}")

    return " / ".join(parts)

def get_spell_trap_type(type_val):
    if (type_val & 0x2):
        if (type_val & 0x80): return "의식 마법" 
        if (type_val & 0x10000): return "속공 마법"
        if (type_val & 0x20000): return "지속 마법"
        if (type_val & 0x40000): return "장착 마법"
        if (type_val & 0x80000): return "필드 마법"
        return "일반 마법"
    elif (type_val & 0x4):
        if (type_val & 0x20000): return "지속 함정"
        if (type_val & 0x100000): return "카운터 함정"
        return "일반 함정"
    return "알 수 없음"

# --- 메인 로직 시작 ---

# 1. 테마명 입력 받기
theme_keyword = input("👉 검색할 테마명(카드 이름 포함)을 입력하세요: ").strip()

if not theme_keyword:
    print("❌ 검색어가 입력되지 않았습니다. 프로그램을 종료합니다.")
    exit()

db_path = os.path.join(script_dir, target_db_name)

# 2. cards.cdb 존재 여부 확인
if not os.path.exists(db_path):
    print(f"❌ '{target_db_name}' 파일을 찾을 수 없습니다.")
    print(f"경로 확인: {db_path}")
else:
    print(f"🔎 '{target_db_name}'에서 '{theme_keyword}' 검색을 시작합니다...")
    
    try:
        conn = sqlite3.connect(db_path)
        
        # 3. SQL 쿼리: LIKE 문을 사용하여 이름에 키워드가 포함된 것만 조회
        query = """
            SELECT T1.name, T1.desc, T2.type, T2.level, T2.attribute, T2.race, T2.atk, T2.def 
            FROM texts AS T1 
            JOIN datas AS T2 ON T1.id = T2.id
            WHERE T1.name LIKE ?
        """
        
        # SQL 파라미터 바인딩 (%키워드% 형태로 부분 일치 검색)
        params = (f'%{theme_keyword}%',)
        
        df = pd.read_sql_query(query, conn, params=params)
        
        if df.empty:
            print(f"⚠️ '{theme_keyword}'(으)로 검색된 카드가 없습니다.")
        else:
            df['desc'] = df['desc'].str.replace(r'[\r\n]+', '\n', regex=True).str.strip()
            
            # 4. 결과 파일명에 검색어 포함
            # 파일명에 사용할 수 없는 특수문자는 제거 (선택 사항)
            safe_keyword = "".join([c for c in theme_keyword if c.isalnum() or c in (' ', '_', '-')])
            output_txt_name = f"Archetype_{safe_keyword}.txt"
            output_txt_path = os.path.join(script_dir, output_txt_name)
            
            count = 0
            with open(output_txt_path, 'w', encoding='utf-8') as txt_file:
                for index, row in df.iterrows():
                    if pd.isna(row['name']) or pd.isna(row['desc']):
                        continue
                    
                    name = str(row['name'])
                    desc = str(row['desc'])
                    type_val = int(row['type'])
                    level_val = int(row['level'])
                    attr_val = int(row['attribute'])
                    race_val = int(row['race'])
                    atk_val = int(row['atk'])
                    def_val = int(row['def'])

                    # 토큰 제외
                    if (type_val & 0x4000):
                        continue

                    count += 1
                    
                    # 1. 몬스터
                    if (type_val & 0x1):
                        monster_line = get_monster_line(type_val, level_val, attr_val, race_val, atk_val, def_val)
                        txt_file.write(f"{name}\n{monster_line}\n{desc}\n\n")
                    
                    # 2. 마법 또는 함정
                    elif (type_val & 0x2) or (type_val & 0x4):
                        st_type_str = get_spell_trap_type(type_val)
                        txt_file.write(f"{name}\n{st_type_str}\n{desc}\n\n")

            print(f"✅ 변환 완료! 총 {count}장의 카드가 저장되었습니다.")
            print(f"📂 파일 위치: {output_txt_path}")

    except Exception as e:
        print(f"❌ 처리 중 오류 발생: {e}")
    finally:
        if 'conn' in locals() and conn:
            conn.close()