#!/bin/bash
# Auto-contribution script - runs forever
# 65-130 commits per day, catches up missed days

REPO_DIR="/tmp/mega-repo"
EMAIL="njfv17@gmail.com"
NAME="brkN"
MIN_COMMITS=65
MAX_COMMITS=130
MODULES=("utils" "helpers" "core" "models" "api" "auth" "db" "cache" "workers" "tasks" "validators" "serializers" "handlers" "middleware" "config" "exceptions" "services" "repositories" "schemas" "routes")
LOG_FILE="/tmp/auto-contribute-history.log"

cd "$REPO_DIR" || exit 1
git config user.email "$EMAIL"
git config user.name "$NAME"
git pull origin main 2>/dev/null

# Get last contribution date from log
LAST_DATE=""
if [ -f "$LOG_FILE" ]; then
    LAST_DATE=$(tail -1 "$LOG_FILE" | cut -d' ' -f1)
fi

TODAY=$(date -u +%Y-%m-%d)
if [ -z "$LAST_DATE" ]; then
    DAYS_TO_RUN=1
else
    LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_DATE" +%s 2>/dev/null || date -d "$LAST_DATE" +%s 2>/dev/null)
    TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null || date -d "$TODAY" +%s 2>/dev/null)
    DIFF=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))
    if [ "$DIFF" -gt 0 ]; then
        DAYS_TO_RUN=$DIFF
    else
        DAYS_TO_RUN=0
    fi
fi

if [ "$DAYS_TO_RUN" -eq 0 ]; then
    echo "$(date): Already ran today, skipping"
    exit 0
fi

TOTAL_COMMITS=0
for d in $(seq 0 $((DAYS_TO_RUN - 1))); do
    RUN_DATE=$(date -u -v+${d}d +%Y-%m-%d 2>/dev/null || date -u -d "+${d} days" +%Y-%m-%d 2>/dev/null)
    
    COMMIT_COUNT=$((RANDOM % ($MAX_COMMITS - $MIN_COMMITS + 1) + $MIN_COMMITS))
    MODULE=${MODULES[$RANDOM % ${#MODULES[@]}]}
    mkdir -p "src/$MODULE"

    for i in $(seq 1 $COMMIT_COUNT); do
        TS=$(date +%s%N)
        FILENAME="src/$MODULE/feature_${TS}_${i}.py"
        
        cat > "$FILENAME" << PYEOF
"""Feature $i - Auto-generated for $RUN_DATE"""

import hashlib
import json
from datetime import datetime
from typing import Any, Dict, List, Optional


class Feature{i}:
    """Feature for contribution graph."""
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        self.created_at = datetime.now()
    
    def process(self, data: List[Any]) -> Dict[str, Any]:
        return {"processed": len(data), "ts": self.created_at.isoformat()}
    
    def validate(self, value: Any) -> bool:
        return value is not None
    
    def compute_hash(self, data: str) -> str:
        return hashlib.sha256(data.encode()).hexdigest()


if __name__ == "__main__":
    f = Feature$i()
    print(json.dumps(f.process([1, 2, 3]), indent=2))
PYEOF
        git add "$FILENAME" && \
        git commit -m "feat($MODULE): feature $i" --quiet 2>/dev/null
    done
    
    echo "$RUN_DATE $COMMIT_COUNT commits" >> "$LOG_FILE"
    TOTAL_COMMITS=$((TOTAL_COMMITS + COMMIT_COUNT))
done

git push origin main 2>/dev/null
echo "$(date): $TOTAL_COMMITS total commits for $DAYS_TO_RUN day(s)"
