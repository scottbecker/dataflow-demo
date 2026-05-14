# Dataflow Hello World (WordCount)

This directory contains a simple Apache Beam pipeline that counts words in a text file. This is the "Hello World" of Dataflow.

## Setup

1. Create a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Running Locally

To run the pipeline locally using the `DirectRunner`:

```bash
python3 word_count.py --output outputs
```

This will create files starting with `outputs-00000-of-00001`.

## Running on Google Cloud Dataflow

To run the pipeline on Google Cloud Dataflow, you need a Google Cloud Storage bucket.

```bash
# Set your variables
PROJECT_ID="maps-346818"
BUCKET_NAME="your-bucket-name" # Replace with your bucket
REGION="us-central1"

python3 word_count.py \
    --region $REGION \
    --input gs://dataflow-samples/shakespeare/kinglear.txt \
    --output gs://$BUCKET_NAME/results/outputs \
    --runner DataflowRunner \
    --project $PROJECT_ID \
    --temp_location gs://$BUCKET_NAME/temp/
```

Note: Ensure the Dataflow API is enabled in your project.
