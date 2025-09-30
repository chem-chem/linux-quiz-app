from pathlib import Path
import json, random

def main():
    data_path = Path(__file__).parent / "data" / "questions.json"
    data = json.loads(data_path.read_text(encoding="utf-8"))
    random.shuffle(data)
    score = 0
    for q in data:
        print("\n問題:", q["question"])
        if input("答え: ").strip() == q["answer"]:
            print("✅ 正解"); score += 1
        else:
            print("❌ 不正解。正解は:", q["answer"])
    print(f"\nスコア: {score}/{len(data)}")

if __name__ == "__main__":
    main()
