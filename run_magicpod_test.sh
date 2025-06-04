#!/bin/bash -e

OS=mac
FILENAME=magicpod-api-client

# MagicPod CLIのダウンロード
curl -L "https://app.magicpod.com/api/v1.0/magicpod-clients/api/${OS}/latest/" \
  -H "Authorization: Token ${MAGICPOD_API_TOKEN}" --output ${FILENAME}.zip
unzip -q ${FILENAME}.zip

export MAGICPOD_ORGANIZATION=MagicPod_Sakakibara
export MAGICPOD_PROJECT=hands-on

TEST_SETTING_NUMBER=5

# 🔁 空きができるまで待つ処理
MAX_RETRIES=30      # 最大リトライ回数
RETRY_INTERVAL=60   # 秒単位の待機時間

for ((i=1; i<=MAX_RETRIES; i++)); do
    echo "🔍 Checking available mobile app batch devices... (Attempt $i/$MAX_RETRIES)"

    AVAILABLE=$(curl -s -H "Authorization: Token ${MAGICPOD_API_TOKEN}" \
        "https://app.magicpod.com/api/v1.0/MagicPod_Sakakibara/cloud-devices/" \
        | jq '.mobile_app.batch_test_run.available')

    if [ "$AVAILABLE" -ge 1 ]; then
        echo "✅ Available devices found: $AVAILABLE"
        break
    else
        echo "⏳ No available devices (found $AVAILABLE). Retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "❌ Timed out waiting for available devices."
        exit 1
    fi
done

# ✅ バッチ実行
echo "🚀 Running MagicPod batch run..."
./magicpod-api-client batch-run -S ${TEST_SETTING_NUMBER}
